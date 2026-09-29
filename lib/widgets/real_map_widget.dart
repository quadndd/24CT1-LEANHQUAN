// ============================================================
// real_map_widget.dart — Widget bản đồ thực với OpenStreetMap
// Sử dụng flutter_map + OpenStreetMap tile (không cần API key)
// Hiển thị vị trí GPS thực, marker và tuyến đường thực từ OSRM
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';          // Widget bản đồ Flutter
import 'package:latlong2/latlong.dart';                  // Kiểu tọa độ LatLng
import 'package:geolocator/geolocator.dart';             // Lấy vị trí GPS thiết bị
import '../services/location_service.dart';              // Service xử lý quyền GPS

/// Widget bản đồ thực — hiển thị bản đồ OpenStreetMap với GPS thật
class RealMapWidget extends StatefulWidget {
  final bool showPulse;                    // Hiển thị hiệu ứng pulse (tìm tài xế)
  final bool isSelectingLocation;          // Chế độ chọn điểm đón bằng cách kéo bản đồ
  final Function(LatLng)? onLocationSelected; // Callback khi người dùng nhấn/kéo bản đồ

  // Dữ liệu phục vụ việc vẽ đường
  final LatLng? pickupLocation;            // Tọa độ điểm đón (vẽ marker xanh)
  final LatLng? dropoffLocation;           // Tọa độ điểm đến (vẽ marker đỏ)
  final List<LatLng>? routePoints;         // Danh sách điểm tạo thành tuyến đường

  const RealMapWidget({
    super.key,
    this.showPulse = false,
    this.isSelectingLocation = false,
    this.onLocationSelected,
    this.pickupLocation,
    this.dropoffLocation,
    this.routePoints,
  });

  @override
  State<RealMapWidget> createState() => _RealMapWidgetState();
}

