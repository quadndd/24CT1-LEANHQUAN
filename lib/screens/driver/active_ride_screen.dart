import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme.dart';
import '../../widgets/fake_map_widget.dart';

class DriverActiveRideScreen extends StatefulWidget {
  const DriverActiveRideScreen({super.key});

  @override
  State<DriverActiveRideScreen> createState() => _DriverActiveRideScreenState();
}

class _DriverActiveRideScreenState extends State<DriverActiveRideScreen> {
  // true = Đang đến đón khách (Demo 4), false = Đang chở khách (Demo 5)
  bool _isDrivingToPickup = true;
  bool _hasArrived = false; // Khi đã ấn "Tôi đã đến nơi"

  Future<void> _saveRide(String status) async {
    final prefs = await SharedPreferences.getInstance();
    final driverId = prefs.getString('id');
    if (driverId == null) return;

    try {
      await Supabase.instance.client.from('rides').insert({
        'driver_id': driverId,
        'status': status,
        'customer_name': 'Trần Thu Hà',
        'rating': '5.0',
        'vehicle_type': 'Car 4 Chỗ',
        'payment_method': 'Thẻ / Ví',
        'pickup_address': '22 Lê Duẩn, P. Bến Nghé, Quận 1',
        'dropoff_address': 'Landmark 81, Bình Thạnh',
        'amount': '+65.000 đ'
      });
    } catch (e) {
      debugPrint('Error saving ride: $e');
    }
  }

