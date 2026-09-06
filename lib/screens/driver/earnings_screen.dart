import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../core/theme.dart';

class DriverEarningsScreen extends StatefulWidget {
  const DriverEarningsScreen({super.key});

  @override
  State<DriverEarningsScreen> createState() => _DriverEarningsScreenState();
}

class _DriverEarningsScreenState extends State<DriverEarningsScreen> {
  int _totalBalance = 0;
  int _todayEarnings = 0;
  int _completedRidesCount = 0;
  String _avatar = 'https://lh3.googleusercontent.com/aida-public/AB6AXuBcB6uHyYEU_xr6DEBl4XDbCaR2T_IUrX2ZvjTcafV3yUJMctgzZBGZwbEAykn9A-78ZYd0E5TXtUJ705T4b57S4jpCYEv5w21xQYh9s0wfQtlXWNv9mHSxDPQXDvOW734cp8YSD7L6th4MzpnSzlvguzm8CrOP3OuOXhAWhLVDJDuqoKs8OjA8EG8W7eXukmKbOvrSzTbiO9Grld-lb10dkRe05sInKX2Ri4nbhBhlYa_jo4EZUyA';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEarnings();
  }

  Future<void> _fetchEarnings() async {
    final prefs = await SharedPreferences.getInstance();
    final driverId = prefs.getString('id');
    if (driverId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final profile = await Supabase.instance.client
          .from('driver_profiles')
          .select('face_image')
          .eq('user_id', driverId)
          .maybeSingle();
      if (profile != null && profile['face_image'] != null && mounted) {
        setState(() => _avatar = profile['face_image']);
      }

      final rides = await Supabase.instance.client
          .from('rides')
          .select('amount, created_at')
          .eq('driver_id', driverId)
          .eq('status', 'completed');

      int total = 0;
      int todayTotal = 0;
      final today = DateTime.now();
      
      for (var r in rides) {
        String amountStr = r['amount'].toString().replaceAll(RegExp(r'[^0-9]'), '');
        int amt = int.tryParse(amountStr) ?? 0;
        total += amt;
        
        DateTime created = DateTime.parse(r['created_at']);
        if (created.year == today.year && created.month == today.month && created.day == today.day) {
          todayTotal += amt;
        }
      }

      if (mounted) {
        setState(() {
          _totalBalance = total;
          _todayEarnings = todayTotal;
          _completedRidesCount = rides.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
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
                Text('Thu Nhập', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF151C27))),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Tabs
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: const Color(0xFFE7EEFE), borderRadius: BorderRadius.circular(24)),
              child: Row(
                children: [
                  Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)]), child: const Center(child: Text('Hôm nay', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF006E2E)))))),
                  Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 8), child: const Center(child: Text('Tuần này', style: TextStyle(fontSize: 13, color: Color(0xFF3D4A3D)))))),
                  Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 8), child: const Center(child: Text('30 ngày', style: TextStyle(fontSize: 13, color: Color(0xFF3D4A3D)))))),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Wallet Balance
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(width: 32, height: 32, decoration: const BoxDecoration(color: Color(0xFF87FB9D), shape: BoxShape.circle), child: const Icon(Icons.account_balance_wallet, size: 18, color: Color(0xFF007433))),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Số dư khả dụng', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))),
                          Text('1.840.000 đ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF151C27))),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFE7EEFE), borderRadius: BorderRadius.circular(12)),
                    child: const Row(children: [Icon(Icons.circle, size: 8, color: Color(0xFF006E2E)), SizedBox(width: 4), Text('Tức thì 24/7', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF006E2E)))]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Hero Earnings Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF003A15), Color(0xFF006E2E), Color(0xFF00B14F)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('THU NHẬP HÔM NAY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.8))),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: const Row(children: [Icon(Icons.trending_up, size: 14, color: Colors.white), SizedBox(width: 4), Text('+18.4%', style: TextStyle(fontSize: 11, color: Colors.white))])),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [Text('650.000', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white)), SizedBox(width: 4), Text('đ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white))]),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Icon(Icons.calendar_today, size: 14, color: Colors.white70), SizedBox(width: 4), Text('Tuần: 4.250.000 đ', style: TextStyle(fontSize: 11, color: Colors.white70)),
                      SizedBox(width: 8), Text('•', style: TextStyle(color: Colors.white70)), SizedBox(width: 8),
                      Icon(Icons.local_taxi, size: 14, color: Colors.white70), SizedBox(width: 4), Text('128 chuyến', style: TextStyle(fontSize: 11, color: Colors.white70)),
                      SizedBox(width: 8), Text('•', style: TextStyle(color: Colors.white70)), SizedBox(width: 8),
                      Icon(Icons.schedule, size: 14, color: Colors.white70), SizedBox(width: 4), Text('36h online', style: TextStyle(fontSize: 11, color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity, height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.account_balance, color: Color(0xFF006E2E)),
                      label: const Text('Rút tiền về ngân hàng Vietcombank', style: TextStyle(color: Color(0xFF006E2E), fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Bonus Quest
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF87FB9D), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.military_tech, color: Color(0xFF007433))),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Thưởng vượt mốc hôm nay', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF151C27))),
                              Text('Đã đạt 12/15 cuốc', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF006E2E))),
                            ],
                          ),
                        ],
                      ),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF87FB9D), borderRadius: BorderRadius.circular(12)), child: const Text('+100.000 đ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF007433)))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(value: 0.8, backgroundColor: const Color(0xFFDCE2F3), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF006E2E)), minHeight: 8),
                  ),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text('Nhận thêm 100.000đ khi hoàn thành 3 cuốc nữa', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))), Text('80%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF151C27)))]),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Chart
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Biểu đồ thu nhập tuần', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF151C27))),
                          Text('Cao nhất vào Chủ Nhật (650k)', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))),
                        ],
                      ),
                      const Icon(Icons.bar_chart, color: Color(0xFF6D7B6C)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildChartBar('T2', 0.55),
                        _buildChartBar('T3', 0.62),
                        _buildChartBar('T4', 0.48),
                        _buildChartBar('T5', 0.68),
                        _buildChartBar('T6', 0.76),
                        _buildChartBar('T7', 0.82),
                        _buildChartBar('CN', 0.95, isToday: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Recent Transactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Lịch sử thu nhập gần đây', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF151C27))),
                Text('Xem tất cả >', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF006E2E))),
              ],
            ),
            const SizedBox(height: 12),
            _buildTxItem(Icons.two_wheeler, 'Cuốc #TX-8921', 'Điểm đến: Landmark 81 • 16:45', '+52.000 đ', 'Ví điện tử'),
            const SizedBox(height: 8),
            _buildTxItem(Icons.two_wheeler, 'Cuốc #TX-8920', 'Điểm đến: Bitexco Tower • 15:20', '+38.000 đ', 'Tiền mặt'),
            const SizedBox(height: 8),
            _buildTxItem(Icons.bolt, 'Thưởng giờ cao điểm', 'Khu vực Q.1 & Q.3 • 12:00', '+30.000 đ', 'Thưởng nóng', isBonus: true),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
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
          // if (index == 1) Navigator.pushReplacementNamed(context, '/driver/trips');
          if (index == 3) Navigator.pushReplacementNamed(context, '/driver/profile');
        },
      ),
    );
  }

  Widget _buildChartBar(String label, double heightRatio, {bool isToday = false}) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 100 * heightRatio,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: isToday ? const Color(0xFF00B14F) : const Color(0xFFDCE2F3),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: isToday ? FontWeight.bold : FontWeight.normal, color: isToday ? const Color(0xFF006E2E) : const Color(0xFF3D4A3D))),
        ],
      ),
    );
  }

  Widget _buildTxItem(IconData icon, String title, String subtitle, String amount, String method, {bool isBonus = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: isBonus ? const Color(0xFF87FB9D) : const Color(0xFF006E2E).withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: isBonus ? const Color(0xFF007433) : const Color(0xFF006E2E))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF151C27))),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF006E2E))),
              Text(method, style: TextStyle(fontSize: 11, fontWeight: isBonus ? FontWeight.bold : FontWeight.normal, color: isBonus ? const Color(0xFF007433) : const Color(0xFF3D4A3D))),
            ],
          ),
        ],
      ),
    );
  }
}
