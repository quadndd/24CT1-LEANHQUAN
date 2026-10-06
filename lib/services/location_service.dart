// ============================================================
// location_service.dart — Dịch vụ lấy vị trí GPS của người dùng
// Sử dụng package geolocator để truy cập GPS của thiết bị
// ============================================================
import 'package:geolocator/geolocator.dart';

/// Lớp LocationService — cung cấp phương thức static để lấy vị trí GPS
class LocationService {
  /// Yêu cầu quyền vị trí và trả về vị trí hiện tại của thiết bị.
  /// Trả về null nếu bị từ chối quyền hoặc GPS tắt.
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Bước 1: Kiểm tra xem dịch vụ GPS có được bật trên thiết bị không
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // GPS bị tắt — có thể mở màn hình cài đặt GPS nếu muốn
      // await Geolocator.openLocationSettings();
      return null; // Trả về null vì không thể lấy vị trí
    }

    // Bước 2: Kiểm tra quyền truy cập vị trí hiện tại của app
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Bước 3: Chưa có quyền → yêu cầu người dùng cấp quyền
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Người dùng từ chối cấp quyền → không thể lấy vị trí
        return null;
      }
    }

    // Nếu người dùng đã từ chối vĩnh viễn (không cho hỏi lại)
    if (permission == LocationPermission.deniedForever) {
      // Phải hướng dẫn user vào cài đặt app để cấp quyền thủ công
      return null;
    }

    // Bước 4: Đủ điều kiện → lấy vị trí GPS hiện tại với độ chính xác cao
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high, // Độ chính xác cao (GPS thực)
    );
  }

  /// Mở màn hình cài đặt của app để người dùng cấp quyền (nếu bị từ chối vĩnh viễn)
  static Future<void> openAppSettings() async {
    await Geolocator.openAppSettings(); // Mở cài đặt ứng dụng trên hệ thống
  }
}
