// ============================================================
// active_ride_screen.dart — Màn hình Chuyến đi đang thực hiện (Tài xế)
// Theo dõi GPS tài xế realtime, gửi vị trí lên Supabase để khách theo dõi
// Tài xế xác nhận đã đón khách và hoàn thành chuyến đi
// ============================================================
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:realtime_client/src/types.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../../core/theme.dart';
import '../../services/location_service.dart';
import '../../services/map_service.dart';
import 'chat_screen.dart';

class DriverActiveRideScreen extends StatefulWidget {
  const DriverActiveRideScreen({super.key});

  @override
  State<DriverActiveRideScreen> createState() => _DriverActiveRideScreenState();
}

class _DriverActiveRideScreenState extends State<DriverActiveRideScreen> {
  bool _isDrivingToPickup = true;
  bool _hasArrived = false;

  // Map & GPS
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  List<LatLng> _routePoints = [];
  bool _isLoadingMap = true;
  StreamSubscription<Position>? _positionStream;

  // Timer push vị trí lên Supabase
  Timer? _locationPushTimer;
  RealtimeChannel? _rideChannel;
  RealtimeChannel? _broadcastChannel; // Kênh phát sóng (Pub/Sub)
  String? _driverId;

  // Dữ liệu cuốc xe từ Database
  int? _rideId;
  int _fareAmount = 0;
  String _vehicleType = '...';
  String _customerName = 'Đang tải...';
  String _pickupName = 'Đang tải...';
  String _dropoffName = 'Đang tải...';

