// ============================================================
// active_ride_screen.dart — Màn hình chuyến đi đang thực hiện (Khách hàng)
// Theo dõi vị trí tài xế realtime, hiển thị bản đồ + thông tin chuyến
// Cung cấp chức năng chat, gọi điện và hủy chuyến
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';              // Widget bản đồ flutter_map
import 'package:latlong2/latlong.dart';                     // Kiểu tọa độ LatLng
import 'package:geolocator/geolocator.dart';                // Lấy và theo dõi GPS
import 'package:supabase_flutter/supabase_flutter.dart';    // Lắng nghe realtime vị trí tài xế
import 'package:shared_preferences/shared_preferences.dart'; // Lấy thông tin session
import 'dart:async';                                        // StreamSubscription
import 'dart:convert';                                      // Decode base64
import '../../core/theme.dart';                             // Màu sắc app
import '../../services/location_service.dart';              // Lấy GPS khách hàng
import '../../services/map_service.dart';                   // Tìm đường
import 'chat_screen.dart';                                  // Màn hình chat với tài xế
import 'package:url_launcher/url_launcher.dart';          // Gọi điện thoại

class CustomerActiveRideScreen extends StatefulWidget {
  const CustomerActiveRideScreen({super.key});

  @override
  State<CustomerActiveRideScreen> createState() => _CustomerActiveRideScreenState();
}

class _CustomerActiveRideScreenState extends State<CustomerActiveRideScreen> {
  bool _isPickupPhase = true;
  String _statusText = 'Tài xế đang đến';

  // Map & GPS
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  List<LatLng> _routePoints = [];
  bool _isLoadingMap = true;
  StreamSubscription<Position>? _positionStream;

  // Vị trí tài xế
  LatLng _driverLocation = const LatLng(10.7730, 106.6960);
  RealtimeChannel? _driverLocationChannel;
  RealtimeChannel? _rideChannel;
  String? _activeDriverId;
  int? _currentRideId;

  // Thông tin chuyến
  String _pickupName = 'Điểm đón';
  String _dropoffName = 'Điểm đến';
  int _fareAmount = 0;

  // Thông tin tài xế
  String _driverName = 'Tài xế';
  String _driverLicense = 'Đang tải...';
  String _driverVehicle = '...';
  String _driverPhone = '';
  String _driverAvatar = 'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png';

  // Tọa độ thực tế
  LatLng _pickupLocation  = const LatLng(10.7769, 106.7009);
  LatLng _dropoffLocation = const LatLng(10.7942, 106.7218);

