import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapService {
  static const String _historyKey = 'search_history';

  /// Lưu địa điểm vào lịch sử
  static Future<void> saveSearchHistory(Map<String, dynamic> place) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_historyKey) ?? [];
    
    // Xóa nếu đã tồn tại để đưa lên đầu
    history.removeWhere((item) {
      final decoded = json.decode(item);
      return decoded['name'] == place['name'];
    });
    
    history.insert(0, json.encode(place));
    
    // Giữ tối đa 5 lịch sử
    if (history.length > 5) history = history.sublist(0, 5);
    
    await prefs.setStringList(_historyKey, history);
  }

  /// Đọc lịch sử tìm kiếm
  static Future<List<Map<String, dynamic>>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_historyKey) ?? [];
    return history.map((item) => json.decode(item) as Map<String, dynamic>).toList();
  }

  /// Hàm tìm kiếm địa danh dựa trên từ khóa (Geocoding)
  /// Sử dụng Nominatim API của OpenStreetMap
  static Future<List<Map<String, dynamic>>> searchAddress(String query) async {
    if (query.trim().isEmpty) return [];

    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=5&countrycodes=vn');

    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'GoRide_Flutter_App_Student_Project' // Nominatim yêu cầu User-Agent
      });

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) {
          return {
            'name': e['display_name'] ?? '',
            'lat': double.tryParse(e['lat'].toString()) ?? 0.0,
            'lon': double.tryParse(e['lon'].toString()) ?? 0.0,
          };
        }).toList();
      }
    } catch (e) {
      print('Lỗi tìm địa điểm: $e');
    }
    return [];
  }

  /// Hàm tìm đường đi ngắn nhất (Dijkstra/A* engine)
  /// Sử dụng OSRM API công khai
  static Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final url = Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson&overview=full');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final geometry = route['geometry'];
          final coordinates = geometry['coordinates'] as List;

          // OSRM trả về [longitude, latitude], FlutterMap cần LatLng(latitude, longitude)
          List<LatLng> points = coordinates.map((coord) {
            return LatLng(coord[1].toDouble(), coord[0].toDouble());
          }).toList();

          return points;
        }
      }
    } catch (e) {
      print('Lỗi tìm đường: $e');
    }
    return [];
  }
}
