import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/theme.dart';
import '../../widgets/fake_map_widget.dart';
import '../../widgets/real_map_widget.dart';

class CustomerActiveRideScreen extends StatefulWidget {
  const CustomerActiveRideScreen({super.key});

  @override
  State<CustomerActiveRideScreen> createState() => _CustomerActiveRideScreenState();
}

class _CustomerActiveRideScreenState extends State<CustomerActiveRideScreen> {
  bool _isPickupPhase = true;
  int _etaSeconds = 10; // Giảm xuống để test nhanh (10s)
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_etaSeconds > 0) {
          _etaSeconds--;
        } else if (_isPickupPhase) {
          _isPickupPhase = false;
          _etaSeconds = 15; // 15s cho giai đoạn di chuyển
        }
        if (!_isPickupPhase && _etaSeconds == 0) {
          _timer.cancel();
          _showArrivalDialog();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _etaText {
    final minutes = _etaSeconds ~/ 60;
    final seconds = _etaSeconds % 60;
    if (minutes > 0) return '$minutes phút';
    return '$seconds giây';
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
            const Text('Tổng tiền: 65.000 đ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF006E2E))),
            const SizedBox(height: 16),
            const Text('Đánh giá tài xế', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => const Icon(Icons.star_border, color: Colors.amber, size: 36)),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacementNamed(context, '/customer/home');
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006E2E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Về trang chủ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          IconButton(icon: const Icon(Icons.notifications, color: Color(0xFF3D4A3D)), onPressed: () {}),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(radius: 16, backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuA9IemJmH933gvRAYYaGwkGpH-wCYhxIiuIvaH88MrGxGbgJulDuQHxXnZAYDyiTMwMlRIuQf4ultYsx-XyOUBj3n-LK5MLe718QxkVbpgX9Wvvp-2SnOnQu27m1dWG3e_8-7ArcUU7ISNHnn-4AOWuZGirN7RFY4Ucf0JGV4VS1drYMoLieC_vTjEsTfyh6L0nJ_r3GwwfhZadPqhoPxjI35fcUDPrpKFg91Ix_kUSbzSycx9wZ0Q')),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map Background
          const Positioned.fill(child: RealMapWidget()),

          // Floating Badges on Map
          Positioned(
            top: 16, left: 16, right: 16,
            child: _isPickupPhase
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)]),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF00B14F), shape: BoxShape.circle)),
                        const SizedBox(width: 10),
                        const Text('Đang di chuyển đến điểm đón', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF151C27))),
                      ],
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFF151C27).withOpacity(0.9), borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12)]),
                    child: Row(
                      children: [
                        Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF00B14F), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.navigation, color: Colors.white)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [const Icon(Icons.circle, size: 8, color: Color(0xFF71FE91)), const SizedBox(width: 6), Text('Dự kiến đến đích: $_etaText', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF71FE91)))]),
                              const Text('Còn khoảng 3.8 km', style: TextStyle(fontSize: 13, color: Colors.white70)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // Bottom Sheet
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

                  if (_isPickupPhase) _buildPickupHeader() else _buildDrivingHeader(),

                  const SizedBox(height: 16),
                  _buildDriverProfile(),

                  const SizedBox(height: 16),
                  if (_isPickupPhase) _buildPickupLocation() else _buildDrivingActionsAndPrice(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF87FB9D), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.near_me, color: Color(0xFF007433))),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Tài xế đang đến đón bạn', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF151C27))),
                  Text('Khoảng cách: 800m', style: TextStyle(fontSize: 12, color: Color(0xFF3D4A3D))),
                ],
              ),
            ],
          ),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF00B14F), borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.timer, size: 16, color: Colors.white), const SizedBox(width: 4), Text(_etaText, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))])),
        ],
      ),
    );
  }

  Widget _buildDrivingHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF87FB9D).withOpacity(0.3), borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: const [Icon(Icons.verified_user, color: Color(0xFF006E2E)), SizedBox(width: 8), Text('Chuyến đi an toàn đang diễn ra', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF151C27)))]),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF006E2E).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Text('GPS Live', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF006E2E)))),
        ],
      ),
    );
  }

  Widget _buildDriverProfile() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _isPickupPhase ? Colors.white : const Color(0xFFF9F9FF), borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 24, backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida/AEtjO1VVBHUYordwALhGbJcHkkRHIQ9tAJ8E1Sf4UMXh_FLdXvQ1n4efaXQ1OR_b5hxx6Q-RCD4e5tbuG3QN-MxZpIwFbIvBrPkOb8LefJbTl3rYjafxCc72IvxYFzF_pNmU3U3f3a2tVwuNDBPTWK35Qay0D2eE6gIjXWBdOf2OA4TN4TMoaZyY-uMs6NMYF0p1hvGBQ0gR3fEKYg_ak9bgE0K5nrDITWZmv9LMXnToEEY9WNB_x8FaFOLrbQ')),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nguyễn Văn Tuấn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF151C27))),
                  Row(children: const [Icon(Icons.star, size: 14, color: Colors.amber), SizedBox(width: 4), Text('4.9', style: TextStyle(fontWeight: FontWeight.bold)), SizedBox(width: 8), Text('51K - 892.45', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF151C27)))]),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFF006E2E), shape: BoxShape.circle), child: const Icon(Icons.call, color: Colors.white, size: 20)),
              const SizedBox(width: 8),
              Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFFDCE2F3), shape: BoxShape.circle), child: const Icon(Icons.chat, color: Color(0xFF151C27), size: 20)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPickupLocation() {
    return Column(
      children: [
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
                  children: const [
                    Text('ĐIỂM ĐÓN CỦA BẠN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF006E2E))),
                    Text('22 Lê Duẩn, P. Bến Nghé, Quận 1', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF151C27))),
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
            Row(children: const [Icon(Icons.shield, color: Color(0xFF006E2E), size: 18), SizedBox(width: 6), Text('Bảo hiểm chuyến đi', style: TextStyle(fontSize: 13, color: Color(0xFF3D4A3D)))]),
            TextButton(onPressed: () {}, child: const Text('HỦY CHUYẾN', style: TextStyle(color: Color(0xFFBA1A1A), fontWeight: FontWeight.bold))),
          ],
        ),
      ],
    );
  }

  Widget _buildDrivingActionsAndPrice() {
    return Column(
      children: [
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
                  children: const [
                    Text('ĐIỂM ĐẾN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF3D4A3D))),
                    Text('Sảnh L1, Landmark 81', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF151C27))),
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
    );
  }
}
