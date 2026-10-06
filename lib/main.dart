import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';

// Khách hàng
import 'screens/customer/home_screen.dart';
import 'screens/customer/booking_screen.dart';
import 'screens/customer/vehicle_select_screen.dart';
import 'screens/customer/finding_driver_screen.dart';
import 'screens/customer/active_ride_screen.dart';
import 'screens/customer/ride_complete_screen.dart';
import 'screens/customer/trips_screen.dart';
import 'screens/customer/notifications_screen.dart';
import 'screens/customer/profile_screen.dart';
import 'screens/customer/payments_screen.dart';
import 'screens/customer/saved_locations_screen.dart';
import 'screens/customer/settings_screen.dart';

// Tài xế
import 'screens/driver/home_screen.dart';
import 'screens/driver/onboarding_screen.dart';
import 'screens/driver/pending_approval_screen.dart';
import 'screens/driver/active_ride_screen.dart';
import 'screens/driver/ride_request_screen.dart';
import 'screens/driver/profile_screen.dart';
import 'screens/driver/trip_complete_screen.dart';
import 'screens/driver/earnings_screen.dart';
import 'screens/driver/trips_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://kvdewjfidrbktwapphph.supabase.co',
    anonKey: 'sb_publishable_LSbKgmKQJpuS06wkKOIrNQ_N9oxMP9e',
  );
  
  runApp(const GoRideApp());
}

class GoRideApp extends StatelessWidget {
  const GoRideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoRide VN',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/splash': page = const SplashScreen(); break;
          case '/login': page = const LoginScreen(); break;

          // Customer
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

          // Driver
          case '/driver/onboarding': page = const DriverOnboardingScreen(); break;
          case '/driver/pending': page = const DriverPendingApprovalScreen(); break;
          case '/driver/home': page = const DriverHomeScreen(); break;
          case '/driver/ride-request': page = const RideRequestScreen(); break;
          case '/driver/active-ride': page = const DriverActiveRideScreen(); break;
          case '/driver/trip-complete': page = const DriverTripCompleteScreen(); break;
          case '/driver/earnings': page = const DriverEarningsScreen(); break;
          case '/driver/trips': page = const DriverTripsScreen(); break;
          case '/driver/profile': page = const DriverProfileScreen(); break;

          default: page = const SplashScreen(); break;
        }

        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeOutQuart;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    );
  }
}
