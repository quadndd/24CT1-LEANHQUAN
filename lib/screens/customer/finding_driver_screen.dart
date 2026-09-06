import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/theme.dart';
import '../../widgets/real_map_widget.dart';

class FindingDriverScreen extends StatefulWidget {
  const FindingDriverScreen({super.key});

  @override
  State<FindingDriverScreen> createState() => _FindingDriverScreenState();
}

class _FindingDriverScreenState extends State<FindingDriverScreen> with TickerProviderStateMixin {
  int _seconds = 0;
  double _progress = 0;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
        _progress = (_progress >= 0.92) ? 0.40 : _progress + 0.025;
      });
      // Giả lập tìm thấy tài xế sau 15 giây
      if (_seconds >= 15) {
        _timer?.cancel();
        Navigator.pushReplacementNamed(context, '/customer/active-ride');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Map với hiệu ứng radar
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                const RealMapWidget(),
                // Badge phạm vi
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 10, height: 10, decoration: BoxDecoration(color: const Color(0xFF00B14F), shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      const Text('Phạm vi: 2.5 km', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
                // Nút quay lại
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  right: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                      child: const Icon(Icons.close, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Card
          Transform.translate(
            offset: const Offset(0, -24),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12)],
              ),
              child: Column(
                children: [
                  // Header: Đang kết nối
                  Row(children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(color: const Color(0xFF87FB9D), shape: BoxShape.circle),
                      child: const Center(child: Icon(Icons.refresh, color: Color(0xFF006D2F), size: 28)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Đang kết nối tài xế gần bạn nhất...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Row(children: [
                        const Icon(Icons.radar, size: 16, color: Color(0xFF006E2E)),
                        const SizedBox(width: 4),
                        const Text('Đã gửi yêu cầu tới 4 xe lân cận', style: TextStyle(fontSize: 14, color: Color(0xFF3D4A3D))),
                      ]),
                    ])),
                  ]),
                  const SizedBox(height: 14),

                  // Thanh tiến trình
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE2E8F8),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00B14F)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Thời gian dự kiến: ~45 giây', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D), fontWeight: FontWeight.w600)),
                    Text(_timerText, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF006E2E))),
                  ]),
                  const SizedBox(height: 14),

                  // Thông tin chuyến đi
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(10)),
                    child: Column(children: [
                      // Điểm đón
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(width: 24, height: 24, decoration: BoxDecoration(color: const Color(0xFF00B14F), shape: BoxShape.circle), child: const Icon(Icons.trip_origin, size: 14, color: Colors.white)),
                        const SizedBox(width: 12),
                        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('ĐIỂM ĐÓN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF3D4A3D), letterSpacing: 0.8)),
                          Text('22 Lê Duẩn, P. Bến Nghé, Quận 1', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        ])),
                      ]),
                      const SizedBox(height: 10),
                      // Điểm đến
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(width: 24, height: 24, decoration: BoxDecoration(color: const Color(0xFFBA1A1A), shape: BoxShape.circle), child: const Icon(Icons.location_on, size: 14, color: Colors.white)),
                        const SizedBox(width: 12),
                        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('ĐIỂM ĐẾN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF3D4A3D), letterSpacing: 0.8)),
                          Text('Landmark 81, Vinhomes Central Park', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          Text('Khoảng cách: 5.4 km', style: TextStyle(fontSize: 14, color: Color(0xFF3D4A3D))),
                        ])),
                      ]),
                      const SizedBox(height: 10),
                      // Xe + Giá
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFE7EEFE), borderRadius: BorderRadius.circular(8)),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Row(children: [
                            Container(width: 36, height: 36, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.local_taxi, color: Color(0xFF006E2E), size: 20)),
                            const SizedBox(width: 10),
                            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Ô tô 4 chỗ (Car)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                              Text('Giá cước cố định', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))),
                            ]),
                          ]),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            const Text('45.000 đ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006E2E))),
                            Row(children: [
                              Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xFF006D2F), shape: BoxShape.circle)),
                              const SizedBox(width: 4),
                              const Text('Ví MoMo', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))),
                            ]),
                          ]),
                        ]),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 12),

                  // AI Tip
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFE7EEFE), borderRadius: BorderRadius.circular(8)),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(width: 24, height: 24, decoration: BoxDecoration(color: const Color(0xFF52E078).withOpacity(0.4), shape: BoxShape.circle), child: const Icon(Icons.smart_toy, size: 16, color: Color(0xFF006E2E))),
                      const SizedBox(width: 10),
                      const Expanded(child: Text.rich(TextSpan(
                        text: 'Hệ thống AI đang ưu tiên kết nối với các đối tác tài xế có đánh giá từ ',
                        style: TextStyle(fontSize: 14, color: Color(0xFF3D4A3D)),
                        children: [
                          TextSpan(text: '4.8★ trở lên', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF151C27))),
                          TextSpan(text: ' để bảo đảm chuyến đi trọn vẹn.'),
                        ],
                      ))),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  // Nút Hủy
                  SizedBox(
                    width: double.infinity, height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        _timer?.cancel();
                        Navigator.pop(context);
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

          // Bảo hiểm
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(12)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Row(children: [
                  Icon(Icons.verified_user, color: Color(0xFF006E2E), size: 20),
                  SizedBox(width: 10),
                  Text('Bảo hiểm chuyến đi tự động kích hoạt', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ]),
                GestureDetector(onTap: () {}, child: const Text('Chi tiết', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF006E2E), decoration: TextDecoration.underline))),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
