// ============================================================
// register_screen.dart — Màn hình Đăng ký tài khoản
// Người dùng nhập họ tên, SĐT, mật khẩu để tạo tài khoản mới
// Sau khi đăng ký thành công → quay lại màn hình đăng nhập
// ============================================================
import 'package:flutter/material.dart';
import '../../core/theme.dart';          // Màu sắc và style
import '../../core/auth_service.dart';   // Xử lý đăng ký tài khoản

/// Màn hình đăng ký — StatefulWidget vì cần quản lý trạng thái nhập liệu
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controllers để đọc giá trị nhập từ người dùng
  final _fullnameController = TextEditingController();  // Họ và tên
  final _phoneController = TextEditingController();     // Số điện thoại
  final _passwordController = TextEditingController(); // Mật khẩu
  bool _obscurePassword = true;         // Ẩn/hiện mật khẩu (mặc định: ẩn)
  bool _isLoading = false;              // Đang gọi API đăng ký
  String _selectedRole = 'customer';   // Vai trò mặc định: khách hàng

  @override
  void dispose() {
    // Giải phóng controllers khi màn hình bị đóng (tránh memory leak)
    _fullnameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Hàm xử lý đăng ký — kiểm tra đầu vào và gọi AuthService
  Future<void> _register() async {
    // Kiểm tra tất cả trường đã được điền chưa
    if (_fullnameController.text.isEmpty || _phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return; // Dừng lại, không gọi API
    }

    setState(() => _isLoading = true); // Hiện loading indicator

    // Gọi API đăng ký với thông tin người dùng
    final result = await AuthService.register(
      _fullnameController.text,  // Họ tên
      _phoneController.text,      // SĐT
      _passwordController.text,   // Mật khẩu
      _selectedRole,              // Vai trò ('customer')
    );

    if (!mounted) return; // Widget đã bị đóng trong lúc chờ API
    setState(() => _isLoading = false); // Ẩn loading

    if (result['status'] == 'success') {
      // Đăng ký thành công → thông báo và quay lại màn hình đăng nhập
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thành công! Vui lòng đăng nhập.'), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Trở về màn hình đăng nhập
    } else {
      // Đăng ký thất bại → hiện thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Đăng ký thất bại'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Nền xám nhạt
      appBar: AppBar(
        title: const Text('Đăng ký tài khoản'),
        backgroundColor: Colors.transparent, // AppBar trong suốt
        elevation: 0,                         // Không có bóng đổ
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24), // Padding đều 24px
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Tiêu đề trang ────────────────────────────────────
              const Text(
                'Tạo tài khoản mới',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 30),

              // ── TextField Họ và tên ───────────────────────────────
              TextField(
                controller: _fullnameController,
                decoration: const InputDecoration(
                  hintText: 'Họ và tên',
                  prefixIcon: Icon(Icons.person, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 16),

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

              // ── TextField Mật khẩu với toggle ẩn/hiện ────────────
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword, // Ẩn/hiện ký tự mật khẩu
                decoration: InputDecoration(
                  hintText: 'Mật khẩu',
                  prefixIcon: const Icon(Icons.lock, color: AppColors.primary),
                  // Nút toggle ẩn/hiện mật khẩu
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Nút Đăng ký ──────────────────────────────────────
              SizedBox(
                width: double.infinity, // Chiều rộng tối đa
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register, // Vô hiệu hóa khi đang loading
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) // Loading trong nút
                    : const Text('Đăng ký'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
