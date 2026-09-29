// ============================================================
// splash_screen.dart — Màn hình chào mừng (Splash Screen)
// Hiển thị logo, loading indicator và tự động điều hướng sau 3 giây
// Kiểm tra phiên đăng nhập để chuyển đến đúng màn hình
// ============================================================
import 'package:flutter/material.dart';
import 'dart:async';                       // Dùng Timer để đếm thời gian
import '../../core/auth_service.dart';     // Kiểm tra phiên đăng nhập đã lưu

/// Màn hình Splash — hiển thị khi khởi động app
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

/// State của SplashScreen — quản lý animation và timer điều hướng
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller; // Controller cho animation (hiện tại chỉ dùng repeat)

  @override
  void initState() {
    super.initState();
    // Khởi tạo animation controller lặp vô hạn (dự phòng cho animation logo)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Sau 3 giây → kiểm tra session và điều hướng đến màn hình phù hợp
    Timer(const Duration(milliseconds: 3000), () async {
      if (!mounted) return; // Thoát nếu widget đã bị hủy
      // Lấy route đã lưu dựa trên vai trò và trạng thái tài khoản
      final savedRoute = await AuthService.getSavedRoute();
      if (!mounted) return;
      // Điều hướng thay thế (không thể quay lại splash)
      Navigator.pushReplacementNamed(
        context,
        savedRoute ?? '/login', // Nếu chưa đăng nhập → màn hình đăng nhập
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Giải phóng animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF), // Nền trắng ngà
      body: SafeArea(
        child: Stack(
          children: [
            // ── Vòng trang trí nền (góc trên phải) ──────────────────
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00B14F).withOpacity(0.1), // Xanh lá mờ
                ),
                // Needs backdrop filter for true blur, but simple opacity is fine for now
              ),
            ),
            // ── Vòng trang trí nền (góc dưới trái) ──────────────────
            Positioned(
              bottom: -100,
              left: -100,
              child: Container(
                width: 288,
                height: 288,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF87FB9D).withOpacity(0.15), // Xanh nhạt hơn
                ),
              ),
            ),
            
            Column(
              children: [
                // ── Thanh trạng thái trên cùng ───────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Badge "Hệ thống sẵn sàng" (xanh lá)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F3FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            // Chấm tròn xanh (indicator online)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF006E2E),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Hệ thống sẵn sàng',
                              style: TextStyle(
                                color: Color(0xFF006E2E),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Badge "Được bảo chứng" (icon khiên)
                      const Row(
                        children: [
                          Icon(Icons.shield, color: Color(0xFF006E2E), size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Được bảo chứng',
                            style: TextStyle(
                              color: Color(0xFF3D4A3D),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const Spacer(), // Đẩy nội dung chính ra giữa màn hình
                
                // ── Nội dung chính (Logo + Tên app + Loading) ────────
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo ứng dụng — hình tròn với bóng đổ
                    Container(
                      width: 112,
                      height: 112,
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 20,
                            offset: Offset(0, 10), // Bóng đổ xuống dưới
                          ),
                        ],
                      ),
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida/AEtjO1UadSbZ_GnbE6Q-ZKhr0EChZXzbtEbeYAW-Iwhjn4zpQ8iHYEETKVgsikXfQOjxFdBDPUje1d7j4de1TgAqJPc7aXJ5dfcu-4GxE4OsxnhV20IzJWLpYBFTtIPxzSfkiJZDkNxwjh_tNDV-Ac-3ucmooXAIaeGtIZvEx9RRXDZipVO5dt4iBc5IKGRjTPy-Hv7MlJR4Bm2sABA3beS8HfDrZOI2qipHwX9ACC3sY2IBOwYCTtkNFBWibA',
                        fit: BoxFit.contain, // Thu gọn vừa khít khung tròn
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Tên ứng dụng
                    const Text(
                      'Ứng dụng Đặt xe Flutter',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF151C27),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Slogan ngắn trong badge màu xanh nhạt
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7EEFE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF3D4A3D),
                            fontWeight: FontWeight.w400,
                          ),
                          children: [
                            TextSpan(text: 'Chuyến đi an toàn '),
                            TextSpan(text: '•', style: TextStyle(color: Color(0xFF006E2E), fontWeight: FontWeight.bold)), // Dấu chấm phân cách màu xanh
                            TextSpan(text: ' Giá cước minh bạch'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    // Vòng tròn loading — màu xanh lá GoRide
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B14F)),
                    ),
                    const SizedBox(height: 12),
                    // Text trạng thái loading
                    const Text(
                      'Đang kết nối vệ tinh định vị...',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF3D4A3D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                
                const Spacer(), // Đẩy footer xuống dưới cùng
                
                // ── Footer thông tin phiên bản ────────────────────────
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge phiên bản
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Phiên bản v2.4.0 (Flutter Engine)',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF3D4A3D),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Thông tin nhà cung cấp bản đồ
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map, color: Color(0xFF006E2E), size: 15),
                        SizedBox(width: 4),
                        Text(
                          'Vận hành bởi MapLibre Open Maps',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF5F5E5E),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
