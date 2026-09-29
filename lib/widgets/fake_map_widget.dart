// ============================================================
// fake_map_widget.dart — Widget bản đồ giả lập (CustomPainter)
// Dùng để hiển thị bản đồ demo khi không cần GPS thực
// Không yêu cầu API key hay kết nối mạng
// ============================================================
import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// Widget bản đồ giả lập — hiển thị bằng CustomPainter
/// thay thế cho Google Maps mà không cần API key
class FakeMapWidget extends StatelessWidget {
  final MapStyle style;   // Kiểu bản đồ: normal, satellite hoặc driver
  final bool showRoute;   // Có hiển thị đường đi (route) không
  final bool showPulse;   // Có hiển thị hiệu ứng pulse (tìm tài xế) không

  const FakeMapWidget({
    super.key,
    this.style = MapStyle.normal, // Mặc định: bản đồ thường
    this.showRoute = false,        // Mặc định: không vẽ đường
    this.showPulse = false,        // Mặc định: không có pulse
  });

  @override
  Widget build(BuildContext context) {
    // Nếu bật pulse → dùng widget animated riêng (cho màn hình tìm tài xế)
    if (showPulse) {
      return _PulseMapWidget();
    }
    // Vẽ bản đồ tĩnh bằng CustomPainter
    return CustomPaint(
      painter: _MapPainter(style: style, showRoute: showRoute),
      child: Container(), // Container rỗng để CustomPainter có diện tích vẽ
    );
  }
}

/// Enum định nghĩa các kiểu hiển thị bản đồ
enum MapStyle { normal, satellite, driver }

/// Lớp vẽ bản đồ giả lập bằng Canvas API
class _MapPainter extends CustomPainter {
  final MapStyle style;   // Kiểu bản đồ
  final bool showRoute;   // Có vẽ đường đi không

  _MapPainter({required this.style, required this.showRoute});

