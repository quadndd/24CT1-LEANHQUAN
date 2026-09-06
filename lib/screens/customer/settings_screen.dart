import 'package:flutter/material.dart';
import '../../core/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cài đặt ứng dụng', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        children: [
          _buildSectionTitle('Chung'),
          _buildSettingItem(context, Icons.language, 'Ngôn ngữ', 'Tiếng Việt / English', trailing: const Text('Tiếng Việt', style: TextStyle(color: Color(0xFF6D7B6C)))),
          _buildSettingItem(context, Icons.palette, 'Giao diện', 'Sáng / Tối / Theo hệ thống', trailing: const Text('Sáng', style: TextStyle(color: Color(0xFF6D7B6C)))),
          
          _buildSectionTitle('Thông báo & Âm thanh'),
          _buildSettingItem(context, Icons.notifications, 'Thông báo', 'Bật/tắt thông báo chuyến xe, khuyến mãi'),
          _buildSettingItem(context, Icons.volume_up, 'Âm thanh & Rung', 'Bật/tắt âm thanh và rung khi có đơn/chuyến xe'),
          
          _buildSectionTitle('Bản đồ & Vị trí'),
          _buildSettingItem(context, Icons.location_on, 'Quyền vị trí', 'Cho phép app sử dụng vị trí hiện tại'),
          _buildSettingItem(context, Icons.map, 'Tùy chỉnh bản đồ', 'Kiểu bản đồ, hiển thị vị trí, mức zoom mặc định'),
          
          _buildSectionTitle('Dữ liệu & Bộ nhớ'),
          _buildSettingItem(context, Icons.data_usage, 'Tiết kiệm dữ liệu', 'Hạn chế tải ảnh và dữ liệu bản đồ', trailing: Switch(value: false, onChanged: (v) {})),
          _buildSettingItem(context, Icons.delete_outline, 'Xóa dữ liệu tạm', 'Xóa cache của ứng dụng', onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa bộ nhớ đệm (Cache)')));
          }),
          
          _buildSectionTitle('Bảo mật & Tài khoản'),
          _buildSettingItem(context, Icons.security, 'Bảo mật', 'Face ID/vân tay, đổi mật khẩu'),
          _buildSettingItem(context, Icons.devices, 'Thiết bị & phiên đăng nhập', 'Xem các thiết bị đang đăng nhập và đăng xuất từ xa'),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF3D4A3D), letterSpacing: 1.0),
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, IconData icon, String title, String subtitle, {Widget? trailing, VoidCallback? onTap}) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap ?? () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chức năng $title đang được phát triển')));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1))),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(color: Color(0xFFE7EEFE), shape: BoxShape.circle),
                child: Icon(icon, color: const Color(0xFF006E2E), size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF151C27))),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF6D7B6C))),
                  ],
                ),
              ),
              if (trailing != null) trailing else const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
