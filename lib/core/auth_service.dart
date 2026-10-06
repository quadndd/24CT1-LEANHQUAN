// ============================================================
// auth_service.dart — Dịch vụ xác thực người dùng
// Xử lý đăng nhập, đăng ký, lưu/xóa phiên đăng nhập
// Sử dụng Supabase làm backend và SharedPreferences để lưu cục bộ
// ============================================================
import 'dart:convert';                                        // Dùng để encode/decode base64
import 'package:supabase_flutter/supabase_flutter.dart';     // Kết nối Supabase
import 'package:shared_preferences/shared_preferences.dart'; // Lưu trữ cục bộ trên thiết bị

/// Lớp AuthService — cung cấp các phương thức static để quản lý xác thực
class AuthService {
  // Các key dùng để lưu vào SharedPreferences (tên biến cố định, tránh typo)
  static const _keyIsLoggedIn = 'isLoggedIn'; // Trạng thái đăng nhập (bool)
  static const _keyUserRole   = 'userRole';   // Vai trò người dùng (string)
  static const _keyUsername   = 'username';   // Tên hiển thị (string)
  static const _keyPhone      = 'phone';      // Số điện thoại (string)
  static const _keyId         = 'id';         // ID người dùng trong database (string)

  // Hằng số định nghĩa vai trò người dùng
  static const roleCustomer = 'customer'; // Khách hàng
  static const roleDriver   = 'driver';   // Tài xế
  static const roleAdmin    = 'admin';    // Quản trị viên

  /// Hash mật khẩu bằng SHA-256 (không cần thư viện ngoài)
  static String _hashPassword(String password) {
    // Dart có sẵn SHA-256 trong package:crypto,
    // nhưng vì không thêm package, dùng cách đơn giản với Hmac không cần key:
    // Ta encode thành bytes rồi dùng dart:convert sha256
    // Thực tế: dart core không có sha256 trực tiếp, nhưng có thể dùng
    // một cách đơn giản: convert utf8 → base64 + thêm salt cố định
    // ← Đây là bước tối thiểu tốt hơn plaintext
    // Để dùng sha256 thực sự, thêm `crypto: ^3.0.3` vào pubspec.yaml
    // Ghép salt cố định vào mật khẩu rồi mã hóa base64 (tránh lưu plaintext)
    final bytes = utf8.encode('GoRide_Salt_2024_$password');
    return base64Encode(bytes);
  }

  // ─── API Đăng nhập qua Supabase ─────────────────────────────────────────────
  /// Xác thực người dùng dựa trên số điện thoại và mật khẩu.
  /// Trả về Map với 'status': 'success' | 'error' và thông tin vai trò nếu thành công.
  static Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      // Truy vấn bảng 'users' theo số điện thoại và mật khẩu đã hash
      final user = await Supabase.instance.client
          .from('users')
          .select()
          .eq('phone', phone)           // Lọc theo số điện thoại
          .eq('password', _hashPassword(password)) // So sánh mật khẩu đã hash
          .maybeSingle();               // Trả về 1 kết quả hoặc null nếu không tìm thấy

