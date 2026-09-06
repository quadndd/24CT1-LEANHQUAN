import 'package:flutter/material.dart';
import '../../core/theme.dart';

class CustomerTripsScreen extends StatelessWidget {
  const CustomerTripsScreen({super.key});

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
            const Text('Chuyến Xe Của Tôi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF151C27))),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTripCard('Hôm nay, 16:45', 'Hoàn thành', 'Landmark 81, Bình Thạnh', '52.000 đ', true),
          const SizedBox(height: 12),
          _buildTripCard('Hôm qua, 09:30', 'Hoàn thành', 'Sân bay Tân Sơn Nhất', '88.000 đ', true),
          const SizedBox(height: 12),
          _buildTripCard('Hôm qua, 21:15', 'Đã hủy', 'Bùi Viện, Q.1', '0 đ', false),
        ],
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

  Widget _buildTripCard(String time, String status, String dropoff, String price, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(time, style: const TextStyle(fontSize: 12, color: Color(0xFF3D4A3D))),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: isCompleted ? const Color(0xFF87FB9D).withOpacity(0.4) : const Color(0xFFFFDAD6), borderRadius: BorderRadius.circular(12)), child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isCompleted ? const Color(0xFF003A15) : const Color(0xFF93000A)))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: isCompleted ? const Color(0xFFF0F3FF) : const Color(0xFFFFDAD6), shape: BoxShape.circle), child: Icon(isCompleted ? Icons.local_taxi : Icons.cancel, color: isCompleted ? const Color(0xFF006E2E) : const Color(0xFF93000A))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Điểm đến', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))),
                    Text(dropoff, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF151C27))),
                  ],
                ),
              ),
              Text(price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF151C27))),
            ],
          ),
        ],
      ),
    );
  }
}
