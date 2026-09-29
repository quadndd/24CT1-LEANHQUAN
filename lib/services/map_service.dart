// ============================================================
// map_service.dart — Dịch vụ bản đồ và tính toán giá cước
// Bao gồm: Tìm kiếm địa chỉ (Nominatim), tìm đường (OSRM),
//          lưu lịch sử tìm kiếm và tính cước phí GoRide VN
// ============================================================
import 'dart:convert';                              // Dùng để encode/decode JSON
import 'dart:math' as math;                         // Toán học (Haversine)
import 'package:flutter/foundation.dart';           // Dùng debugPrint
import 'package:http/http.dart' as http;            // HTTP request đến API bên ngoài
import 'package:latlong2/latlong.dart';             // Kiểu tọa độ LatLng
import 'package:shared_preferences/shared_preferences.dart'; // Lưu lịch sử tìm kiếm cục bộ

/// Lớp MapService — cung cấp các tính năng bản đồ và tìm kiếm địa điểm
class MapService {
  // Key để lưu lịch sử tìm kiếm vào SharedPreferences
  static const String _historyKey = 'search_history';

  // ─── Lịch sử tìm kiếm ───────────────────────────────────────────────────────

  /// Lưu một địa điểm vào lịch sử tìm kiếm (tối đa 5 địa điểm gần nhất).
  /// Nếu địa điểm đã tồn tại, nó sẽ được đưa lên đầu danh sách.
  static Future<void> saveSearchHistory(Map<String, dynamic> place) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_historyKey) ?? [];

    // Xóa bản ghi cũ nếu địa điểm đã tồn tại trong lịch sử (để đưa lên đầu)
    history.removeWhere((item) {
      final decoded = json.decode(item);
      return decoded['name'] == place['name']; // So sánh theo tên địa điểm
    });

    // Thêm địa điểm mới nhất vào đầu danh sách
    history.insert(0, json.encode(place));

    // Giới hạn lịch sử tối đa 5 địa điểm
    if (history.length > 5) history = history.sublist(0, 5);

    // Lưu lại vào SharedPreferences
    await prefs.setStringList(_historyKey, history);
  }

  /// Đọc danh sách lịch sử tìm kiếm từ SharedPreferences.
  /// Trả về danh sách rỗng nếu chưa có lịch sử.
  static Future<List<Map<String, dynamic>>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_historyKey) ?? [];
    // Decode từng chuỗi JSON thành Map
    return history.map((item) => json.decode(item) as Map<String, dynamic>).toList();
  }

  // ─── Tính khoảng cách đường chim bay (Haversine) ────────────────────────────
  
  static double calculateDistance(LatLng start, LatLng end) {
    const double earthRadiusKm = 6371.0;
    var dLat = _degreesToRadians(end.latitude - start.latitude);
    var dLon = _degreesToRadians(end.longitude - start.longitude);
    var lat1 = _degreesToRadians(start.latitude);
    var lat2 = _degreesToRadians(end.latitude);

    var a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) * math.sin(dLon / 2) * math.cos(lat1) * math.cos(lat2);
    var c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  // ─── Tìm kiếm địa chỉ ───────────────────────────────────────────────────────

  /// Tìm kiếm địa danh theo từ khóa bằng OpenStreetMap (Nominatim API).
  /// Dùng Nominatim thay vì Google Maps để tránh cần API key.
  /// [query]: Từ khóa tìm kiếm, [nearLocation]: Ưu tiên kết quả gần vị trí này.
  static Future<List<Map<String, dynamic>>> searchAddress(String query, {LatLng? nearLocation}) async {
    if (query.trim().isEmpty) return []; // Không tìm nếu query rỗng

    // Sử dụng Nominatim API — miễn phí, không cần API key
    // countrycodes=vn: Giới hạn kết quả trong Việt Nam
    String url = 'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=5&countrycodes=vn';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'cnpm_24ct1_leanhquan/1.0', // Bắt buộc cho Nominatim — identify app
          'Accept-Language': 'vi-VN,vi;q=0.9',      // Ưu tiên kết quả tiếng Việt
        }
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((e) {
          String fullName = e['display_name'] ?? '';
          // Bỏ phần ", Việt Nam" ở cuối để hiển thị gọn hơn
          fullName = fullName.replaceAll(', Việt Nam', '').replaceAll(', Vietnam', '');
          // Cắt bớt nếu tên quá dài (hơn 80 ký tự)
          if (fullName.length > 80) fullName = '${fullName.substring(0, 80)}...';
          
          double lat = double.tryParse(e['lat'].toString()) ?? 0.0;
          double lon = double.tryParse(e['lon'].toString()) ?? 0.0;
          double distance = 0.0;
          if (nearLocation != null) {
            distance = calculateDistance(nearLocation, LatLng(lat, lon));
          }
          
          return {
            'name': fullName,
            'lat': lat, // Vĩ độ
            'lon': lon, // Kinh độ
            'distance': distance, // Khoảng cách (km)
          };
        }).toList();
      }
    } catch (e) {
      debugPrint('Lỗi tìm kiếm Nominatim: $e'); // Log lỗi để debug
    }

    return []; // Trả về rỗng nếu có lỗi
  }

  /// Dịch ngược tọa độ thành tên đường (Reverse Geocoding) bằng Nominatim
  static Future<String> reverseGeocode(LatLng location) async {
    String url = 'https://nominatim.openstreetmap.org/reverse?lat=${location.latitude}&lon=${location.longitude}&format=json&addressdetails=1&accept-language=vi-VN';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'cnpm_24ct1_leanhquan/1.0',
        }
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String name = data['display_name'] ?? 'Vị trí ghim trên bản đồ';
        name = name.replaceAll(', Việt Nam', '').replaceAll(', Vietnam', '');
        if (name.length > 80) name = '${name.substring(0, 80)}...';
        return name;
      }
    } catch (e) {
      debugPrint('Lỗi Reverse Geocoding: $e');
    }
    return 'Vị trí ghim trên bản đồ';
  }

  /// Xử lý kết quả trả về từ Google Places API (không dùng hiện tại, để dự phòng)
  static List<Map<String, dynamic>> _parseGoogleResults(List data) {
    return data.take(5).map((e) {
      String name = e['name'] ?? '';
      String address = e['formatted_address'] ?? '';
      
      // Ghép tên và địa chỉ để hiển thị đẹp hơn
      String fullName = name;
      if (address.isNotEmpty && !address.startsWith(name)) {
        fullName = '$name, $address';   // Tên + địa chỉ
      } else if (address.isNotEmpty) {
        fullName = address;             // Chỉ địa chỉ nếu đã bao gồm tên
      }
      fullName = fullName.replaceAll(', Việt Nam', '').replaceAll(', Vietnam', '');
      
      // Cắt bớt nếu quá dài
      if (fullName.length > 80) fullName = '${fullName.substring(0, 80)}...';
      
      return {
        'name': fullName,
        'lat': e['geometry']?['location']?['lat'] ?? 0.0, // Vĩ độ từ Google
        'lon': e['geometry']?['location']?['lng'] ?? 0.0, // Kinh độ từ Google
      };
    }).toList();
  }

  // ─── Tìm đường ──────────────────────────────────────────────────────────────

  /// Tìm tuyến đường từ [start] đến [end] và trả về danh sách điểm tọa độ.
  /// Phiên bản đơn giản — backward compatible với code cũ.
  static Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final result = await getRouteWithInfo(start, end);
    return result?.points ?? []; // Trả về [] nếu không tìm được đường
  }

  /// Tìm tuyến đường có đầy đủ thông tin: tọa độ các điểm + khoảng cách + thời gian.
  /// Sử dụng OSRM (Open Source Routing Machine) — miễn phí, không cần API key.
  /// Trả về [RouteResult] hoặc null nếu không tìm được đường.
  static Future<RouteResult?> getRouteWithInfo(LatLng start, LatLng end) async {
    // Gọi OSRM API với tọa độ lon,lat (chú ý: OSRM dùng kinh độ trước vĩ độ)
    final url = Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson&overview=full');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Kiểm tra có kết quả tuyến đường không
        if (data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0]; // Lấy tuyến đường đầu tiên (ngắn nhất)
          final coordinates = route['geometry']['coordinates'] as List;

          // OSRM trả về [longitude, latitude] → phải đổi thành LatLng(latitude, longitude)
          final points = coordinates
              .map((coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
              .toList();

          // Tính khoảng cách (m → km) và thời gian (s → phút, làm tròn lên)
          final distanceKm = (route['distance'] as num).toDouble() / 1000.0;
          final durationMin = ((route['duration'] as num).toDouble() / 60.0).ceil();

          return RouteResult(
            points: points,
            distanceKm: distanceKm,
            durationMin: durationMin,
          );
        }
      }
    } catch (e) {
      debugPrint('Lỗi tìm đường: $e'); // Log lỗi để debug
    }
    return null; // Không tìm được đường
  }
}