  void _handleArrived() {
    if (!_hasArrived) {
      setState(() => _hasArrived = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hành khách đã nhận thông báo bạn đã tới!')),
      );
    } else {
      // Khi đã đến nơi, ấn lần nữa để Bắt đầu chuyến (chuyển sang Demo 5)
      setState(() => _isDrivingToPickup = false);
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tổng thu nhập', style: TextStyle(fontSize: 14, color: Color(0xFF3D4A3D))),
                  Text('65.000 đ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF006E2E))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  await _saveRide('completed');
                  if (mounted) {
                    Navigator.pop(context); // close dialog
                    Navigator.pushReplacementNamed(context, '/driver/trip-complete');
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006E2E), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text('Xem chi tiết thu nhập', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
          // Fake Map with tracking
          const Positioned.fill(
            child: FakeMapWidget(),
          ),

          // Header Top Bar
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, bottom: 12, left: 16, right: 16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
                      const Icon(Icons.drive_eta, color: Color(0xFF006E2E), size: 20),
                      const SizedBox(width: 8),
                      Text(_isDrivingToPickup ? 'Chi Tiết Chuyến Đi' : 'Đang Di Chuyển', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF151C27))),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.help_outline), onPressed: () {}),
                      const CircleAvatar(radius: 16, backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBcB6uHyYEU_xr6DEBl4XDbCaR2T_IUrX2ZvjTcafV3yUJMctgzZBGZwbEAykn9A-78ZYd0E5TXtUJ705T4b57S4jpCYEv5w21xQYh9s0wfQtlXWNv9mHSxDPQXDvOW734cp8YSD7L6th4MzpnSzlvguzm8CrOP3OuOXhAWhLVDJDuqoKs8OjA8EG8W7eXukmKbOvrSzTbiO9Grld-lb10dkRe05sInKX2Ri4nbhBhlYa_jo4EZUyA')),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Turn-by-Turn Navigation Overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 70, left: 16, right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF2A313D).withOpacity(0.95), borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)]),
              child: Row(
                children: [
                  Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFF00B14F), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.turn_right, color: Colors.white, size: 30)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [Text(_isDrivingToPickup ? '150M NỮA' : 'ĐI THẲNG QUA CẦU', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF71FE91))), const SizedBox(width: 6), const Icon(Icons.circle, size: 4, color: Colors.white54), const SizedBox(width: 6), const Text('3 phút • 650m', style: TextStyle(fontSize: 11, color: Colors.white70))]),
                        Text(_isDrivingToPickup ? 'Rẽ phải vào đường Hai Bà Trưng' : 'Theo hướng Nguyễn Hữu Cảnh', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),
                  Container(width: 40, height: 40, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.volume_up, color: Color(0xFF151C27))),
                ],
              ),
            ),
          ),

          // Floating Controls
          Positioned(
            right: 16, bottom: _isDrivingToPickup ? 350 : 300,
            child: Column(
              children: [
                if (!_isDrivingToPickup) ...[
                  FloatingActionButton(heroTag: 'vol', mini: true, backgroundColor: Colors.white, onPressed: () {}, child: const Icon(Icons.volume_up, color: Color(0xFF151C27))),
                  const SizedBox(height: 8),
                  FloatingActionButton(heroTag: 'layers', mini: true, backgroundColor: Colors.white, onPressed: () {}, child: const Icon(Icons.layers, color: Color(0xFF151C27))),
                  const SizedBox(height: 8),
                  FloatingActionButton(heroTag: 'report', mini: true, backgroundColor: Colors.white, onPressed: () {}, child: const Icon(Icons.report, color: Color(0xFFBA1A1A))),
                ] else ...[
                  FloatingActionButton(heroTag: 'sos_mini', mini: true, backgroundColor: const Color(0xFFFFDAD6), onPressed: () {}, child: const Icon(Icons.shield, color: Color(0xFF93000A))),
                  const SizedBox(height: 8),
                  FloatingActionButton(heroTag: 'loc', mini: true, backgroundColor: Colors.white, onPressed: () {}, child: const Icon(Icons.my_location, color: Color(0xFF151C27))),
                ],
              ],
            ),
          ),

          // Bottom Sheet
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -10))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 48, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)), margin: const EdgeInsets.only(bottom: 12)),
                  
                  // Status Banner
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFF87FB9D), borderRadius: BorderRadius.circular(16)),
                        child: Row(children: [const Icon(Icons.circle, size: 8, color: Color(0xFF00B14F)), const SizedBox(width: 8), Text(_isDrivingToPickup ? 'ĐANG ĐẾN ĐÓN KHÁCH' : 'ĐANG THỰC HIỆN CHUYẾN', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF003A15)))]),
                      ),
                      if (_isDrivingToPickup)
                        const Row(children: [Icon(Icons.near_me, size: 18, color: Color(0xFF3D4A3D)), SizedBox(width: 4), Text('650 m', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF006E2E)))])
                      else
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: const [Text('Giá cước tạm tính', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))), Text('65.000 đ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF006E2E)))]),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Passenger Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            const CircleAvatar(radius: 24, backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCXOzn3S9jp-Kg0aDudIjRNsPqtqOIJ7rgPCL4FSD7P2nkTf-PUBhxYaRgUlbLQG1Waz5YtecZZ4PcGmRKVDDRm7KRQHu2jlb5rZXmHg27M0QHjltgI2eFLt5_dhkguLbRs8i5DNQekJyYNELw7O8_lb2SG42wUHNfSRzrfFdrBnQfJ5PMvyjO2VkqiznBnlaULafTvlM2HPCMAkIM3-at4MYV_TfDOAdWodEWGMXr7r7eprQCRf3g')),
                            Positioned(bottom: 0, right: 0, child: Container(decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.verified, size: 14, color: Color(0xFF006E2E)))),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [Flexible(child: Text('Trần Thu Hà', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)), const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFE2E8F8), borderRadius: BorderRadius.circular(4)), child: const Row(children: [Icon(Icons.star, size: 12, color: Colors.amber), Text('5.0', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]))]),
                              const SizedBox(height: 4),
                              const Row(children: [Icon(Icons.account_balance_wallet, size: 14, color: Color(0xFF3D4A3D)), SizedBox(width: 4), Flexible(child: Text('Thanh toán Thẻ / Ví', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D)), overflow: TextOverflow.ellipsis))]),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFFE2E8F8), shape: BoxShape.circle), child: const Icon(Icons.call, color: Color(0xFF151C27))),
                            const SizedBox(width: 8),
                            Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFF00B14F), shape: BoxShape.circle), child: const Icon(Icons.chat, color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_isDrivingToPickup) ...[
                    // Quick Reply Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildChip(Icons.send, 'Tôi đã tới nơi', true),
                          const SizedBox(width: 8),
                          _buildChip(Icons.traffic, 'Kẹt xe 2-3 phút', false),
                          const SizedBox(width: 8),
                          _buildChip(Icons.pin_drop, 'Đang bật đèn khẩn cấp', false),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Pickup Location
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
                              children: const [
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('ĐIỂM ĐÓN KHÁCH', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF3D4A3D))), Text('Cửa trước', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF006E2E)))]),
                                SizedBox(height: 4),
                                Text('22 Lê Duẩn, P. Bến Nghé', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF151C27))),
                                Text('Gần sảnh chính mPlaza, Quận 1', style: TextStyle(fontSize: 13, color: Color(0xFF3D4A3D))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Actions
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
                            Text(_hasArrived ? 'BẮT ĐẦU CHUYẾN' : 'NHẬN CHUYẾN', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
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
                            content: const Text('Bạn có chắc chắn muốn hủy chuyến này không? Việc hủy quá nhiều có thể ảnh hưởng đến đánh giá của bạn.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('QUAY LẠI')),
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.pop(ctx);
                                  await _saveRide('cancelled');
                                  if (mounted) {
                                    Navigator.pushReplacementNamed(context, '/driver/home');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Đã hủy chuyến xe'), backgroundColor: Color(0xFFBA1A1A)),
                                    );
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
                    // Dropoff Location
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
                            children: const [
                              Text('ĐIỂM ĐẾN', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))),
                              SizedBox(height: 4),
                              Text('Sảnh L1, Landmark 81', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF151C27))),
                              Text('720A Điện Biên Phủ, Phường 22, Bình Thạnh', style: TextStyle(fontSize: 13, color: Color(0xFF3D4A3D))),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Actions
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

  Widget _buildChip(IconData icon, String label, bool isPrimary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFE7EEFE), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isPrimary ? const Color(0xFF006E2E) : const Color(0xFF3D4A3D)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF151C27))),
        ],
      ),
    );
  }
}
