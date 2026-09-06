import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/auth_service.dart';

class DriverPendingApprovalScreen extends StatelessWidget {
  const DriverPendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.access_time_filled, size: 80, color: Color(0xFF006E2E)),
              const SizedBox(height: 24),
              const Text(
                'Đã hoàn tất\nVui lòng chờ xác nhận thông tin',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF151C27),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Hồ sơ của bạn đang được ban quản trị xét duyệt. Quá trình này có thể mất từ 1-2 ngày làm việc. Chúng tôi sẽ thông báo cho bạn khi hoàn tất.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF3D4A3D),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    // Check status again
                    final route = await AuthService.getSavedRoute();
                    if (context.mounted) {
                      if (route == '/driver/home') {
                        Navigator.pushReplacementNamed(context, '/driver/home');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Hồ sơ vẫn đang trong quá trình xét duyệt!')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006E2E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Tải lại trạng thái', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  await AuthService.clearSession();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                child: const Text('Đăng xuất', style: TextStyle(color: Color(0xFF6D7B6C), fontWeight: FontWeight.w600)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