// ─────────────────────────────────────────────────────────────────────────────
// Model kết quả tìm đường
// ─────────────────────────────────────────────────────────────────────────────

/// Model chứa thông tin tuyến đường trả về từ OSRM
class RouteResult {
  final List<LatLng> points;  // Danh sách tọa độ các điểm trên tuyến đường
  final double distanceKm;    // Tổng khoảng cách (km)
  final int durationMin;      // Thời gian ước tính (phút, làm tròn lên)

  const RouteResult({
    required this.points,
    required this.distanceKm,
    required this.durationMin,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Bộ tính giá cước GoRide VN
// ─────────────────────────────────────────────────────────────────────────────

/// Lớp tính toán giá cước dựa trên loại xe, khoảng cách và giờ cao điểm
class FareCalculator {
  // ── Cước mở cửa (flag fall) — tính ngay khi lên xe ─────────
  static const int _baseFareBike    = 10000;  // Xe máy: 10.000đ
  static const int _baseFareCar4    = 15000;  // Ô tô 4 chỗ: 15.000đ
  static const int _baseFarePremium = 20000;  // Xe cao cấp: 20.000đ

  // ── Giá theo km ──────────────────────────────────────────────
  static const double _perKmBike    = 4500.0;   // Xe máy: 4.500đ/km
  static const double _perKmCar4    = 9000.0;   // Ô tô 4 chỗ: 9.000đ/km
  static const double _perKmPremium = 15000.0;  // Xe cao cấp: 15.000đ/km

  // ── Hệ số giờ cao điểm ───────────────────────────────────────
  static const double _peakMultiplier = 1.5; // Nhân x1.5 trong giờ cao điểm

  /// Kiểm tra có đang trong giờ cao điểm hay không.
  /// Giờ cao điểm: 7–9h sáng (đi làm) hoặc 17–20h chiều (tan làm).
  /// [now]: Thời điểm cần kiểm tra, mặc định là thời gian hiện tại.
  static bool isPeakHour([DateTime? now]) {
    final h = (now ?? DateTime.now()).hour; // Lấy giờ hiện tại
    return (h >= 7 && h < 9) || (h >= 17 && h < 20); // Khung giờ cao điểm
  }

  /// Tính giá cước dựa trên loại xe và khoảng cách thực tế từ OSRM.
  /// [vehicleId]: 'bike' | 'car4' | 'premium'
  /// [distanceKm]: Khoảng cách thực (km) lấy từ MapService
  /// Trả về Map với: {'amount': int, 'isPeak': bool, 'distanceKm': double}
  static Map<String, dynamic> calculate(String vehicleId, double distanceKm) {
    final peak = isPeakHour(); // Kiểm tra giờ cao điểm

    // Chọn cước mở cửa và giá/km theo loại xe
    int baseFare;
    double perKm;
    switch (vehicleId) {
      case 'bike':    // Xe máy
        baseFare = _baseFareBike;
        perKm = _perKmBike;
        break;
      case 'premium': // Xe cao cấp
        baseFare = _baseFarePremium;
        perKm = _perKmPremium;
        break;
      default:        // Ô tô 4 chỗ (mặc định)
        baseFare = _baseFareCar4;
        perKm = _perKmCar4;
    }

    // Tính tổng cước = cước mở cửa + (giá/km × khoảng cách)
    double raw = baseFare + (perKm * distanceKm);
    // Nhân hệ số cao điểm nếu đang trong giờ cao điểm
    if (peak) raw *= _peakMultiplier;

    // Làm tròn lên đến 1.000đ gần nhất (đơn vị tiền Việt Nam)
    final int amount = ((raw / 1000).ceil()) * 1000;

    return {
      'amount': amount,           // Tổng cước đã làm tròn (VND)
      'isPeak': peak,             // Có phải giờ cao điểm không
      'distanceKm': distanceKm,  // Khoảng cách thực (km)
    };
  }

  /// Định dạng số tiền VND có dấu chấm phân cách hàng nghìn.
  /// Ví dụ: 65000 → "65.000 đ"
  static String formatVND(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} đ';
  }
}
