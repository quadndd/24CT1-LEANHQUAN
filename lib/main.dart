import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';

// Customer screens
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

// Driver screens
import 'screens/driver/home_screen.dart';
import 'screens/driver/onboarding_screen.dart';
import 'screens/driver/pending_approval_screen.dart';
import 'screens/driver/active_ride_screen.dart';
import 'screens/driver/ride_request_screen.dart';
import 'screens/driver/profile_screen.dart';
import 'screens/driver/trip_complete_screen.dart';
import 'screens/driver/earnings_screen.dart';
import 'screens/driver/trips_screen.dart';

// Admin screens
import 'screens/admin/dashboard_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

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
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),

        // ────────────────────────────────────
        // Luồng KHÁCH HÀNG (Customer)
        // ────────────────────────────────────
        '/customer/home': (context) => const CustomerHomeScreen(),
        '/customer/booking': (context) => const BookingScreen(),
        '/customer/vehicle-select': (context) => const VehicleSelectScreen(),
        '/customer/finding-driver': (context) => const FindingDriverScreen(),
        '/customer/active-ride': (context) => const CustomerActiveRideScreen(),
        '/customer/ride-complete': (context) => const RideCompleteScreen(),
        '/customer/trips': (context) => const CustomerTripsScreen(),
        '/customer/notifications': (context) => const CustomerNotificationsScreen(),
        '/customer/profile': (context) => const CustomerProfileScreen(),
        '/customer/payments': (context) => const CustomerPaymentsScreen(),
        '/customer/saved-locations': (context) => const CustomerSavedLocationsScreen(),
        '/customer/settings': (context) => const SettingsScreen(),

        // ────────────────────────────────────
        // Luồng TÀI XẾ (Driver)
        // ────────────────────────────────────
        '/driver/onboarding': (context) => const DriverOnboardingScreen(),
        '/driver/pending': (context) => const DriverPendingApprovalScreen(),
        '/driver/home': (context) => const DriverHomeScreen(),
        '/driver/ride-request': (context) => const RideRequestScreen(),
        '/driver/active-ride': (context) => const DriverActiveRideScreen(),
        '/driver/trip-complete': (context) => const DriverTripCompleteScreen(),
        '/driver/earnings': (context) => const DriverEarningsScreen(),
        '/driver/trips': (context) => const DriverTripsScreen(),
        '/driver/profile': (context) => const DriverProfileScreen(),

        // ────────────────────────────────────
        // Luồng ADMIN
        // ────────────────────────────────────
        '/admin/dashboard': (context) => const AdminDashboardScreen(),
      },
    );
  }
}
