import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _keyIsLoggedIn = 'isLoggedIn';
  static const _keyUserRole = 'userRole';
  static const _keyUsername = 'username';
  static const _keyPhone = 'phone';
  static const _keyId = 'id';

  static const roleCustomer = 'customer';
  static const roleDriver = 'driver';
  static const roleAdmin = 'admin';

  // API Đăng nhập qua Supabase
  static Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final user = await Supabase.instance.client
          .from('users')
          .select()
          .eq('phone', phone)
          .eq('password', password)
          .maybeSingle();

      if (user != null) {
        // Lưu session
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
            "role": user['role']
          }
        };
      } else {
        return {"status": "error", "message": "Sai số điện thoại hoặc mật khẩu"};
      }
    } catch (e) {
      return {"status": "error", "message": "Lỗi kết nối Supabase: $e"};
    }
  }

  // API Đăng ký qua Supabase
  static Future<Map<String, dynamic>> register(String fullname, String phone, String password, String role) async {
    try {
      // Kiểm tra sđt tồn tại
      final existing = await Supabase.instance.client
          .from('users')
          .select()
          .eq('phone', phone)
          .maybeSingle();
          
      if (existing != null) {
        return {"status": "error", "message": "Số điện thoại đã được đăng ký"};
      }

      final response = await Supabase.instance.client
          .from('users')
          .insert({
            'fullname': fullname,
            'phone': phone,
            'password': password,
            'role': role,
          })
          .select()
          .single();

      return {"status": "success", "message": "Đăng ký thành công"};
    } catch (e) {
      return {"status": "error", "message": "Lỗi kết nối Supabase: $e"};
    }
  }

  // ─── Đọc trạng thái đăng nhập ───────────────────────────────────
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  static Future<String?> getSavedRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    if (!loggedIn) return null;

    final role = prefs.getString(_keyUserRole);
    if (role == roleCustomer) return '/customer/home';
    if (role == roleAdmin) return '/admin/dashboard';
    
    if (role == roleDriver) {
      final userId = prefs.getString(_keyId);
      if (userId == null) return '/login';
      
      try {
        final profile = await Supabase.instance.client
            .from('driver_profiles')
            .select()
            .eq('user_id', userId)
            .maybeSingle();
            
        if (profile == null) return '/driver/onboarding'; // Chưa có hồ sơ -> Cập nhật
        
        // is_approved là boolean (TRUE/FALSE)
        final isApproved = profile['is_approved'] ?? false;
        
        if (isApproved == true) {
          return '/driver/home'; // Đã duyệt
        } else {
          return '/driver/pending'; // Chưa duyệt (false)
        } 
      } catch (e) {
        // Fallback
        return '/driver/home';
      }
    }
    return null;
  }

  static Future<String?> getSavedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  static Future<String?> getSavedPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPhone);
  }

  static Future<String?> getSavedRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserRole);
  }

  // ─── Lưu phiên đăng nhập ────────────────────────────────────────
  static Future<void> saveSession({
    required String id,
    required String role,
    required String username,
    String phone = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyId, id);
    await prefs.setString(_keyUserRole, role);
    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyPhone, phone);
  }

  // ─── Xóa phiên đăng nhập (logout) ──────────────────────────────
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyId);
    await prefs.remove(_keyUserRole);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyPhone);
  }
}
