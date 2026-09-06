import 'package:flutter/material.dart';
import '../../core/theme.dart';

class CustomerNotificationsScreen extends StatelessWidget {
  const CustomerNotificationsScreen({super.key});

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
            const Icon(Icons.notifications, color: Color(0xFF006E2E)),
            const SizedBox(width: 8),
            const Text('Thông Báo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF151C27))),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationCard('Khuyến mãi', 'Giảm 20.000đ cho chuyến đi tiếp theo của bạn! Nhập mã GORIDE20.', '10 phút trước', Icons.local_offer, true),
          const SizedBox(height: 12),
          _buildNotificationCard('Tin tức', 'GoRide VN chính thức ra mắt tính năng đặt xe máy.', 'Hôm qua', Icons.two_wheeler, false),
          const SizedBox(height: 12),
          _buildNotificationCard('Hệ thống', 'Bảo trì hệ thống từ 00:00 - 02:00 ngày mai.', '2 ngày trước', Icons.info, false),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
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
          if (index == 1) Navigator.pushReplacementNamed(context, '/customer/trips');
          if (index == 3) Navigator.pushReplacementNamed(context, '/customer/profile');
        },
      ),
    );
  }

  Widget _buildNotificationCard(String title, String content, String time, IconData icon, bool isUnread) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isUnread ? const Color(0xFFF0F3FF) : Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFFE7EEFE), shape: BoxShape.circle), child: Icon(icon, color: const Color(0xFF006E2E))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: TextStyle(fontSize: 15, fontWeight: isUnread ? FontWeight.bold : FontWeight.w600, color: const Color(0xFF151C27))),
                    if (isUnread) Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFBA1A1A), shape: BoxShape.circle)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(fontSize: 13, color: Color(0xFF3D4A3D))),
                const SizedBox(height: 8),
                Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
