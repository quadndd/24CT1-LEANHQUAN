import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// Widget bản đồ giả lập - hiển thị bằng CustomPainter
/// thay thế cho Google Maps mà không cần API key
class FakeMapWidget extends StatelessWidget {
  final MapStyle style;
  final bool showRoute;
  final bool showPulse;

  const FakeMapWidget({
    super.key,
    this.style = MapStyle.normal,
    this.showRoute = false,
    this.showPulse = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showPulse) {
      return _PulseMapWidget();
    }
    return CustomPaint(
      painter: _MapPainter(style: style, showRoute: showRoute),
      child: Container(),
    );
  }
}

enum MapStyle { normal, satellite, driver }

class _MapPainter extends CustomPainter {
  final MapStyle style;
  final bool showRoute;

  _MapPainter({required this.style, required this.showRoute});

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    final bgPaint = Paint()..color = const Color(0xFFE8EFF0);
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Grid lines (simulate roads)
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final smallRoadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Horizontal roads
    for (double y = 0; y < size.height; y += size.height / 6) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), roadPaint);
    }
    // Vertical roads
    for (double x = 0; x < size.width; x += size.width / 5) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), roadPaint);
    }

    // Diagonal roads
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

    // Green areas (parks)
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

    // Buildings (grey blocks)
    final buildingPaint = Paint()..color = const Color(0xFFD4D8DC);
    final buildings = [
      Rect.fromLTWH(size.width * 0.05, size.height * 0.25, size.width * 0.12, size.height * 0.08),
      Rect.fromLTWH(size.width * 0.30, size.height * 0.12, size.width * 0.10, size.height * 0.10),
      Rect.fromLTWH(size.width * 0.50, size.height * 0.30, size.width * 0.13, size.height * 0.09),
      Rect.fromLTWH(size.width * 0.70, size.height * 0.15, size.width * 0.11, size.height * 0.08),
      Rect.fromLTWH(size.width * 0.20, size.height * 0.55, size.width * 0.14, size.height * 0.10),
      Rect.fromLTWH(size.width * 0.55, size.height * 0.68, size.width * 0.12, size.height * 0.09),
      Rect.fromLTWH(size.width * 0.75, size.height * 0.70, size.width * 0.10, size.height * 0.08),
    ];
    for (final rect in buildings) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        buildingPaint,
      );
    }

    // Water body (river-like)
    final waterPaint = Paint()..color = const Color(0xFFADD8E6).withValues(alpha: 0.4);
    final waterPath = Path()
      ..moveTo(size.width * 0.0, size.height * 0.45)
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
      ..close();
    canvas.drawPath(waterPath, waterPaint);

    if (showRoute) {
      _drawRoute(canvas, size);
    }

    // Origin marker (green)
    _drawMarker(
      canvas,
      Offset(size.width * 0.3, size.height * 0.6),
      AppColors.primary,
      isOrigin: true,
    );

    // Destination marker (red)
    _drawMarker(
      canvas,
      Offset(size.width * 0.7, size.height * 0.3),
      Colors.red,
      isOrigin: false,
    );
  }

  void _drawRoute(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Dashed line route
    final path = Path()
      ..moveTo(size.width * 0.3, size.height * 0.6)
      ..quadraticBezierTo(
        size.width * 0.5, size.height * 0.35,
        size.width * 0.7, size.height * 0.3,
      );

    _drawDashedPath(canvas, path, routePaint, dashLength: 8, gapLength: 6);
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    double dashLength = 10,
    double gapLength = 5,
  }) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final len = draw ? dashLength : gapLength;
        if (draw) {
          final segment = metric.extractPath(
            distance,
            (distance + len).clamp(0, metric.length),
          );
          canvas.drawPath(segment, paint);
        }
        distance += len;
        draw = !draw;
      }
    }
  }

  void _drawMarker(Canvas canvas, Offset center, Color color, {required bool isOrigin}) {
    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center.translate(0, 2), 14, shadowPaint);

    // Main circle
    final circlePaint = Paint()..color = color;
    canvas.drawCircle(center, 14, circlePaint);

    // Inner white
    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, 6, innerPaint);

    if (!isOrigin) {
      // Pin point
      final pinPaint = Paint()..color = color;
      final pinPath = Path()
        ..moveTo(center.dx - 5, center.dy + 12)
        ..lineTo(center.dx + 5, center.dy + 12)
        ..lineTo(center.dx, center.dy + 20)
        ..close();
      canvas.drawPath(pinPath, pinPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Pulse animation map for "finding driver" screen
class _PulseMapWidget extends StatefulWidget {
  @override
  State<_PulseMapWidget> createState() => _PulseMapWidgetState();
}

class _PulseMapWidgetState extends State<_PulseMapWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base map
        CustomPaint(
          painter: _MapPainter(style: MapStyle.normal, showRoute: false),
          child: Container(),
        ),
        // Pulse effect at center
        Center(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 100 * _animation.value,
                    height: 100 * _animation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.15 * (1 - _animation.value + 0.3)),
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
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
