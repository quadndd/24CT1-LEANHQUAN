// ============================================================
// trips_screen.dart — Màn hình Lịch sử chuyến đi (Khách hàng)
// Tải danh sách chuyến đã thực hiện từ Supabase và hiển thị theo thời gian
// ============================================================
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';    // Lấy lịch sử chuyến từ DB
import 'package:shared_preferences/shared_preferences.dart'; // Lấy userId từ session
import 'package:intl/intl.dart';                            // Format ngày tháng
import '../../core/theme.dart';                             // Màu sắc app

class CustomerTripsScreen extends StatefulWidget {
  const CustomerTripsScreen({super.key});

  @override
  State<CustomerTripsScreen> createState() => _CustomerTripsScreenState();
}

class _CustomerTripsScreenState extends State<CustomerTripsScreen> {
  List<Map<String, dynamic>> _trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTrips();
  }

  Future<void> _fetchTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('id');
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Lấy tên khách để query (vì rides lưu customer_name, không lưu customer_id)
      final username = prefs.getString('username') ?? '';

      // Lấy tất cả rides từ bảng, tìm theo customer_name hoặc customer_id nếu có
      final data = await Supabase.instance.client
          .from('rides')
          .select()
          .eq('customer_id', userId)
          .order('created_at', ascending: false)
          .limit(20);

      if (mounted) {
        setState(() {
          _trips = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      // Nếu lỗi (bảng rides không có cột customer_id), fallback về empty
      if (mounted) setState(() => _isLoading = false);
      debugPrint('Lỗi fetch trips: $e');
    }
  }

  String _formatDate(String? isoString) {
    if (isoString == null) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inDays == 0) return 'Hôm nay, ${DateFormat('HH:mm').format(dt)}';
      if (diff.inDays == 1) return 'Hôm qua, ${DateFormat('HH:mm').format(dt)}';
      return DateFormat('dd/MM/yyyy, HH:mm').format(dt);
    } catch (_) {
      return isoString;
    }
  }

  String _formatAmount(dynamic amount) {
    if (amount == null) return '0 đ';
    final str = amount.toString().replaceAll(RegExp(r'[^\d]'), '');
    final num = int.tryParse(str) ?? 0;
    return num.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        ) +
        ' đ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            const Icon(Icons.receipt_long, color: Color(0xFF006E2E)),
            const SizedBox(width: 8),
            const Text('Chuyến Xe Của Tôi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF151C27))),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF006E2E)),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchTrips();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00B14F)))
          : _trips.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.receipt_long_outlined, size: 64, color: Color(0xFFBCCBB9)),
                      SizedBox(height: 12),
                      Text('Chưa có chuyến đi nào', style: TextStyle(fontSize: 16, color: Color(0xFF6D7B6C))),
                      SizedBox(height: 4),
                      Text('Đặt xe ngay để bắt đầu hành trình!',
                          style: TextStyle(fontSize: 13, color: Color(0xFF3D4A3D))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _trips.length,
                  itemBuilder: (context, index) {
                    final trip = _trips[index];
                    final isCompleted = trip['status'] == 'completed';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildTripCard(trip, isCompleted),
                    );
                  },
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF006E2E),
        unselectedItemColor: const Color(0xFF6D7B6C),
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Chuyến đi'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), activeIcon: Icon(Icons.notifications), label: 'Thông báo'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Cá nhân'),
        ],
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/customer/home');
          if (index == 2) Navigator.pushReplacementNamed(context, '/customer/notifications');
          if (index == 3) Navigator.pushReplacementNamed(context, '/customer/profile');
        },
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip, bool isCompleted) {
    final status = isCompleted ? 'Hoàn thành' : 'Đã hủy';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(trip['created_at']?.toString()),
                style: const TextStyle(fontSize: 12, color: Color(0xFF3D4A3D)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted ? const Color(0xFF87FB9D).withOpacity(0.4) : const Color(0xFFFFDAD6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? const Color(0xFF003A15) : const Color(0xFF93000A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: isCompleted ? const Color(0xFFF0F3FF) : const Color(0xFFFFDAD6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted ? Icons.local_taxi : Icons.cancel,
                  color: isCompleted ? const Color(0xFF006E2E) : const Color(0xFF93000A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (trip['pickup_location'] != null)
                      Row(children: [
                        const Icon(Icons.radio_button_checked, size: 12, color: Color(0xFF006E2E)),
                        const SizedBox(width: 4),
                        Expanded(child: Text(trip['pickup_location'].toString(), style: const TextStyle(fontSize: 12, color: Color(0xFF3D4A3D)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ]),
                    const SizedBox(height: 2),
                    Row(children: [
                      const Icon(Icons.location_on, size: 12, color: Color(0xFFBA1A1A)),
                      const SizedBox(width: 4),
                      Expanded(child: Text(trip['dropoff_location']?.toString() ?? 'Không có thông tin', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF151C27)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                    if (trip['vehicle_type'] != null)
                      Text(trip['vehicle_type'].toString(), style: const TextStyle(fontSize: 11, color: Color(0xFF6D7B6C))),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatAmount(trip['amount']),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF151C27)),
                  ),
                  if (trip['rating'] != null && trip['rating'].toString().isNotEmpty)
                    Row(children: [
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      Text(trip['rating'].toString(), style: const TextStyle(fontSize: 11)),
                    ]),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}


