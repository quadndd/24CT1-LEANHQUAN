// ============================================================
// ride_request_screen.dart — Màn hình có chuyến đi mới (Tài xế)
// Hiển thị thông tin chuyến 15 giây trước khi tự động từ chối
// Tài xế có thể chấp nhận hoặc bỏ qua chuyến
// ============================================================
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';     // Cập nhật trạng thái chuyến khi chấp nhận
import 'package:shared_preferences/shared_preferences.dart'; // Lấy driverId từ session
import '../../core/theme.dart';
import '../../widgets/real_map_widget.dart';

class RideRequestScreen extends StatefulWidget {
  const RideRequestScreen({super.key});

  @override
  State<RideRequestScreen> createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends State<RideRequestScreen> with SingleTickerProviderStateMixin {
  int _timeLeft = 15;                          // Thời gian đếm ngược (giây)
  Timer? _timer;                               // Timer đếm ngược tự từ chối
  late AnimationController _animationController; // Animation cho vòng countdown
  bool _isAccepting = false;                   // Tránh nhấn đúp nút chấp nhận

  // Dữ liệu chuyến nhận từ arguments (truyền từ driver home_screen)
  int? _rideId;
  String _pickupName = 'Điểm đón';
  String _dropoffName = 'Điểm đến';
  String _vehicleType = 'Xe';
  String _customerName = 'Khách hàng';
  String _amount = '0';
  String _distanceText = '...';
  String _etaText = '...';
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 15));
    _animationController.reverse(from: 1.0);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          timer.cancel();
          _rejectRide();
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      // Nhận dữ liệu chuyến từ driver home_screen (Map<String,dynamic>)
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        _rideId = args['id'] != null ? int.tryParse(args['id'].toString()) : null;
        _pickupName = args['pickup_location']?.toString().split('|')[0] ?? 'Điểm đón';
        _dropoffName = args['dropoff_location']?.toString().split('|')[0] ?? 'Điểm đến';
        _vehicleType = args['vehicle_type']?.toString() ?? 'Xe';
        _customerName = args['customer_name']?.toString() ?? 'Khách hàng';
        final rawAmount = args['amount'];
        if (rawAmount != null) {
          final num = int.tryParse(rawAmount.toString()) ?? 0;
          // Format giá tiền thành dạng 65.000đ
          _amount = num.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.') + 'đ';
        }
      }
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  /// Từ chối / hết giờ → quay về màn hình chờ
  void _rejectRide() {
    if (mounted) Navigator.pop(context);
  }

  /// Chấp nhận chuyến: cập nhật DB + chuyển sang active_ride_screen
  Future<void> _acceptRide() async {
    if (_isAccepting || _rideId == null) return; // Tránh nhấn 2 lần
    setState(() => _isAccepting = true);
    _timer?.cancel(); // Dừng đếm ngược ngay khi chấp nhận
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final driverId = prefs.getString('id');
      if (driverId == null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi: Không tìm thấy thông tin tài xế')));
        setState(() => _isAccepting = false);
        return;
      }

      // Cập nhật DB: đánh dấu đã có tài xế + ghi driver_id
      // Dùng .eq('status', 'pending') để chống race condition
      final updateResponse = await Supabase.instance.client.from('rides').update({
        'status': 'accepted',
        'driver_id': driverId,
      }).eq('id', _rideId!).eq('status', 'pending').select().maybeSingle();

      if (updateResponse == null) {
        throw Exception('Chuyến xe đã bị nhận bởi tài xế khác hoặc bị hủy!');
      }

      if (mounted) {
        // Truyền rideId sang active_ride_screen để tải chi tiết chuyến
        Navigator.pushReplacementNamed(
          context,
          '/driver/active-ride',
          arguments: _rideId, // int
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi chấp nhận: $e')));
        setState(() => _isAccepting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Real Map with route overlay
          const Positioned.fill(
            child: RealMapWidget(
              pickupLocation: const LatLng(10.7816, 106.6994),
              dropoffLocation: const LatLng(10.7946, 106.7219),
            ),
          ),
          
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16, right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFF2A313D).withOpacity(0.85), borderRadius: BorderRadius.circular(20)),
                  child: const Row(children: [Icon(Icons.circle, size: 8, color: Color(0xFF71FE91)), SizedBox(width: 8), Text('Hệ thống phân cuốc AI', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600))]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFF2A313D).withOpacity(0.85), borderRadius: BorderRadius.circular(20)),
                  child: const Row(children: [Icon(Icons.bolt, size: 16, color: Color(0xFF71FE91)), SizedBox(width: 4), Text('+1.3x Cao điểm', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold))]),
                ),
              ],
            ),
          ),

          // Bottom Sheet
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.65,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -10))],
              ),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Scrollable content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 48, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)), margin: const EdgeInsets.only(bottom: 8)),
                    
                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 56, height: 56,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          CircularProgressIndicator(
                                            value: _animationController.value,
                                            backgroundColor: const Color(0xFFE2E8F8),
                                            valueColor: AlwaysStoppedAnimation<Color>(_timeLeft <= 5 ? const Color(0xFFBA1A1A) : const Color(0xFF00B14F)),
                                            strokeWidth: 4.5,
                                          ),
                                          Text('$_timeLeft', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _timeLeft <= 5 ? const Color(0xFFBA1A1A) : const Color(0xFF006E2E))),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                          decoration: BoxDecoration(color: const Color(0xFF87FB9D).withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                                          child: const Row(children: [Icon(Icons.volume_up, size: 16, color: Color(0xFF007433)), SizedBox(width: 4), Text('CUỐC XE ƯU TIÊN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF007433)))]),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text('Có chuyến xe mới!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF151C27))),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('Dịch vụ', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(12)),
                                      child: const Row(children: [Icon(Icons.local_taxi, size: 16, color: Color(0xFF006E2E)), SizedBox(width: 4), Text('Car 4 Chỗ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF151C27)))]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Income
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text('THU NHẬP ƯỚC TÍNH', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF3D4A3D))),
                                      Text('65.000đ', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF00B14F))),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: const Color(0xFF71FE91).withOpacity(0.4), borderRadius: BorderRadius.circular(12)),
                                        child: const Row(children: [Icon(Icons.payments, size: 14), SizedBox(width: 4), Text('Tiền mặt', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text('Khách trả trực tiếp', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Telemetry
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(color: const Color(0xFFE7EEFE), borderRadius: BorderRadius.circular(8)),
                                    child: Row(
                                      children: [
                                        Container(width: 32, height: 32, decoration: BoxDecoration(color: const Color(0xFF00B14F).withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.near_me, size: 18, color: Color(0xFF00B14F))),
                                        const SizedBox(width: 8),
                                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Điểm đón khách', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))), Text('800m (3 phút)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF151C27)))]),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(color: const Color(0xFFE7EEFE), borderRadius: BorderRadius.circular(8)),
                                    child: Row(
                                      children: [
                                        Container(width: 32, height: 32, decoration: BoxDecoration(color: const Color(0xFFDCE2F3), shape: BoxShape.circle), child: const Icon(Icons.straighten, size: 18, color: Color(0xFF5F5E5E))),
                                        const SizedBox(width: 8),
                                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Lộ trình chuyến', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))), Text('5.2 km (14 phút)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF151C27)))]),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Timeline
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          const SizedBox(height: 4),
                                          Container(width: 14, height: 14, decoration: const BoxDecoration(color: Color(0xFF006E2E), shape: BoxShape.circle), child: Center(child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)))),
                                          Container(width: 2, height: 28, color: const Color(0xFFBCCBB9), margin: const EdgeInsets.symmetric(vertical: 4)),
                                        ],
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: const [
                                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('ĐIỂM ĐÓN (800M)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF006E2E))), Text('Bến Nghé, Q.1', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF3D4A3D)))]),
                                            SizedBox(height: 2),
                                            Text('22 Lê Duẩn, Bến Nghé, Quận 1', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF151C27)), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          const SizedBox(height: 4),
                                          Container(width: 14, height: 14, decoration: BoxDecoration(color: const Color(0xFFBA1A1A), borderRadius: BorderRadius.circular(4)), child: Center(child: Container(width: 6, height: 6, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))))),
                                        ],
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: const [
                                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('ĐIỂM ĐẾN (5.2 KM)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFBA1A1A))), Text('14 phút tới', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF3D4A3D)))]),
                                            SizedBox(height: 2),
                                            Text('Landmark 81, Vinhomes Central Park, Bình Thạnh', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF151C27)), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),

                    // Fixed buttons at bottom
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))],
                      ),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: _rejectRide,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE2E8F8),
                              foregroundColor: const Color(0xFF3D4A3D),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Row(children: [Icon(Icons.close, size: 20), SizedBox(width: 6), Text('TỪ CHỐI', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))]),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _acceptRide,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00B14F),
                                foregroundColor: Colors.white,
                                elevation: 4,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, size: 24), SizedBox(width: 8), Text('NHẬN CHUYẾN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
                            ),
                          ),
                        ],
                      ),
                    ),
                   ],
                ),
             ),
           ),
        ],
      ),
    );
  }
}
