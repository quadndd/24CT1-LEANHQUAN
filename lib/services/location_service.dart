import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Hàm yêu cầu quyền vị trí và trả về vị trí hiện tại.
  /// Trả về null nếu bị từ chối quyền hoặc GPS tắt.
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Kiểm tra xem GPS có bật không
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Có thể mở cài đặt GPS nếu muốn
      // await Geolocator.openLocationSettings();
      return null;
    }

    // 2. Kiểm tra quyền
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // 3. Xin quyền nếu chưa có
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Người dùng từ chối
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Người dùng từ chối vĩnh viễn
      return null;
    }

    // 4. Nếu đủ điều kiện, trả về vị trí hiện tại
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high, // Độ chính xác cao
    );
  }

  /// Mở màn hình cài đặt của app để người dùng cấp quyền (nếu bị từ chối vĩnh viễn)
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
