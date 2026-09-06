import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../core/theme.dart';

class DriverTripsScreen extends StatefulWidget {
  const DriverTripsScreen({super.key});

  @override
  State<DriverTripsScreen> createState() => _DriverTripsScreenState();
}

class _DriverTripsScreenState extends State<DriverTripsScreen> {
  int _selectedFilter = 0; // 0: All, 1: Completed, 2: Cancelled
  bool _isLoading = true;
  List<dynamic> _rides = [];
  String _avatar = 'https://lh3.googleusercontent.com/aida-public/AB6AXuBcB6uHyYEU_xr6DEBl4XDbCaR2T_IUrX2ZvjTcafV3yUJMctgzZBGZwbEAykn9A-78ZYd0E5TXtUJ705T4b57S4jpCYEv5w21xQYh9s0wfQtlXWNv9mHSxDPQXDvOW734cp8YSD7L6th4MzpnSzlvguzm8CrOP3OuOXhAWhLVDJDuqoKs8OjA8EG8W7eXukmKbOvrSzTbiO9Grld-lb10dkRe05sInKX2Ri4nbhBhlYa_jo4EZUyA';

  @override
  void initState() {
    super.initState();
    _fetchRides();
  }

  Future<void> _fetchRides() async {
    final prefs = await SharedPreferences.getInstance();
    final driverId = prefs.getString('id');
    if (driverId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      // Get avatar
      final profile = await Supabase.instance.client
          .from('driver_profiles')
          .select('face_image')
          .eq('user_id', driverId)
          .maybeSingle();
      if (profile != null && profile['face_image'] != null && mounted) {
        setState(() => _avatar = profile['face_image']);
      }

      // Get rides
      final data = await Supabase.instance.client
          .from('rides')
          .select()
          .eq('driver_id', driverId)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _rides = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching rides: $e');
      if (mounted) setState(() => _isLoading = false);
    }
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
            const Icon(Icons.drive_eta, color: Color(0xFF006E2E)),
            const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('TÀI XẾ', style: TextStyle(fontSize: 10, color: Color(0xFF3D4A3D), letterSpacing: 1.0)),
              Text('Chuyến Xe', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF151C27))),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.notifications, color: Color(0xFF3D4A3D)), onPressed: () {}),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            radius: 16,
            backgroundImage: _avatar.startsWith('data:image') ? MemoryImage(base64Decode(_avatar.split(',')[1])) as ImageProvider : NetworkImage(_avatar),
          ),
        ),
      ],
    ),
      body: Column(
        children: [
          // Search & Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.background,
            child: Column(
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                  child: const TextField(decoration: InputDecoration(hintText: 'Tìm theo mã chuyến (#TX-8921)...', hintStyle: TextStyle(fontSize: 14, color: Colors.grey), border: InputBorder.none, icon: Icon(Icons.search, color: Colors.grey))),
                ),
                const SizedBox(height: 12),

                // Stats Bar
                Row(
                  children: [
                    Expanded(child: _buildStatItem('Tổng số', '${_rides.length}', null)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatItem('Hoàn tất', '${_rides.where((r) => r['status'] == 'completed').length}', const Color(0xFF006E2E))),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatItem('Hủy chuyến', '${_rides.where((r) => r['status'] == 'cancelled').length}', const Color(0xFFBA1A1A))),
                  ],
                ),
                const SizedBox(height: 12),

                // Filter Pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterPill(0, 'Tất cả', '${_rides.length}'),
                      const SizedBox(width: 8),
                      _buildFilterPill(1, 'Hoàn thành', '(${_rides.where((r) => r['status'] == 'completed').length})'),
                      const SizedBox(width: 8),
                      _buildFilterPill(2, 'Đã hủy', '(${_rides.where((r) => r['status'] == 'cancelled').length})'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00B14F)))
                : _rides.isEmpty 
                    ? const Center(child: Text('Chưa có chuyến xe nào', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _rides.length,
                        itemBuilder: (context, index) {
                          final ride = _rides[index];
                          // Lọc danh sách theo tab
                          if (_selectedFilter == 1 && ride['status'] != 'completed') return const SizedBox.shrink();
                          if (_selectedFilter == 2 && ride['status'] != 'cancelled') return const SizedBox.shrink();

                          final createdAt = DateTime.parse(ride['created_at']);
                          final timeString = DateFormat('dd/MM, HH:mm').format(createdAt);
                          // Lấy id rút gọn
                          final shortId = ride['id'].toString().substring(0, 6).toUpperCase();

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildTripCard(
                              shortId, timeString, ride['customer_name'] ?? 'Khách',
                              ride['rating'] ?? '5.0', ride['vehicle_type'] ?? 'Car 4 Chỗ', ride['payment_method'] ?? 'Tiền mặt',
                              ride['pickup_address'] ?? 'Đang cập nhật', ride['dropoff_address'] ?? 'Đang cập nhật',
                              ride['amount'] ?? '0 đ', ride['status'] == 'completed',
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF006E2E),
        unselectedItemColor: const Color(0xFF3D4A3D),
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Chuyến xe'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Thu nhập'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
        ],
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/driver/home');
          if (index == 2) Navigator.pushReplacementNamed(context, '/driver/earnings');
          if (index == 3) Navigator.pushReplacementNamed(context, '/driver/profile');
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color? color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: color != null ? color.withOpacity(0.1) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: color != null ? color.withOpacity(0.2) : Colors.grey.withOpacity(0.2))),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: color ?? const Color(0xFF3D4A3D))),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color ?? const Color(0xFF151C27))),
        ],
      ),
    );
  }

  Widget _buildFilterPill(int index, String label, String badge) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? const Color(0xFF006E2E) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? const Color(0xFF006E2E) : Colors.grey.withOpacity(0.3))),
        child: Row(
          children: [
            Text(label, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.white : const Color(0xFF3D4A3D))),
            const SizedBox(width: 6),
            Text(badge, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white70 : Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(String code, String time, String customer, String rating, String type, String method, String pickup, String dropoff, String amount, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 32, height: 32, decoration: BoxDecoration(color: isCompleted ? const Color(0xFFF0F3FF) : const Color(0xFFFFDAD6), shape: BoxShape.circle), child: Icon(isCompleted ? Icons.local_taxi : Icons.cancel, size: 16, color: isCompleted ? const Color(0xFF006E2E) : const Color(0xFF93000A))),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(time, style: const TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))),
                      Text('#$code', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF151C27))),
                    ],
                  ),
                ],
              ),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: isCompleted ? const Color(0xFF87FB9D).withOpacity(0.4) : const Color(0xFFFFDAD6), borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(Icons.circle, size: 8, color: isCompleted ? const Color(0xFF006E2E) : const Color(0xFFBA1A1A)), const SizedBox(width: 4), Text(isCompleted ? 'Hoàn thành' : 'Khách hủy', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isCompleted ? const Color(0xFF003A15) : const Color(0xFF93000A)))])),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFF9F9FF), borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(radius: 18, backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBmKxCfGkjyzrxAEszuKHcHYitR_3B62hdHfdcZ2dEnfF0wR8nNNszQvkcyFwMW8Z2wTxeMXesK5fGPhl311SpKBag6_OECxdDUQmG8NIBTQagS-ULeCrIOi96hzFyVqpiHFGUET34T1dSPozzjI2IFkiVDa0OmT71kZPyqzBTgiOhKmQpjpUqK3GLBHbIPpnJKNnD1iys2c6-0qoQMQ0d6OVZY74T-2-SlKq4VHacR-RUMj9x-BB8')),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [Text(customer, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF151C27))), if (rating.isNotEmpty) ...[const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)), child: Row(children: [const Icon(Icons.star, size: 10, color: Colors.amber), Text(rating, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))]))]]),
                        Text(type, style: const TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))),
                      ],
                    ),
                  ],
                ),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: isCompleted ? Colors.white : const Color(0xFFFFDAD6).withOpacity(0.5), borderRadius: BorderRadius.circular(4)), child: Text(method, style: const TextStyle(fontSize: 11, color: Color(0xFF3D4A3D)))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  const SizedBox(height: 4),
                  Container(width: 14, height: 14, decoration: BoxDecoration(color: const Color(0xFF006E2E).withOpacity(0.2), shape: BoxShape.circle), child: Center(child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF006E2E), shape: BoxShape.circle)))),
                  if (dropoff.isNotEmpty) Container(width: 2, height: 28, color: const Color(0xFFBCCBB9), margin: const EdgeInsets.symmetric(vertical: 4)),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Điểm đón', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))),
                    Text(pickup, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF151C27))),
                  ],
                ),
              ),
            ],
          ),
          if (dropoff.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 4),
                    Container(width: 14, height: 14, decoration: BoxDecoration(color: const Color(0xFFBA1A1A).withOpacity(0.2), shape: BoxShape.circle), child: Center(child: Container(width: 6, height: 6, decoration: BoxDecoration(color: const Color(0xFFBA1A1A), borderRadius: BorderRadius.circular(2))))),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Điểm đến', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))),
                      Text(dropoff, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF151C27))),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          Container(height: 1, color: Colors.grey.withOpacity(0.2)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isCompleted ? 'Thu nhập thực nhận' : 'Cộng ví tài xế', style: const TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))),
                  Text(amount, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF006E2E))),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.chevron_right, size: 18),
                label: const Text('Chi tiết', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF0F3FF), foregroundColor: const Color(0xFF151C27), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
