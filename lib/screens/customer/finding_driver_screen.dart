// ============================================================
// finding_driver_screen.dart — Màn hình đang tìm tài xế
// Lắng nghe realtime từ Supabase: khi tài xế chấp nhận chuyến
// → tự động điều hướng sang màn hình active_ride
// ============================================================
import 'package:flutter/material.dart';
import 'dart:async';                                         // Dùng Timer đếm giây
import 'package:supabase_flutter/supabase_flutter.dart';    // Realtime listener
import '../../core/theme.dart';                             // Màu sắc app
import '../../widgets/real_map_widget.dart';                // Bản đồ với hiệu ứng pulse

/// Màn hình chờ tài xế chấp nhận chuyến đi
class FindingDriverScreen extends StatefulWidget {
  const FindingDriverScreen({super.key});

  @override
  State<FindingDriverScreen> createState() => _FindingDriverScreenState();
}

/// State quản lý timer, realtime listener và hiệu ứng animation
class _FindingDriverScreenState extends State<FindingDriverScreen> with TickerProviderStateMixin {
  int _seconds = 0;                // Số giây đã chờ
  double _progress = 0;            // Tiến trình thanh loading (0.0 → 1.0)
  Timer? _timer;                   // Timer đếm giây
  late AnimationController _pulseController; // Controller cho hiệu ứng pulse bản đồ
  RealtimeChannel? _rideChannel;   // Kênh lắng nghe realtime Supabase cho chuyến đi
  Map<String, dynamic>? _rideData; // Dữ liệu chuyến đi từ DB (args hoặc realtime)
  bool _isInit = false;            // Đã khởi tạo dữ liệu chưa (tránh lặp)
  String _statusTitle = 'Đang tìm tài xế...';           // Tiêu đề trạng thái
  String _statusSub = 'Đã thông báo cho các tài xế gần bạn'; // Mô tả trạng thái
  bool _isDriverFound = false;     // Đã tìm được tài xế chưa

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['rideId'] != null) {
        final rideId = int.tryParse(args['rideId'].toString()) ?? 0;
        if (rideId > 0) {
          _listenToRide(rideId);
          _fetchRideDetails(rideId);
        }
      }
      _isInit = true;
    }
  }

  Future<void> _fetchRideDetails(int rideId) async {
    try {
      final data = await Supabase.instance.client.from('rides').select().eq('id', rideId).maybeSingle();
      if (data != null && mounted) {
        setState(() {
          _rideData = data;
        });
      }
    } catch (e) {
      debugPrint('Error fetching ride: $e');
    }
  }

  void _listenToRide(int rideId) {
    _rideChannel = Supabase.instance.client
        .channel('public:rides:id=eq.$rideId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'rides',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: rideId,
          ),
          callback: (payload) async {
            final newRecord = payload.newRecord;
            if (newRecord.isNotEmpty && newRecord['status'] == 'accepted') {
              _timer?.cancel();
              _rideChannel?.unsubscribe();
              if (mounted) {
                String driverName = 'Một tài xế';
                if (newRecord['driver_id'] != null) {
                  try {
                    final userRecord = await Supabase.instance.client.from('users').select('fullname').eq('id', newRecord['driver_id']).maybeSingle();
                    if (userRecord != null && userRecord['fullname'] != null) {
                      driverName = userRecord['fullname'];
                    }
                  } catch(e) {}
                }
                
                setState(() {
                  _statusTitle = 'Đã tìm thấy tài xế!';
                  _statusSub = 'Tài xế $driverName đang đến đón bạn';
                  _isDriverFound = true;
                });
                
                await Future.delayed(const Duration(seconds: 2));

                if (mounted) {
                  final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                  Navigator.pushReplacementNamed(
                    context,
                    '/customer/active-ride',
                    arguments: args,
                  );
                }
              }
            }
          },
        )
        .subscribe();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (mounted) {
        setState(() {
          _seconds++;
          _progress = _seconds / 60.0;
        });
        if (_seconds >= 60) {
          timer.cancel();
          _rideChannel?.unsubscribe();
          if (_rideData != null) {
            await Supabase.instance.client.from('rides').update({'status': 'cancelled'}).eq('id', _rideData!['id']).eq('status', 'pending');
          }
          if (mounted) {
            showDialog(
              context: context, 
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                title: const Text('Rất tiếc'),
                content: const Text('Hiện không có tài xế nào nhận chuyến. Vui lòng thử lại sau.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    }, 
                    child: const Text('ĐÓNG')
                  )
                ],
              )
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _rideChannel?.unsubscribe();
    _pulseController.dispose();
    super.dispose();
  }

  String get _timerText {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    String pickupName = _rideData?['pickup_location']?.toString().split('|')[0] ?? 'Đang tải...';
    String dropoffName = _rideData?['dropoff_location']?.toString().split('|')[0] ?? 'Đang tải...';
    String price = _rideData != null ? '${_rideData!['amount'].toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')} đ' : '...';

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        _timer?.cancel();
        _rideChannel?.unsubscribe();
        if (_rideData != null) {
          await Supabase.instance.client.from('rides').update({'status': 'cancelled'}).eq('id', _rideData!['id']).eq('status', 'pending');
        }
        if (context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: const RealMapWidget(),
                ),
                Positioned.fill(child: Container(color: Colors.white.withOpacity(0.5))),
                
                // Pulse Animation
                Center(
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(width: 80 + (_pulseController.value * 80), height: 80 + (_pulseController.value * 80), decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF00B14F).withOpacity(1 - _pulseController.value))),
                          Container(width: 60 + (_pulseController.value * 60), height: 60 + (_pulseController.value * 60), decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF00B14F).withOpacity((1 - _pulseController.value) * 0.5))),
                          Container(width: 80, height: 80, decoration: BoxDecoration(color: const Color(0xFF00B14F), shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFF006E2E).withOpacity(0.5), blurRadius: 16)]), child: const Icon(Icons.search, color: Colors.white, size: 36)),
                        ],
                      );
                    },
                  ),
                ),

                Positioned(
                  top: 50, left: 16, right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 16)]),
                    child: Row(
                      children: [
                        const Icon(Icons.radar, color: Color(0xFF00B14F)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_statusTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF151C27))),
                              Text(_statusSub, style: const TextStyle(fontSize: 13, color: Color(0xFF3D4A3D))),
                            ],
                          ),
                        ),
                        if (!_isDriverFound)
                          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(20)), child: Text(_timerText, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006E2E))))
                        else
                          const CircularProgressIndicator(color: Color(0xFF00B14F)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, -4))]),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Tiến trình tìm xe', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    Text('${(_progress * 100).toInt()}%', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF006E2E))),
                  ]),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: _progress, backgroundColor: const Color(0xFFE7EEFE), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00B14F)), minHeight: 8),
                  ),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
                    Text('Mở rộng bán kính', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))),
                    Text('Tăng giá (+5k)', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))),
                  ]),
                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(10)),
                    child: Column(children: [
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(width: 24, height: 24, decoration: const BoxDecoration(color: Color(0xFF00B14F), shape: BoxShape.circle), child: const Icon(Icons.trip_origin, size: 14, color: Colors.white)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('ĐIỂM ĐÓN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF3D4A3D), letterSpacing: 0.8)),
                          Text(pickupName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
                        ])),
                      ]),
                      const SizedBox(height: 10),
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(width: 24, height: 24, decoration: const BoxDecoration(color: Color(0xFFBA1A1A), shape: BoxShape.circle), child: const Icon(Icons.location_on, size: 14, color: Colors.white)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('ĐIỂM ĐẾN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF3D4A3D), letterSpacing: 0.8)),
                          Text(dropoffName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
                        ])),
                      ]),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFE7EEFE), borderRadius: BorderRadius.circular(8)),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Row(children: [
                            Container(width: 36, height: 36, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.local_taxi, color: Color(0xFF006E2E), size: 20)),
                            const SizedBox(width: 10),
                            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('GoRide', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                              Text('Giá cước cố định', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))),
                            ]),
                          ]),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Text(price, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006E2E))),
                            Row(children: [
                              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF006D2F), shape: BoxShape.circle)),
                              const SizedBox(width: 4),
                              const Text('Voucher', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))),
                            ]),
                          ]),
                        ]),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity, height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        _timer?.cancel();
                        _rideChannel?.unsubscribe();
                        if (_rideData != null) {
                           await Supabase.instance.client.from('rides').update({'status': 'cancelled'}).eq('id', _rideData!['id']).eq('status', 'pending');
                           
                           // Hoàn tiền nếu khách hủy khi đang tìm tài xế
                           final payment = await Supabase.instance.client
                               .from('ride_payments')
                               .select('id')
                               .eq('ride_id', _rideData!['id'])
                               .eq('status', 'HELD')
                               .maybeSingle();

                           if (payment != null) {
                             await Supabase.instance.client.from('ride_payments')
                                 .update({'status': 'REFUNDED'})
                                 .eq('id', payment['id']);
                           }
                        }
                        if (mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFDAD6),
                        foregroundColor: const Color(0xFF93000A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 1,
                      ),
                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.close, size: 22),
                        SizedBox(width: 8),
                        Text('HỦY TÌM CHUYẾN', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text('Bạn có thể hủy miễn phí trong quá trình đang tìm kiếm tài xế', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D)), textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}
