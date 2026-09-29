// ============================================================
// main.dart — Điểm khởi động của ứng dụng GoRide VN (App Khách hàng)
// ============================================================
import 'package:flutter/material.dart';
import 'core/theme.dart';                               // Theme màu sắc, typography toàn app
import 'screens/splash/splash_screen.dart';             // Màn hình chào mừng (splash)
import 'screens/auth/login_screen.dart';                // Màn hình đăng nhập

// Các màn hình dành cho khách hàng
import 'screens/customer/home_screen.dart';             // Trang chủ khách hàng (có bản đồ)
import 'screens/customer/booking_screen.dart';          // Màn hình nhập điểm đón/đến
import 'screens/customer/vehicle_select_screen.dart';   // Màn hình chọn loại xe
import 'screens/customer/finding_driver_screen.dart';   // Màn hình đang tìm tài xế
import 'screens/customer/active_ride_screen.dart';      // Màn hình chuyến đi đang diễn ra
import 'screens/customer/ride_complete_screen.dart';    // Màn hình hoàn thành chuyến đi
import 'screens/customer/trips_screen.dart';            // Lịch sử chuyến đi
import 'screens/customer/notifications_screen.dart';    // Thông báo
import 'screens/customer/profile_screen.dart';          // Hồ sơ cá nhân
import 'screens/customer/payments_screen.dart';         // Thanh toán
import 'screens/customer/saved_locations_screen.dart';  // Địa điểm đã lưu
import 'screens/customer/settings_screen.dart';         // Cài đặt

import 'package:supabase_flutter/supabase_flutter.dart'; // Thư viện kết nối Supabase (DB & Auth)

/// Hàm main() — bắt buộc phải là async để khởi tạo Supabase trước khi chạy app
void main() async {
  // Đảm bảo Flutter engine được khởi tạo trước khi dùng plugin
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo kết nối Supabase với URL và anon key của project
  await Supabase.initialize(
    url: 'https://kvdewjfidrbktwapphph.supabase.co',
    anonKey: 'sb_publishable_LSbKgmKQJpuS06wkKOIrNQ_N9oxMP9e',
  );
  
  // Chạy ứng dụng Flutter
  runApp(const GoRideApp());
}

/// Widget gốc của ứng dụng — khai báo theme, route và điều hướng
class GoRideApp extends StatelessWidget {
  const GoRideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoRide VN',                          // Tên app hiển thị trên OS
      theme: AppTheme.light,                        // Áp dụng theme xanh lá tùy chỉnh
      debugShowCheckedModeBanner: false,            // Ẩn badge "DEBUG" góc phải màn hình
      initialRoute: '/splash',                      // Màn hình đầu tiên khi khởi động
      // onGenerateRoute: Xử lý điều hướng với hiệu ứng chuyển màn hình tùy chỉnh
      onGenerateRoute: (settings) {
        Widget page;
        // Lấy Widget tương ứng với tên route được yêu cầu
        switch (settings.name) {
          case '/splash': page = const SplashScreen(); break;      // Màn hình splash
          case '/login': page = const LoginScreen(); break;        // Đăng nhập

          // Các route của khách hàng
          case '/customer/home': page = const CustomerHomeScreen(); break;
          case '/customer/booking': page = const BookingScreen(); break;
          case '/customer/vehicle-select': page = const VehicleSelectScreen(); break;
          case '/customer/finding-driver': page = const FindingDriverScreen(); break;
          case '/customer/active-ride': page = const CustomerActiveRideScreen(); break;
          case '/customer/ride-complete': page = const RideCompleteScreen(); break;
          case '/customer/trips': page = const CustomerTripsScreen(); break;
          case '/customer/notifications': page = const CustomerNotificationsScreen(); break;
          case '/customer/profile': page = const CustomerProfileScreen(); break;
          case '/customer/payments': page = const CustomerPaymentsScreen(); break;
          case '/customer/saved-locations': page = const CustomerSavedLocationsScreen(); break;
          case '/customer/settings': page = const SettingsScreen(); break;

          // Nếu route không tồn tại → về splash
          default: page = const SplashScreen(); break;
        }

        // Dùng PageRouteBuilder để thêm hiệu ứng chuyển màn hình tùy chỉnh
        return PageRouteBuilder(
          settings: settings,
          // pageBuilder: trả về widget màn hình cần hiển thị
          pageBuilder: (context, animation, secondaryAnimation) => page,
          // transitionsBuilder: định nghĩa hiệu ứng animation chuyển màn hình
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Hiệu ứng trượt từ phải sang trái khi mở màn hình mới
            const begin = Offset(1.0, 0.0);         // Bắt đầu từ bên phải
            const end = Offset.zero;                 // Kết thúc ở vị trí bình thường
            const curve = Curves.easeOutQuart;       // Đường cong animation mượt mà
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
          transitionDuration: const Duration(milliseconds: 300), // Thời gian chuyển màn hình
        );
      },
    );
  }
}