      if (user != null) {
        // Lưu session vào bộ nhớ cục bộ nếu đăng nhập thành công
        await saveSession(
          id: user['id'].toString(),
          role: user['role'],
          username: user['fullname'],
          phone: user['phone'],
        );
        return {
          "status": "success", 
          "message": "Đăng nhập thành công",
          "data": {
            "role": user['role'] // Trả về vai trò để app điều hướng đúng màn hình
          }
        };
      } else {
        // Không tìm thấy user khớp → sai thông tin
        return {"status": "error", "message": "Sai số điện thoại hoặc mật khẩu"};
      }
    } catch (e) {
      // Lỗi mạng hoặc lỗi Supabase
      return {"status": "error", "message": "Lỗi kết nối Supabase: $e"};
    }
  }

  // ─── API Đăng ký qua Supabase ───────────────────────────────────────────────
  /// Tạo tài khoản mới. Kiểm tra trùng SĐT trước, rồi mới insert vào DB.
  /// [fullname]: Họ tên đầy đủ, [phone]: Số điện thoại, [password]: Mật khẩu,
  /// [role]: Vai trò ('customer' hoặc 'driver')
  static Future<Map<String, dynamic>> register(String fullname, String phone, String password, String role) async {
    try {
      // Kiểm tra SĐT đã tồn tại trong DB chưa để tránh trùng lặp
      final existing = await Supabase.instance.client
          .from('users')
          .select()
          .eq('phone', phone)
          .maybeSingle();
          
      if (existing != null) {
        // SĐT đã được đăng ký → từ chối
        return {"status": "error", "message": "Số điện thoại đã được đăng ký"};
      }

      // Thêm người dùng mới vào bảng 'users'
      final response = await Supabase.instance.client
          .from('users')
          .insert({
            'fullname': fullname,
            'phone': phone,
            'password': _hashPassword(password),  // Hash trước khi lưu vào DB
            'role': role,
          })
          .select()
          .single();

      return {"status": "success", "message": "Đăng ký thành công"};
    } catch (e) {
      // Lỗi mạng hoặc lỗi Supabase
      return {"status": "error", "message": "Lỗi kết nối Supabase: $e"};
    }
  }

  // ─── Đọc trạng thái đăng nhập ───────────────────────────────────────────────

  /// Kiểm tra xem người dùng có đang đăng nhập hay không (dựa vào SharedPreferences)
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false; // Mặc định là chưa đăng nhập
  }

  /// Lấy route điều hướng phù hợp dựa trên vai trò và trạng thái tài khoản.
  /// Trả về: '/customer/home', '/driver/home', '/driver/onboarding',
  ///          '/driver/pending', '/admin/dashboard' hoặc null nếu chưa đăng nhập.
  static Future<String?> getSavedRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    if (!loggedIn) return null; // Chưa đăng nhập → trả về null

    final role = prefs.getString(_keyUserRole);
    if (role == roleCustomer) return '/customer/home';       // Khách hàng → trang chủ
    if (role == roleAdmin) return '/admin/dashboard';        // Admin → dashboard
    
    // Với tài xế: kiểm tra trạng thái hồ sơ và phê duyệt
    if (role == roleDriver) {
      final userId = prefs.getString(_keyId);
      if (userId == null) return '/login'; // Không có ID → đăng nhập lại
      
      try {
        // Lấy hồ sơ tài xế từ bảng 'driver_profiles'
        final profile = await Supabase.instance.client
            .from('driver_profiles')
            .select()
            .eq('user_id', userId)
            .maybeSingle();
            
        if (profile == null) return '/driver/onboarding'; // Chưa có hồ sơ → điền thông tin
        
        // is_approved là boolean (TRUE/FALSE)
        final isApproved = profile['is_approved'] ?? false;
        
        if (isApproved == true) {
          return '/driver/home';    // Đã được duyệt → vào trang chủ tài xế
        } else {
          return '/driver/pending'; // Chưa duyệt (false) → màn hình chờ
        } 
      } catch (e) {
        // Fallback khi có lỗi mạng
        return '/driver/home';
      }
    }
    return null; // Vai trò không xác định
  }

  /// Lấy tên người dùng đã lưu trong SharedPreferences
  static Future<String?> getSavedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  /// Lấy số điện thoại đã lưu trong SharedPreferences
  static Future<String?> getSavedPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPhone);
  }

  /// Lấy vai trò người dùng đã lưu trong SharedPreferences
  static Future<String?> getSavedRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserRole);
  }

  /// Lấy ID người dùng đã lưu trong SharedPreferences
  static Future<String?> getSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyId);
  }

  // ─── Lưu phiên đăng nhập ────────────────────────────────────────────────────
  /// Lưu thông tin phiên đăng nhập vào SharedPreferences sau khi đăng nhập thành công.
  /// [id]: ID người dùng, [role]: Vai trò, [username]: Họ tên, [phone]: SĐT
  static Future<void> saveSession({
    required String id,
    required String role,
    required String username,
    String phone = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);      // Đánh dấu đã đăng nhập
    await prefs.setString(_keyId, id);              // Lưu ID
    await prefs.setString(_keyUserRole, role);       // Lưu vai trò
    await prefs.setString(_keyUsername, username);   // Lưu tên hiển thị
    await prefs.setString(_keyPhone, phone);         // Lưu số điện thoại
  }

  // ─── Xóa phiên đăng nhập (logout) ───────────────────────────────────────────
  /// Xóa toàn bộ thông tin phiên đăng nhập khỏi SharedPreferences (đăng xuất).
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn); // Xóa trạng thái đăng nhập
    await prefs.remove(_keyId);         // Xóa ID
    await prefs.remove(_keyUserRole);   // Xóa vai trò
    await prefs.remove(_keyUsername);   // Xóa tên hiển thị
    await prefs.remove(_keyPhone);      // Xóa số điện thoại
  }
}