  @override
  void paint(Canvas canvas, Size size) {
    // ── Nền bản đồ (màu xanh xám nhạt) ──────────────────────────
    final bgPaint = Paint()..color = const Color(0xFFE8EFF0);
    canvas.drawRect(Offset.zero & size, bgPaint); // Vẽ phủ toàn bộ diện tích

    // ── Đường lớn (Lưới đường phố chính) ─────────────────────────
    final roadPaint = Paint()
      ..color = Colors.white          // Màu trắng mô phỏng đường nhựa
      ..strokeWidth = 3.0             // Độ dày đường lớn
      ..style = PaintingStyle.stroke; // Chỉ vẽ viền (không tô màu)

    // Đường nhỏ (đường phụ, hẻm)
    final smallRoadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7) // Nhạt hơn đường chính
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Vẽ đường ngang (6 đường phân bố đều theo chiều cao)
    for (double y = 0; y < size.height; y += size.height / 6) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), roadPaint);
    }
    // Vẽ đường dọc (5 đường phân bố đều theo chiều rộng)
    for (double x = 0; x < size.width; x += size.width / 5) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), roadPaint);
    }

    // Vẽ 2 đường chéo mô phỏng đường phố không vuông góc
    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width * 0.6, size.height * 0.8),
      smallRoadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.2, 0),
      Offset(size.width, size.height * 0.6),
      smallRoadPaint,
    );

    // ── Khu vực xanh (Công viên) ──────────────────────────────────
    final parkPaint = Paint()..color = const Color(0xFFB8D4BD).withValues(alpha: 0.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.1, size.height * 0.1, size.width * 0.15, size.height * 0.12),
        const Radius.circular(4),
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.65, size.height * 0.55, size.width * 0.2, size.height * 0.15),
        const Radius.circular(4),
      ),
      parkPaint,
    );

    // ── Tòa nhà (Các khối xám mô phỏng building) ──────────────────
    final buildingPaint = Paint()..color = const Color(0xFFD4D8DC);
    // Danh sách các hình chữ nhật mô phỏng tòa nhà
    final buildings = [
      Rect.fromLTWH(size.width * 0.05, size.height * 0.25, size.width * 0.12, size.height * 0.08),
      Rect.fromLTWH(size.width * 0.30, size.height * 0.12, size.width * 0.10, size.height * 0.10),
      Rect.fromLTWH(size.width * 0.50, size.height * 0.30, size.width * 0.13, size.height * 0.09),
      Rect.fromLTWH(size.width * 0.70, size.height * 0.15, size.width * 0.11, size.height * 0.08),
      Rect.fromLTWH(size.width * 0.20, size.height * 0.55, size.width * 0.14, size.height * 0.10),
      Rect.fromLTWH(size.width * 0.55, size.height * 0.68, size.width * 0.12, size.height * 0.09),
      Rect.fromLTWH(size.width * 0.75, size.height * 0.70, size.width * 0.10, size.height * 0.08),
    ];
    // Vẽ từng tòa nhà với góc bo tròn nhẹ
    for (final rect in buildings) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        buildingPaint,
      );
    }

    // ── Sông/kênh (Đường cong màu xanh nhạt mô phỏng mặt nước) ───
    final waterPaint = Paint()..color = const Color(0xFFADD8E6).withValues(alpha: 0.4);
    final waterPath = Path()
      ..moveTo(size.width * 0.0, size.height * 0.45)
      // Vẽ đường cong bezier mô phỏng dòng sông ngoằn ngoèo
      ..quadraticBezierTo(
        size.width * 0.3, size.height * 0.5,
        size.width * 0.6, size.height * 0.42,
      )
      ..quadraticBezierTo(
        size.width * 0.8, size.height * 0.38,
        size.width * 1.0, size.height * 0.43,
      )
      ..lineTo(size.width * 1.0, size.height * 0.50)
      ..quadraticBezierTo(
        size.width * 0.8, size.height * 0.46,
        size.width * 0.6, size.height * 0.50,
      )
      ..quadraticBezierTo(
        size.width * 0.3, size.height * 0.57,
        size.width * 0.0, size.height * 0.52,
      )
      ..close(); // Đóng path để tạo vùng khép kín
    canvas.drawPath(waterPath, waterPaint);

    // ── Vẽ đường đi nếu được yêu cầu ─────────────────────────────
    if (showRoute) {
      _drawRoute(canvas, size); // Vẽ route từ điểm đón đến điểm đến
    }

    // ── Marker điểm đón (xanh lá) ─────────────────────────────────
    _drawMarker(
      canvas,
      Offset(size.width * 0.3, size.height * 0.6), // Vị trí demo điểm đón
      AppColors.primary,
      isOrigin: true, // Marker tròn (không có chân)
    );

    // ── Marker điểm đến (đỏ) ──────────────────────────────────────
    _drawMarker(
      canvas,
      Offset(size.width * 0.7, size.height * 0.3), // Vị trí demo điểm đến
      Colors.red,
      isOrigin: false, // Marker có chân nhọn (pin)
    );
  }

  /// Vẽ đường đi dạng nét đứt từ điểm đón đến điểm đến
  void _drawRoute(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = AppColors.primary   // Màu xanh lá
      ..strokeWidth = 3             // Độ dày đường
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round; // Đầu nét tròn

    // Đường cong bezier mô phỏng tuyến đường thực tế
    final path = Path()
      ..moveTo(size.width * 0.3, size.height * 0.6)  // Từ điểm đón
      ..quadraticBezierTo(
        size.width * 0.5, size.height * 0.35,          // Điểm kiểm soát
        size.width * 0.7, size.height * 0.3,           // Đến điểm đến
      );

    // Vẽ đường dạng nét đứt (dash = 8, gap = 6)
    _drawDashedPath(canvas, path, routePaint, dashLength: 8, gapLength: 6);
  }

  /// Vẽ đường theo kiểu nét đứt (dashed line) trên Canvas
  /// [dashLength]: Độ dài mỗi nét, [gapLength]: Khoảng cách giữa các nét
  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    double dashLength = 10,
    double gapLength = 5,
  }) {
    final metrics = path.computeMetrics(); // Lấy thông tin độ dài path
    for (final metric in metrics) {
      double distance = 0;
      bool draw = true; // Xen kẽ: true = vẽ nét, false = bỏ qua (tạo khoảng hở)
      while (distance < metric.length) {
        final len = draw ? dashLength : gapLength; // Độ dài tùy vào đang vẽ hay bỏ
        if (draw) {
          // Cắt đoạn path và vẽ lên canvas
          final segment = metric.extractPath(
            distance,
            (distance + len).clamp(0, metric.length), // Không vượt quá độ dài path
          );
          canvas.drawPath(segment, paint);
        }
        distance += len; // Tiến đến vị trí tiếp theo
        draw = !draw;    // Chuyển trạng thái vẽ/bỏ
      }
    }
  }

  /// Vẽ marker (ghim vị trí) trên bản đồ
  /// [center]: Tọa độ canvas, [color]: Màu marker, [isOrigin]: true = tròn, false = có chân nhọn
  void _drawMarker(Canvas canvas, Offset center, Color color, {required bool isOrigin}) {
    // Bóng đổ để marker nổi lên khỏi bản đồ
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4); // Làm mờ bóng
    canvas.drawCircle(center.translate(0, 2), 14, shadowPaint); // Bóng lệch xuống 2px

    // Vòng tròn chính của marker
    final circlePaint = Paint()..color = color;
    canvas.drawCircle(center, 14, circlePaint);

    // Vòng tròn trắng bên trong (tạo hiệu ứng viền)
    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, 6, innerPaint);

    if (!isOrigin) {
      // Chân nhọn (pin) chỉ dành cho marker điểm đến
      final pinPaint = Paint()..color = color;
      final pinPath = Path()
        ..moveTo(center.dx - 5, center.dy + 12) // Góc trái
        ..lineTo(center.dx + 5, center.dy + 12) // Góc phải
        ..lineTo(center.dx, center.dy + 20)      // Đỉnh nhọn
        ..close();
      canvas.drawPath(pinPath, pinPaint);
    }
  }

  /// Không cần vẽ lại khi widget update (bản đồ tĩnh)
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget bản đồ có hiệu ứng Pulse (dùng cho màn hình đang tìm tài xế)
// ─────────────────────────────────────────────────────────────────────────────