  bool _isInit = false;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _initUser();
    _initGPS();
  }

  Future<void> _initUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _userId = prefs.getString('id') ?? '');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null) {
        if (args is Map<String, dynamic>) {
          _currentRideId = args['rideId'] != null ? int.tryParse(args['rideId'].toString()) : null;
        } else if (args is int) {
          _currentRideId = args;
        }
        
        if (_currentRideId != null) {
          _loadRideAndDriverInfo(_currentRideId!);
          _subscribeToRide(_currentRideId!);
        }
      }
      _isInit = true;
    }
  }

  Future<void> _loadRideAndDriverInfo(int rideId) async {
    try {
      final ride = await Supabase.instance.client.from('rides').select().eq('id', rideId).maybeSingle();
      if (ride != null && mounted) {
        setState(() {
          final pickupStr = ride['pickup_location']?.toString() ?? '';
          final pickupParts = pickupStr.split('|');
          _pickupName = pickupParts[0].isNotEmpty ? pickupParts[0] : 'Điểm đón';
          if (pickupParts.length >= 3) {
            _pickupLocation = LatLng(double.tryParse(pickupParts[1]) ?? 10.7769, double.tryParse(pickupParts[2]) ?? 106.7009);
          }

          final dropoffStr = ride['dropoff_location']?.toString() ?? '';
          final dropoffParts = dropoffStr.split('|');
          _dropoffName = dropoffParts[0].isNotEmpty ? dropoffParts[0] : 'Điểm đến';
          if (dropoffParts.length >= 3) {
            _dropoffLocation = LatLng(double.tryParse(dropoffParts[1]) ?? 10.7942, double.tryParse(dropoffParts[2]) ?? 106.7218);
          }

          _fareAmount = int.tryParse(ride['amount'].toString()) ?? 0;
          
          if (ride['driver_id'] != null) {
            _activeDriverId = ride['driver_id'].toString();
            _subscribeDriverLocation(_activeDriverId!);
            _loadDriverProfile(_activeDriverId!);
          }
        });
        _fetchRoute();
      }
    } catch (e) {
      debugPrint('Error load ride info: $e');
    }
  }

  Future<void> _loadDriverProfile(String driverId) async {
    try {
      final user = await Supabase.instance.client.from('users').select('fullname, phone').eq('id', driverId).maybeSingle();
      final profile = await Supabase.instance.client.from('driver_profiles').select().eq('user_id', driverId).maybeSingle();
      
      if (mounted) {
        setState(() {
          if (user != null) {
            _driverName = user['fullname'] ?? 'Tài xế';
            _driverPhone = user['phone'] ?? '';
          }
          if (profile != null) {
            final model = profile['vehicle_model'] ?? '';
            final color = profile['vehicle_color'] ?? '';
            _driverVehicle = '$model $color'.trim();
            _driverLicense = profile['license_plate'] ?? '';
            if (profile['face_image'] != null) _driverAvatar = profile['face_image'];
          }
        });
      }
    } catch (e) {}
  }

  void _subscribeToRide(int rideId) {
    _rideChannel = Supabase.instance.client.channel('public:rides:id=eq.$rideId').onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'rides',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: rideId,
      ),
      callback: (payload) {
        final newRecord = payload.newRecord;
        if (newRecord.isNotEmpty && mounted) {
          final status = newRecord['status'];
          if (status == 'arrived') {
            setState(() => _statusText = 'Tài xế đã đến điểm đón');
          } else if (status == 'in_progress') {
            setState(() {
              _isPickupPhase = false;
              _statusText = 'Đang di chuyển';
            });
            _fetchRoute();
          } else if (status == 'completed') {
            _showArrivalDialog();
          } else if (status == 'cancelled') {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chuyến đi đã bị hủy!'), backgroundColor: Colors.red));
            Navigator.pushNamedAndRemoveUntil(context, '/customer/home', (r) => false);
          }
        }
      },
    ).subscribe();
  }

  void _subscribeDriverLocation(String driverId) {
    if (_currentRideId == null) return;
    
    // Hủy kênh cũ nếu có
    _driverLocationChannel?.unsubscribe();
    
    // Đăng ký nhận Broadcast từ tài xế (mỗi 3 giây)
    _driverLocationChannel = Supabase.instance.client.channel('room_ride_$_currentRideId').onBroadcast(
      event: 'location_update',
      callback: (payload) {
        if (mounted) {
          final lat = (payload['latitude'] as num?)?.toDouble();
          final lng = (payload['longitude'] as num?)?.toDouble();
          if (lat != null && lng != null) {
            setState(() {
              _driverLocation = LatLng(lat, lng);
            });
            // Tùy chọn: Ở Giai đoạn 4.2 chuyên sâu hơn, có thể dùng Tween Animation để làm mượt chuyển động của Marker
          }
        }
      },
    ).subscribe();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _driverLocationChannel?.unsubscribe();
    _rideChannel?.unsubscribe();
    super.dispose();
  }

  Future<void> _initGPS() async {
    final position = await LocationService.getCurrentLocation();
    if (position != null && mounted) {
      setState(() => _currentLocation = LatLng(position.latitude, position.longitude));
    } else {
      if (mounted) setState(() => _currentLocation = _pickupLocation);
    }
    await _fetchRoute();
    _startGPSTracking();
    if (mounted) setState(() => _isLoadingMap = false);
  }

  Future<void> _fetchRoute() async {
    final start = _isPickupPhase ? _driverLocation : _pickupLocation;
    final end = _isPickupPhase ? _pickupLocation : _dropoffLocation;
    final points = await MapService.getRoute(start, end);
    if (mounted && points.isNotEmpty) {
      setState(() => _routePoints = points);
      _fitMapToRoute();
    }
  }

  void _fitMapToRoute() {
    if (_routePoints.isEmpty) return;
    final allPoints = [..._routePoints];
    if (_currentLocation != null) allPoints.add(_currentLocation!);
    final bounds = LatLngBounds.fromPoints(allPoints);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)));
    });
  }

  void _startGPSTracking() {
    const locationSettings = LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10);
    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((position) {
      if (mounted) setState(() => _currentLocation = LatLng(position.latitude, position.longitude));
    });
  }

  void _showArrivalDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF006E2E), size: 60),
            SizedBox(height: 12),
            Text('Đã đến nơi!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Cảm ơn bạn đã sử dụng GoRide VN.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF3D4A3D))),
            const SizedBox(height: 16),
            Text('Tổng tiền: ${_fareAmount.toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')} đ', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF006E2E))),
            const SizedBox(height: 16),
            const Text('Đánh giá tài xế', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => const Icon(Icons.star_border, color: Colors.amber, size: 36))),
          ],
        ),
        actions: [
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacementNamed(context, '/customer/ride-complete', arguments: _currentRideId);
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006E2E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Đánh giá chuyến đi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        title: Row(
          children: [
            IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF151C27)), onPressed: () => Navigator.pop(context)),
            const Icon(Icons.directions_car, color: Color(0xFF006E2E), size: 20),
            const SizedBox(width: 8),
            const Text('Theo Dõi Chuyến Đi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF151C27))),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.my_location, color: Color(0xFF3D4A3D)), onPressed: () {
            if (_currentLocation != null) _mapController.move(_currentLocation!, 16);
          }),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: _isLoadingMap
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00B14F)))
                : FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(initialCenter: _currentLocation ?? _pickupLocation, initialZoom: 15.0),
                    children: [
                      TileLayer(urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}', userAgentPackageName: 'com.example.app'),
                      if (_routePoints.isNotEmpty) PolylineLayer(polylines: [Polyline(points: _routePoints, strokeWidth: 5.0, color: const Color(0xFF006E2E))]),
                      MarkerLayer(
                        markers: [
                          if (_currentLocation != null)
                            Marker(point: _currentLocation!, width: 50, height: 50, child: Container(decoration: BoxDecoration(color: const Color(0xFF006E2E), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)]), child: const Icon(Icons.person, color: Colors.white, size: 22))),
                          Marker(point: _driverLocation, width: 50, height: 50, child: Container(decoration: BoxDecoration(color: const Color(0xFF00B14F), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)]), child: const Icon(Icons.drive_eta, color: Colors.white, size: 22))),
                          Marker(point: _dropoffLocation, width: 44, height: 44, child: Container(decoration: BoxDecoration(color: const Color(0xFFBA1A1A), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)]), child: const Icon(Icons.flag, color: Colors.white, size: 20))),
                        ],
                      ),
                    ],
                  ),
          ),
          Positioned(
            top: 16, left: 16, right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)]),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF00B14F), shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_statusText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF151C27)))),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, -8))]),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 16),
                  
                  // Status Header
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: _isPickupPhase ? const Color(0xFFF0F3FF) : const Color(0xFF87FB9D).withOpacity(0.3), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF87FB9D), borderRadius: BorderRadius.circular(12)), child: Icon(_isPickupPhase ? Icons.near_me : Icons.verified_user, color: const Color(0xFF007433))),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_statusText, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF151C27))),
                                    const Text('GPS Live Tracking', style: TextStyle(fontSize: 12, color: Color(0xFF3D4A3D))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  // Driver profile
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: _isPickupPhase ? Colors.white : const Color(0xFFF9F9FF), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(radius: 24, backgroundImage: _driverAvatar.startsWith('data:image') ? MemoryImage(base64Decode(_driverAvatar.split(',')[1])) as ImageProvider : NetworkImage(_driverAvatar)),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_driverName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF151C27))),
                                Row(children: [
                                  const Icon(Icons.star, size: 14, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  const Text('4.9', style: TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  Text('${_driverVehicle.isEmpty ? "Xe" : _driverVehicle} - $_driverLicense', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF151C27)))
                                ]),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final phone = _driverPhone.isNotEmpty ? _driverPhone : '0987654321';
                                final Uri url = Uri.parse('tel:$phone');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                } else {
                                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể mở trình gọi điện')));
                                }
                              },
                              child: Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFF006E2E), shape: BoxShape.circle), child: const Icon(Icons.call, color: Colors.white, size: 20)),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                if (_currentRideId != null) {
                                  Navigator.push(context, MaterialPageRoute(builder: (ctx) => ChatScreen(
                                    rideId: _currentRideId!,
                                    currentUserId: _userId,
                                    otherName: 'Tài xế',
                                  )));
                                }
                              },
                              child: Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFFDCE2F3), shape: BoxShape.circle), child: const Icon(Icons.chat, color: Color(0xFF151C27), size: 20)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  if (_isPickupPhase) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          Container(width: 32, height: 32, decoration: BoxDecoration(color: const Color(0xFF006E2E).withOpacity(0.15), shape: BoxShape.circle), child: const Icon(Icons.location_on, color: Color(0xFF006E2E), size: 18)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('ĐIỂM ĐÓN CỦA BẠN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF006E2E))),
                                Text(_pickupName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF151C27)), maxLines: 2),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(children: [Icon(Icons.shield, color: Color(0xFF006E2E), size: 18), SizedBox(width: 6), Text('Bảo hiểm chuyến đi', style: TextStyle(fontSize: 13, color: Color(0xFF3D4A3D)))]),
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Xác nhận hủy chuyến'),
                                content: const Text('Bạn có chắc chắn muốn hủy chuyến đi này không?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Không hủy')),
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (_currentRideId != null) {
                                        await Supabase.instance.client.from('rides').update({'status': 'cancelled'}).eq('id', _currentRideId!);
                                        
                                        // Xử lý BƯỚC 3: Hoàn tiền nếu thanh toán qua Ví điện tử
                                        final payment = await Supabase.instance.client
                                            .from('ride_payments')
                                            .select('id')
                                            .eq('ride_id', _currentRideId!)
                                            .eq('status', 'HELD')
                                            .maybeSingle();

                                        if (payment != null) {
                                          await Supabase.instance.client.from('ride_payments')
                                              .update({'status': 'REFUNDED'})
                                              .eq('id', payment['id']);
                                        }
                                      }
                                      if (ctx.mounted) Navigator.pop(ctx);
                                      if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/customer/home', (route) => false);
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBA1A1A)),
                                    child: const Text('Đồng ý hủy', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text('HỦY CHUYẾN', style: TextStyle(color: Color(0xFFBA1A1A), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFF9F9FF), borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          Container(width: 32, height: 32, decoration: BoxDecoration(color: const Color(0xFFBA1A1A).withOpacity(0.15), shape: BoxShape.circle), child: const Icon(Icons.location_on, color: Color(0xFFBA1A1A), size: 18)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('ĐIỂM ĐẾN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF3D4A3D))),
                                Text(_dropoffName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF151C27)), maxLines: 2),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.emergency, color: Color(0xFFBA1A1A)), label: const Text('SOS', style: TextStyle(color: Color(0xFFBA1A1A), fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFDAD6), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
                        const SizedBox(width: 12),
                        Expanded(child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.share_location, color: Color(0xFF151C27)), label: const Text('Chia sẻ lộ trình', style: TextStyle(color: Color(0xFF151C27), fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDCE2F3), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