  // Tọa độ thật của chuyến đi
  LatLng _pickupLocation  = const LatLng(10.7769, 106.7009);
  LatLng _dropoffLocation = const LatLng(10.7942, 106.7218);

  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _initDriverId();
    _initGPS();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final rideId = ModalRoute.of(context)?.settings.arguments as int?;
      if (rideId != null) {
        _rideId = rideId;
        _fetchRideDetails(rideId);
        _listenToRide(rideId);
        _setupBroadcastChannel(rideId);
      }
      _isInit = true;
    }
  }

  Future<void> _fetchRideDetails(int rideId) async {
    try {
      final data = await Supabase.instance.client.from('rides').select().eq('id', rideId).maybeSingle();
      if (data != null && mounted) {
        setState(() {
          _customerName = data['customer_name'] ?? 'Khách hàng';
          
          final pickupStr = data['pickup_location']?.toString() ?? '';
          final pickupParts = pickupStr.split('|');
          _pickupName = pickupParts[0].isNotEmpty ? pickupParts[0] : 'Điểm đón';
          if (pickupParts.length >= 3) {
            _pickupLocation = LatLng(double.tryParse(pickupParts[1]) ?? 10.7769, double.tryParse(pickupParts[2]) ?? 106.7009);
          }

          final dropoffStr = data['dropoff_location']?.toString() ?? '';
          final dropoffParts = dropoffStr.split('|');
          _dropoffName = dropoffParts[0].isNotEmpty ? dropoffParts[0] : 'Điểm đến';
          if (dropoffParts.length >= 3) {
            _dropoffLocation = LatLng(double.tryParse(dropoffParts[1]) ?? 10.7942, double.tryParse(dropoffParts[2]) ?? 106.7218);
          }

          _vehicleType = data['vehicle_type'] ?? 'Xe';
          _fareAmount = int.tryParse(data['amount'].toString()) ?? 0;
        });
        
        // Cập nhật lại tuyến đường trên bản đồ vì tọa độ đã thay đổi
        _fetchRoute();
      }
    } catch (e) {
      debugPrint('Error fetching ride details: $e');
    }
  }

  void _listenToRide(int rideId) {
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
          if (status == 'cancelled') {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Khách hàng đã hủy chuyến đi!'), backgroundColor: Colors.red));
            Navigator.pushNamedAndRemoveUntil(context, '/driver/home', (r) => false);
          }
        }
      },
    ).subscribe();
  }

  void _setupBroadcastChannel(int rideId) {
    // Khởi tạo kênh broadcast để bắn tọa độ liên tục cho App Khách
    _broadcastChannel = Supabase.instance.client.channel('room_ride_$rideId');
    _broadcastChannel!.subscribe();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _locationPushTimer?.cancel();
    _rideChannel?.unsubscribe();
    _broadcastChannel?.unsubscribe();
    super.dispose();
  }

  Future<void> _initDriverId() async {
    final prefs = await SharedPreferences.getInstance();
    _driverId = prefs.getString('id');
  }

  Future<void> _initGPS() async {
    final position = await LocationService.getCurrentLocation();
    if (position != null && mounted) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } else {
      if (mounted) setState(() => _currentLocation = const LatLng(10.7769, 106.6990));
    }

    await _fetchRoute();
    _startGPSTracking();
    _startLocationPush();

    if (mounted) setState(() => _isLoadingMap = false);
  }

  void _startLocationPush() {
    // Thay vì gọi DB (upsert), ta dùng Broadcast (WebSockets) mỗi 3 giây
    _locationPushTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (_broadcastChannel == null || _currentLocation == null) return;
      try {
        await _broadcastChannel!.send(
          type: RealtimeListenTypes.broadcast,
          event: 'location_update',
          payload: {
            'latitude': _currentLocation!.latitude,
            'longitude': _currentLocation!.longitude,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      } catch (e) {
        debugPrint('Lỗi bắn tọa độ: $e');
      }
    });
  }

  Future<void> _fetchRoute() async {
    if (_currentLocation == null) return;
    final destination = _isDrivingToPickup ? _pickupLocation : _dropoffLocation;
    final points = await MapService.getRoute(_currentLocation!, destination);
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
      if (mounted) {
        setState(() => _currentLocation = LatLng(position.latitude, position.longitude));
      }
    });
  }

  Future<void> _updateRideStatus(String status) async {
    if (_rideId == null) return;
    try {
      await Supabase.instance.client.from('rides').update({'status': status}).eq('id', _rideId!);
      
      if (status == 'completed' || status == 'cancelled') {
        if (_driverId != null) {
          await Supabase.instance.client.from('driver_locations').delete().eq('driver_id', _driverId!);
        }
      }

      // Xử lý công nợ, ví tiền và thanh toán khi hoàn thành chuyến
      if (status == 'completed' && _driverId != null && _fareAmount > 0) {
        // Lấy phương thức thanh toán của chuyến này
        final rideData = await Supabase.instance.client.from('rides').select('payment_method').eq('id', _rideId!).maybeSingle();
        final paymentMethod = rideData?['payment_method'] ?? 'Tiền mặt';

        final int commission = (_fareAmount * 0.2).round();
        
        final profile = await Supabase.instance.client
            .from('driver_profiles')
            .select('current_debt, wallet_balance')
            .eq('user_id', _driverId!)
            .maybeSingle();
            
        int currentDebt = profile?['current_debt'] ?? 0;
        int walletBalance = profile?['wallet_balance'] ?? 0;
        
        if (paymentMethod == 'Tiền mặt') {
          // BƯỚC 2 (Tiền mặt): Tài xế thu cash -> Ghi nợ 20% hoa hồng
          int newDebt = currentDebt + commission;
          await Supabase.instance.client.from('driver_profiles').update({
            'current_debt': newDebt
          }).eq('user_id', _driverId!);
          
          await Supabase.instance.client.from('wallet_transactions').insert({
            'driver_id': int.parse(_driverId!),
            'type': 'COMMISSION_FEE',
            'amount': commission,
            'description': 'Phí hoa hồng 20% chuyến #$_rideId (Tiền mặt)',
          });
        } else {
          // BƯỚC 2 (Ví điện tử): Khách đã thanh toán qua Momo/Zalo -> Công ty giữ 100%
          // -> Trả lại 80% thu nhập vào ví tài xế
          final int driverIncome = _fareAmount - commission;
          int newBalance = walletBalance + driverIncome;

          await Supabase.instance.client.from('driver_profiles').update({
            'wallet_balance': newBalance
          }).eq('user_id', _driverId!);
          
          await Supabase.instance.client.from('wallet_transactions').insert({
            'driver_id': int.parse(_driverId!),
            'type': 'RIDE_INCOME',
            'amount': driverIncome,
            'description': 'Thu nhập 80% chuyến #$_rideId ($paymentMethod)',
          });

          // Cập nhật trạng thái thanh toán từ HELD sang TRANSFERRED
          await Supabase.instance.client.from('ride_payments')
              .update({'status': 'TRANSFERRED'})
              .eq('ride_id', _rideId!);
        }
      }

      // Xử lý BƯỚC 3: Nếu tài xế hủy chuyến
      if (status == 'cancelled' && _rideId != null) {
        final payment = await Supabase.instance.client
            .from('ride_payments')
            .select('id, gateway_transaction_id')
            .eq('ride_id', _rideId!)
            .eq('status', 'HELD')
            .maybeSingle();

        if (payment != null) {
          // TODO: Trong thực tế, server của bạn sẽ gọi API Momo/Zalo để hoàn tiền cho khách.
          // Sau khi hoàn tiền thành công, đổi trạng thái thành REFUNDED.
          await Supabase.instance.client.from('ride_payments')
              .update({'status': 'REFUNDED'})
              .eq('id', payment['id']);
        }
      }
    } catch (e) {
      debugPrint('Error updating status: $e');
    }
  }

  void _handleArrived() async {
    if (!_hasArrived) {
      setState(() => _hasArrived = true);
      await _updateRideStatus('arrived');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã gửi thông báo cho khách hàng!')));
    } else {
      setState(() => _isDrivingToPickup = false);
      await _updateRideStatus('in_progress');
      await _fetchRoute();
    }
  }

  void _showCompletionModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 64, height: 64, decoration: const BoxDecoration(color: Color(0xFF87FB9D), shape: BoxShape.circle), child: const Icon(Icons.verified, size: 36, color: Color(0xFF007433))),
            const SizedBox(height: 16),
            const Text('Chuyến đi hoàn tất!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF151C27))),
            const SizedBox(height: 8),
            const Text('Cảm ơn bác tài đã đưa khách đến nơi an toàn.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Color(0xFF3D4A3D))),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tổng thu nhập', style: TextStyle(fontSize: 14, color: Color(0xFF3D4A3D))),
                  Text('${_fareAmount.toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')} đ', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF006E2E))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  await _updateRideStatus('completed');
                  if (mounted) {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/driver/home');
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã hoàn thành chuyến đi!')));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006E2E), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text('QUAY VỀ TRANG CHỦ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: _isLoadingMap
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00B14F)))
                : FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(initialCenter: _currentLocation ?? const LatLng(10.7769, 106.7009), initialZoom: 15.0),
                    children: [
                      TileLayer(urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}', userAgentPackageName: 'com.example.app'),
                      if (_routePoints.isNotEmpty) PolylineLayer(polylines: [Polyline(points: _routePoints, strokeWidth: 5.0, color: const Color(0xFF006E2E))]),
                      MarkerLayer(
                        markers: [
                          if (_currentLocation != null)
                            Marker(point: _currentLocation!, width: 50, height: 50, child: Container(decoration: BoxDecoration(color: const Color(0xFF006E2E), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)]), child: const Icon(Icons.drive_eta, color: Colors.white, size: 22))),
                          Marker(point: _pickupLocation, width: 44, height: 44, child: Container(decoration: BoxDecoration(color: const Color(0xFF00B14F), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)]), child: const Icon(Icons.person_pin_circle, color: Colors.white, size: 22))),
                          Marker(point: _dropoffLocation, width: 44, height: 44, child: Container(decoration: BoxDecoration(color: const Color(0xFFBA1A1A), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)]), child: const Icon(Icons.flag, color: Colors.white, size: 20))),
                        ],
                      ),
                    ],
                  ),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, bottom: 12, left: 16, right: 16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
                    const Icon(Icons.drive_eta, color: Color(0xFF006E2E), size: 20),
                    const SizedBox(width: 8),
                    Text(_isDrivingToPickup ? 'Đang Đón Khách' : 'Đang Di Chuyển', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF151C27))),
                  ]),
                  IconButton(icon: const Icon(Icons.my_location), onPressed: () {
                    if (_currentLocation != null) _mapController.move(_currentLocation!, 16);
                  }),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 70, left: 16, right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF2A313D).withOpacity(0.95), borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)]),
              child: Row(
                children: [
                  Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFF00B14F), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.navigation, color: Colors.white, size: 30)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_isDrivingToPickup ? 'ĐẾN ĐIỂM ĐÓN' : 'ĐẾN ĐIỂM TRẢ KHÁCH', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF71FE91))),
                        Text(_isDrivingToPickup ? _pickupName : _dropoffName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 16, bottom: _isDrivingToPickup ? 360 : 310,
            child: Column(
              children: [
                FloatingActionButton(heroTag: 'zoom_in', mini: true, backgroundColor: Colors.white, onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1), child: const Icon(Icons.add, color: Color(0xFF151C27))),
                const SizedBox(height: 8),
                FloatingActionButton(heroTag: 'zoom_out', mini: true, backgroundColor: Colors.white, onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1), child: const Icon(Icons.remove, color: Color(0xFF151C27))),
                const SizedBox(height: 8),
                FloatingActionButton(heroTag: 'fit_route', mini: true, backgroundColor: Colors.white, onPressed: _fitMapToRoute, child: const Icon(Icons.fullscreen, color: Color(0xFF151C27))),
              ],
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24)), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -10))]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 48, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)), margin: const EdgeInsets.only(bottom: 12)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFF87FB9D), borderRadius: BorderRadius.circular(16)),
                        child: Row(children: [const Icon(Icons.circle, size: 8, color: Color(0xFF00B14F)), const SizedBox(width: 8), Text(_isDrivingToPickup ? 'ĐANG ĐẾN ĐÓN KHÁCH' : 'ĐANG THỰC HIỆN CHUYẾN', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF003A15)))]),
                      ),
                      if (_isDrivingToPickup)
                        const Row(children: [Icon(Icons.gps_fixed, size: 18, color: Color(0xFF006E2E)), SizedBox(width: 4), Text('GPS Live', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF006E2E)))])
                      else
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [const Text('Giá cước', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))), Text('${_fareAmount.toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')} đ', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF006E2E)))]),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        const CircleAvatar(radius: 24, backgroundImage: NetworkImage('https://cdn-icons-png.flaticon.com/512/3135/3135715.png')),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_customerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text('Thanh toán Tiền mặt', style: const TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFFE2E8F8), shape: BoxShape.circle), child: const Icon(Icons.call, color: Color(0xFF151C27))),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                if (_rideId != null && _driverId != null) {
                                  Navigator.push(context, MaterialPageRoute(builder: (ctx) => ChatScreen(
                                    rideId: _rideId!,
                                    currentUserId: _driverId!,
                                    otherName: 'Khách hàng',
                                  )));
                                }
                              },
                              child: Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFF00B14F), shape: BoxShape.circle), child: const Icon(Icons.chat, color: Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_isDrivingToPickup) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(width: 32, height: 32, decoration: BoxDecoration(color: const Color(0xFF00B14F).withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.location_on, size: 18, color: Color(0xFF006E2E))),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('ĐIỂM ĐÓN KHÁCH', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF3D4A3D))),
                                const SizedBox(height: 4),
                                Text(_pickupName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF151C27)), maxLines: 2),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity, height: 56,
                      child: ElevatedButton(
                        onPressed: _handleArrived,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hasArrived ? const Color(0xFF006E2E) : const Color(0xFF00B14F),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_hasArrived ? Icons.done_all : Icons.where_to_vote, size: 24),
                            const SizedBox(width: 8),
                            Text(_hasArrived ? 'BẮT ĐẦU CHUYẾN' : 'ĐÃ ĐẾN ĐIỂM ĐÓN', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text('Xác nhận hủy chuyến?'),
                            content: const Text('Bạn có chắc chắn muốn hủy chuyến này không?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('QUAY LẠI')),
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.pop(ctx);
                                  await _updateRideStatus('cancelled');
                                  if (mounted) {
                                    Navigator.pushReplacementNamed(context, '/driver/home');
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã hủy chuyến xe'), backgroundColor: Color(0xFFBA1A1A)));
                                  }
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBA1A1A), foregroundColor: Colors.white),
                                child: const Text('HỦY CHUYẾN'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.cancel, color: Color(0xFFBA1A1A), size: 18),
                      label: const Text('HỦY CHUYẾN', style: TextStyle(color: Color(0xFFBA1A1A), fontWeight: FontWeight.bold)),
                    ),
                  ] else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            const SizedBox(height: 4),
                            Container(width: 12, height: 12, decoration: BoxDecoration(color: const Color(0xFFBA1A1A), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFFFDAD6), width: 3))),
                            Container(width: 2, height: 24, color: const Color(0xFFBCCBB9), margin: const EdgeInsets.symmetric(vertical: 4)),
                            const Icon(Icons.flag, size: 16, color: Color(0xFF3D4A3D)),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('ĐIỂM ĐẾN', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))),
                              const SizedBox(height: 4),
                              Text(_dropoffName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF151C27)), maxLines: 2),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(color: const Color(0xFFFFDAD6), borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.shield, color: Color(0xFF93000A), size: 24),
                              Text('SOS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF93000A))),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _showCompletionModal,
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B14F), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, size: 24), SizedBox(width: 8), Text('HOÀN THÀNH CHUYẾN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]),
                            ),
                          ),
                        ),
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
