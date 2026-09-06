import 'package:flutter/material.dart';
import '../../core/theme.dart';

class CustomerSavedLocationsScreen extends StatelessWidget {
  const CustomerSavedLocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Địa điểm đã lưu', style: TextStyle(color: Color(0xFF151C27), fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF151C27)),
        actions: [
          IconButton(icon: const Icon(Icons.add, color: Color(0xFF00B14F)), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLocationItem(Icons.home, 'Nhà riêng', '123 Đường A, Quận 1, TP.HCM'),
          const Divider(),
          _buildLocationItem(Icons.work, 'Cơ quan', 'Tòa nhà B, Quận 3, TP.HCM'),
          const Divider(),
          _buildLocationItem(Icons.favorite, 'Quán cafe quen', '456 Đường C, Quận 10, TP.HCM'),
        ],
      ),
    );
  }

  Widget _buildLocationItem(IconData icon, String title, String address) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(20)),
        child: Icon(icon, color: const Color(0xFF006E2E)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(address, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.more_vert, color: Colors.grey),
    );
  }
}
