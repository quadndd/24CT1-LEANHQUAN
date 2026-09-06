import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class RealMapWidget extends StatefulWidget {
  final bool showPulse;
  final Function(LatLng)? onLocationSelected;
  
  // Dữ liệu phục vụ việc vẽ đường
  final LatLng? pickupLocation;
  final LatLng? dropoffLocation;
  final List<LatLng>? routePoints;

  const RealMapWidget({
    super.key,
    this.showPulse = false,
    this.onLocationSelected,
    this.pickupLocation,
    this.dropoffLocation,
    this.routePoints,
  });

  @override
  State<RealMapWidget> createState() => _RealMapWidgetState();
}

class _RealMapWidgetState extends State<RealMapWidget> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  Position? currentLocation;
  bool _isLoadingLocation = true;
  String _errorMsg = '';
  
  LatLng? _selectedLocation;
  
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _initLocation();
  }

  @override
  void didUpdateWidget(covariant RealMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nếu có tuyến đường mới, tự động căn bản đồ (Fit bounds)
    if (widget.routePoints != null && widget.routePoints!.isNotEmpty && widget.routePoints != oldWidget.routePoints) {
      _fitBounds();
    }
  }

  void _fitBounds() {
    if (widget.routePoints == null || widget.routePoints!.isEmpty) return;
    
    final bounds = LatLngBounds.fromPoints(widget.routePoints!);
    
    // Đợi UI render xong rồi mới fitBounds để tránh lỗi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50.0),
        ),
      );
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    final position = await LocationService.getCurrentLocation();
    if (!mounted) return;

    // Toạ độ mặc định Việt Nam nếu lỗi
    const double vnLat = 10.7831;
    const double vnLng = 106.7006;

    if (position != null) {
      bool isEmulatorDefault = (position.latitude > 37 && position.latitude < 38) && (position.longitude < -122 && position.longitude > -123);
      final lat = isEmulatorDefault ? vnLat : position.latitude;
      final lng = isEmulatorDefault ? vnLng : position.longitude;

      setState(() {
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
        _isLoadingLocation = false;
      });
      _mapController.move(LatLng(lat, lng), 15.0);
    } else {
      setState(() {
        currentLocation = Position(
          latitude: vnLat,
          longitude: vnLng,
          timestamp: DateTime.now(),
          accuracy: 100,
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

  void _moveToCurrentLocation() {
    if (currentLocation != null) {
      _mapController.move(
        LatLng(currentLocation!.latitude, currentLocation!.longitude),
        15.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingLocation) {
      return const Center(child: CircularProgressIndicator());
    }

    final myLatLng = LatLng(currentLocation!.latitude, currentLocation!.longitude);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: myLatLng,
            initialZoom: 15.0,
            onTap: (tapPosition, point) {
              setState(() {
                _selectedLocation = point;
              });
              if (widget.onLocationSelected != null) {
                widget.onLocationSelected!(point);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
              userAgentPackageName: 'com.example.app',
            ),
            
            // 1. Vẽ đường đi nếu có
            if (widget.routePoints != null && widget.routePoints!.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: widget.routePoints!,
                    strokeWidth: 4.0,
                    color: Colors.blueAccent,
                  ),
                ],
              ),

            // 2. Vẽ Markers
            MarkerLayer(
              markers: [
                // Marker GPS hiện tại (Pulse xanh dương)
                Marker(
                  point: myLatLng,
                  width: 60,
                  height: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (widget.showPulse)
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              width: 60 * _pulseController.value,
                              height: 60 * _pulseController.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue.withOpacity(0.4 * (1 - _pulseController.value)),
                              ),
                            );
                          },
                        ),
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Marker Điểm đón (Màu xanh lá)
                if (widget.pickupLocation != null)
                  Marker(
                    point: widget.pickupLocation!,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on, color: Colors.green, size: 40),
                    alignment: Alignment.topCenter,
                  ),

                // Marker Điểm đến (Màu đỏ)
                if (widget.dropoffLocation != null)
                  Marker(
                    point: widget.dropoffLocation!,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    alignment: Alignment.topCenter,
                  ),

                // Marker do User Tự chọn tự do
                if (_selectedLocation != null && widget.dropoffLocation == null)
                  Marker(
                    point: _selectedLocation!,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_pin, color: Colors.orange, size: 40),
                    alignment: Alignment.topCenter,
                  ),
              ],
            ),
          ],
        ),
        
        // Nút bấm quay về vị trí hiện tại
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: _moveToCurrentLocation,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: const Icon(Icons.gps_fixed, color: Colors.blue, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}