/// State quản lý bản đồ, vị trí GPS và animation pulse
class _RealMapWidgetState extends State<RealMapWidget> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController(); // Điều khiển bản đồ (zoom, di chuyển)
  Position? currentLocation;               // Vị trí GPS hiện tại của thiết bị
  bool _isLoadingLocation = true;          // Đang tải vị trí GPS
  String _errorMsg = '';                   // Thông báo lỗi (nếu có)
  
  LatLng? _selectedLocation;              // Vị trí người dùng đã nhấn chọn trên bản đồ
  
  late AnimationController _pulseController; // Controller cho hiệu ứng pulse GPS

  @override
  void initState() {
    super.initState();
    // Khởi tạo animation pulse (lặp vô hạn, chu kỳ 2s)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    // Bắt đầu lấy vị trí GPS ngay khi widget được tạo
    _initLocation();
  }

  @override
  void didUpdateWidget(covariant RealMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nếu có tuyến đường mới được truyền vào → tự động zoom vừa khít tuyến đường
    if (widget.routePoints != null && widget.routePoints!.isNotEmpty && widget.routePoints != oldWidget.routePoints) {
      _fitBounds(); // Điều chỉnh camera để hiển thị toàn bộ tuyến đường
    }
  }

  /// Điều chỉnh camera bản đồ để vừa khít với tuyến đường hiện tại
  void _fitBounds() {
    if (widget.routePoints == null || widget.routePoints!.isEmpty) return;
    
    // Tạo hộp giới hạn (bounding box) bao phủ toàn bộ tuyến đường
    final bounds = LatLngBounds.fromPoints(widget.routePoints!);
    
    // Đợi UI render xong rồi mới gọi fitBounds (tránh lỗi gọi khi widget chưa ready)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50.0), // Thêm padding 50px mỗi cạnh để nhìn thoáng hơn
        ),
      );
    });
  }

  @override
  void dispose() {
    _pulseController.dispose(); // Giải phóng animation controller (tránh memory leak)
    super.dispose();
  }

  /// Lấy vị trí GPS hiện tại và khởi tạo bản đồ
  Future<void> _initLocation() async {
    final position = await LocationService.getCurrentLocation();
    if (!mounted) return; // Kiểm tra widget còn tồn tại không trước khi setState

    // Tọa độ mặc định TP.HCM (dùng khi GPS bị lỗi hoặc bị từ chối quyền)
    const double vnLat = 10.7831;
    const double vnLng = 106.7006;

    if (position != null) {
      // Phát hiện nếu đang chạy trên emulator Android với vị trí mặc định Mountain View, CA
      bool isEmulatorDefault = (position.latitude > 37 && position.latitude < 38) && (position.longitude < -122 && position.longitude > -123);
      // Nếu là emulator → dùng tọa độ TP.HCM thay thế
      final lat = isEmulatorDefault ? vnLat : position.latitude;
      final lng = isEmulatorDefault ? vnLng : position.longitude;

      setState(() {
        // Tạo lại Position với tọa độ đã được xử lý (emulator hoặc thực)
        currentLocation = Position(
          latitude: lat,
          longitude: lng,
          timestamp: DateTime.now(),
          accuracy: position.accuracy,
          altitude: position.altitude,
          altitudeAccuracy: position.altitudeAccuracy,
          heading: position.heading,
          headingAccuracy: position.headingAccuracy,
          speed: position.speed,
          speedAccuracy: position.speedAccuracy,
        );
        _isLoadingLocation = false; // Đã tải xong vị trí
      });
      // Di chuyển camera bản đồ đến vị trí hiện tại, zoom 15
      _mapController.move(LatLng(lat, lng), 15.0);
    } else {
      // Không lấy được GPS → dùng tọa độ mặc định TP.HCM
      setState(() {
        currentLocation = Position(
          latitude: vnLat,
          longitude: vnLng,
          timestamp: DateTime.now(),
          accuracy: 100,       // Độ chính xác thấp (fallback)
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
        _isLoadingLocation = false;
      });
      _mapController.move(LatLng(vnLat, vnLng), 15.0);
    }
  }

  /// Di chuyển camera bản đồ về vị trí GPS hiện tại khi nhấn nút GPS
  void _moveToCurrentLocation() {
    if (currentLocation != null) {
      _mapController.move(
        LatLng(currentLocation!.latitude, currentLocation!.longitude),
        15.0, // Mức zoom 15 (nhìn rõ đường phố)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hiển thị vòng tròn loading khi đang lấy GPS
    if (_isLoadingLocation) {
      return const Center(child: CircularProgressIndicator());
    }

    // Tạo tọa độ LatLng từ vị trí GPS hiện tại
    final myLatLng = LatLng(currentLocation!.latitude, currentLocation!.longitude);

    return Stack(
      children: [
        // ── FlutterMap — Widget bản đồ chính ─────────────────────
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: myLatLng,   // Tâm bản đồ ban đầu = vị trí GPS
            initialZoom: 15.0,         // Zoom ban đầu (nhìn rõ đường phố)
            // Xử lý sự kiện kéo bản đồ để ghim tọa độ
            onPositionChanged: (position, hasGesture) {
              if (widget.isSelectingLocation && hasGesture && position.center != null) {
                // Đang kéo thì không cần làm gì, chỉ khi nào thả tay ra mới gọi API hoặc update
                // Nếu muốn real-time có thể update ở đây
                if (widget.onLocationSelected != null) {
                  widget.onLocationSelected!(position.center!);
                }
              }
            },
            // Xử lý sự kiện nhấn trên bản đồ
            onTap: (tapPosition, point) {
              if (!widget.isSelectingLocation) {
                setState(() {
                  _selectedLocation = point; // Lưu vị trí được chọn
                });
                if (widget.onLocationSelected != null) {
                  widget.onLocationSelected!(point);
                }
              }
            },
          ),
          children: [
            // ── Tile Layer — Hiển thị ảnh bản đồ từ server ────────
            TileLayer(
              urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}', // Google Maps tile (không cần API key)
              userAgentPackageName: 'com.example.app', // Định danh app khi request tile
            ),
            
            // 1. Vẽ đường đi nếu có routePoints được truyền vào
            if (widget.routePoints != null && widget.routePoints!.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: widget.routePoints!, // Danh sách điểm tạo thành đường đi
                    strokeWidth: 4.0,            // Độ dày đường
                    color: Colors.blueAccent,    // Màu đường đi (xanh dương)
                  ),
                ],
              ),

            // 2. Vẽ các Marker trên bản đồ
            MarkerLayer(
              markers: [
                // ── Marker GPS hiện tại (Chấm xanh dương với hiệu ứng Pulse) ──
                Marker(
                  point: myLatLng,    // Vị trí GPS của người dùng
                  width: 60,
                  height: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Hiệu ứng pulse (vòng sóng lan ra) nếu được bật
                      if (widget.showPulse)
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              // Kích thước phình to theo animation
                              width: 60 * _pulseController.value,
                              height: 60 * _pulseController.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                // Màu mờ dần khi vòng lớn ra
                                color: Colors.blue.withOpacity(0.4 * (1 - _pulseController.value)),
                              ),
                            );
                          },
                        ),
                      // Chấm xanh trung tâm (vị trí GPS thực)
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.blue,                                   // Màu xanh GPS
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),   // Viền trắng
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // ── Marker Điểm đón (Màu xanh lá) ────────────────────
                if (widget.pickupLocation != null)
                  Marker(
                    point: widget.pickupLocation!, // Tọa độ điểm đón
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on, color: Colors.green, size: 40),
                    alignment: Alignment.topCenter, // Đỉnh marker = tọa độ điểm đón
                  ),

                // ── Marker Điểm đến (Màu đỏ) ──────────────────────────
                if (widget.dropoffLocation != null)
                  Marker(
                    point: widget.dropoffLocation!, // Tọa độ điểm đến
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    alignment: Alignment.topCenter,
                  ),

                // ── Marker do User Tự chọn (Màu cam) — chỉ hiện khi chưa có dropoff ──
                if (_selectedLocation != null && widget.dropoffLocation == null)
                  Marker(
                    point: _selectedLocation!, // Vị trí user đã tap trên bản đồ
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_pin, color: Colors.orange, size: 40),
                    alignment: Alignment.topCenter,
                  ),
              ],
            ),
          ],
        ),
        // 3. Tâm bản đồ cố định khi đang ở chế độ chọn địa điểm (Kéo thả)
        if (widget.isSelectingLocation)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40.0), // Đẩy lên một chút để đầu kim ghim đúng vào giữa
              child: Icon(Icons.location_on, size: 40, color: Color(0xFF00B14F)),
            ),
          ),
          
        // ── Nút GPS — Quay về vị trí hiện tại ───────────────────────
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: _moveToCurrentLocation, // Nhấn để căn giữa bản đồ vào GPS
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: const Icon(Icons.gps_fixed, color: Colors.blue, size: 20), // Icon GPS
            ),
          ),
        ),
      ],
    );
  }
}
