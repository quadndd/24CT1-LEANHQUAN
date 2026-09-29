// ============================================================
// login_screen.dart — Màn hình Đăng nhập (App Khách hàng)
// Cho phép người dùng nhập SĐT + mật khẩu để đăng nhập
// Sau khi đăng nhập thành công, điều hướng theo vai trò
// ============================================================
import 'package:flutter/material.dart';
import '../../core/theme.dart';              // Màu sắc và style
import '../../core/constants.dart';          // Hằng số app
import '../../core/auth_service.dart';       // Xử lý đăng nhập
import 'register_screen.dart';               // Màn hình đăng ký

/// Màn hình đăng nhập — StatefulWidget vì cần quản lý trạng thái loading và nhập liệu
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers để đọc giá trị từ các TextField
  final _phoneController = TextEditingController();     // TextField số điện thoại
  final _passwordController = TextEditingController();  // TextField mật khẩu
  bool _obscurePassword = true;   // Ẩn/hiện mật khẩu (mặc định: ẩn)
  bool _isLoading = false;        // Trạng thái đang gọi API đăng nhập

  @override
  void dispose() {
    // Giải phóng controller khi màn hình bị đóng (tránh memory leak)
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Hàm xử lý đăng nhập — gọi AuthService và điều hướng theo vai trò
  Future<void> _login() async {
    // Kiểm tra đầu vào trước khi gọi API
    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng nhập số điện thoại và mật khẩu')),
      );
      return; // Dừng lại, không gọi API
    }

    setState(() => _isLoading = true); // Hiện loading indicator

    // Gọi API đăng nhập (async)
    final result = await AuthService.login(
      _phoneController.text,
      _passwordController.text,
    );

    if (!mounted) return; // Widget đã bị đóng trong lúc chờ API

    setState(() => _isLoading = false); // Ẩn loading indicator

    if (result['status'] == 'success') {
      // Đăng nhập thành công — hiện thông báo xanh
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Đăng nhập thành công!'),
            backgroundColor: Colors.green),
      );

      final role = result['data']['role']; // Lấy vai trò từ kết quả
      // dòng chuyển qua file khi bấm đăng nhập
      if (role == 'customer') {
        // Khách hàng → vào trang chủ khách hàng
        Navigator.pushReplacementNamed(context, '/customer/home');
      } else if (role == 'driver') {
        // Tài xế đăng nhập nhầm app → thông báo dùng app tài xế
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng tải app GoRide Driver để sử dụng tính năng tài xế.'), backgroundColor: Colors.red),
        );
      } else {
        // Admin đăng nhập nhầm app → thông báo
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập bằng app Admin.'), backgroundColor: Colors.red),
        );
      }
    } else {
      // Đăng nhập thất bại — hiện thông báo lỗi đỏ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(result['message'] ?? 'Đăng nhập thất bại'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,  // Nền xám nhạt
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24), // Padding đều 24px
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40), // Khoảng trống đầu trang

              // ── Logo tròn GoRide ──────────────────────────────────
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.accentLight,   // Nền xanh nhạt
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.1), width: 2), // Viền xanh mờ
                ),
                child: const Icon(Icons.directions_car_filled,
                    color: AppColors.primary, size: 54), // Icon ô tô màu xanh
              ),

              const SizedBox(height: 24),

              // ── Tiêu đề trang ─────────────────────────────────────
              const Text(
                'Chào mừng trở lại!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Đăng nhập để bắt đầu chuyến đi của bạn',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 36),

              // ── TextField Số điện thoại ───────────────────────────
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone, // Bàn phím số điện thoại
                decoration: const InputDecoration(
                  hintText: 'Số điện thoại',
                  prefixIcon: Icon(Icons.phone, color: AppColors.primary),
                ),
              ),

              const SizedBox(height: 16),

              // ── TextField Mật khẩu ────────────────────────────────
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword, // Ẩn/hiện ký tự mật khẩu
                decoration: InputDecoration(
                  hintText: 'Mật khẩu',
                  prefixIcon: const Icon(Icons.lock, color: AppColors.primary),
                  // Nút toggle ẩn/hiện mật khẩu ở cuối TextField
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off  // Đang ẩn → icon mắt gạch
                          : Icons.visibility,     // Đang hiện → icon mắt
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword), // Toggle
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Nút Đăng nhập ─────────────────────────────────────
              SizedBox(
                width: double.infinity, // Rộng tối đa
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login, // Vô hiệu hóa khi đang loading
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2)) // Loading nhỏ trong nút
                      : const Text('Đăng nhập'),
                ),
              ),

              const SizedBox(height: 24),

              // ── Link chuyển sang trang đăng ký ───────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Chưa có tài khoản? ',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Điều hướng sang màn hình đăng ký (push, không replace)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text(
                      'Đăng ký ngay',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700, // In đậm để nổi bật
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