/// Widget bản đồ với hiệu ứng sóng lan ra (pulse animation)
/// Sử dụng cho màn hình "Đang tìm tài xế"
class _PulseMapWidget extends StatefulWidget {
  @override
  State<_PulseMapWidget> createState() => _PulseMapWidgetState();
}

/// State quản lý animation của pulse effect
class _PulseMapWidgetState extends State<_PulseMapWidget>
    with SingleTickerProviderStateMixin { // Mixin cần thiết để dùng AnimationController
  late AnimationController _controller; // Điều khiển animation
  late Animation<double> _animation;    // Giá trị animation (0.3 → 1.0)

  @override
  void initState() {
    super.initState();
    // Tạo animation controller với chu kỳ 2 giây, lặp vô hạn
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(); // Lặp animation liên tục
    // Animation từ 0.3 đến 1.0 với đường cong easeOut (nhanh đầu, chậm cuối)
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Giải phóng controller khi widget bị hủy (tránh memory leak)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Lớp bản đồ tĩnh phía dưới
        CustomPaint(
          painter: _MapPainter(style: MapStyle.normal, showRoute: false),
          child: Container(),
        ),
        // Hiệu ứng pulse ở giữa màn hình (mô phỏng đang tìm kiếm trong khu vực)
        Center(
          child: AnimatedBuilder(
            animation: _animation, // Rebuild mỗi khi animation thay đổi
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Vòng ngoài cùng — mở rộng dần, mờ dần
                  Container(
                    width: 100 * _animation.value,   // Kích thước tăng theo animation
                    height: 100 * _animation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // Màu mờ dần khi vòng mở rộng (hiệu ứng sóng)
                      color: AppColors.primary.withValues(alpha: 0.15 * (1 - _animation.value + 0.3)),
                    ),
                  ),
                  // Vòng giữa — bán kính cố định, hơi mờ
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  // Vòng trong cùng — nhỏ nhất, đặc nhất (tâm điểm tìm kiếm)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary, // Màu đặc nhất
                    ),
                    child: const Icon(Icons.circle, color: Colors.white, size: 12),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
