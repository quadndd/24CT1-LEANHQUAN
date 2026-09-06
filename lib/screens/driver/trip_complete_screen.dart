import 'package:flutter/material.dart';
import '../../core/theme.dart';

class DriverTripCompleteScreen extends StatelessWidget {
  const DriverTripCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF151C27)), onPressed: () => Navigator.pop(context)),
            const Icon(Icons.drive_eta, color: Color(0xFF006E2E), size: 20),
            const SizedBox(width: 8),
            const Text('Chi Tiết Chuyến Đi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF151C27))),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Success Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(width: 80, height: 80, decoration: BoxDecoration(color: const Color(0xFF87FB9D).withOpacity(0.3), shape: BoxShape.circle)),
                      Container(width: 56, height: 56, decoration: const BoxDecoration(color: Color(0xFF006E2E), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)]), child: const Icon(Icons.check_circle, color: Colors.white, size: 36)),
                      Positioned(top: 0, right: 0, child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]), child: const Row(children: [Text('✨ ', style: TextStyle(fontSize: 10)), Text('Hoàn tất', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF006E2E)))]))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF87FB9D).withOpacity(0.4), borderRadius: BorderRadius.circular(16)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Text('🎉 ', style: TextStyle(fontSize: 14)), Text('Chuyến đi hoàn thành!', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF003A15)))],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Cước khách trả: ', style: TextStyle(fontSize: 14, color: Color(0xFF3D4A3D))), Text('65.000 đ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF151C27)))]),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Earnings Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFF006E2E), borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Thu nhập thực nhận'.toUpperCase(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.8))),
                            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Text('Đã khấu trừ 20% phí sàn', style: TextStyle(fontSize: 11, color: Colors.white))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [Text('+52.000', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white)), Text('đ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))]),
                        const SizedBox(height: 12),
                        Container(height: 1, color: Colors.white.withOpacity(0.15)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.account_balance_wallet, color: Color(0xFF71FE91), size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: RichText(text: const TextSpan(style: TextStyle(fontSize: 14, color: Colors.white), children: [TextSpan(text: 'Khách trả qua Ví MoMo / Thẻ • '), TextSpan(text: 'Cộng vào ví ngay lập tức', style: TextStyle(color: Color(0xFF71FE91), fontWeight: FontWeight.w600))]))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Stats Grid
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Chỉ số chuyến xe', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF151C27))),
                            Text('Mã chuyến: #GRB-89421', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 2.2,
                          children: [
                            _buildStatBox(Icons.straighten, 'Quãng đường', '5.8 km'),
                            _buildStatBox(Icons.schedule, 'Thời gian', '14 phút'),
                            _buildStatBox(Icons.verified, 'Đón đúng giờ', '100%', iconColor: const Color(0xFF006E2E)),
                            _buildTipBox(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Route Details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Lộ trình di chuyển', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF151C27))),
                        const SizedBox(height: 12),
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
                                  Text('ĐIỂM ĐÓN', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))),
                                  Text('22 Lê Duẩn', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF151C27))),
                                  Text('Bến Nghé, Quận 1, TP. Hồ Chí Minh', style: TextStyle(fontSize: 13, color: Color(0xFF3D4A3D))),
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
                                  Text('ĐIỂM ĐẾN', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))),
                                  Text('Landmark 81', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF151C27))),
                                  Text('720A Điện Biên Phủ, Phường 22, Bình Thạnh', style: TextStyle(fontSize: 13, color: Color(0xFF3D4A3D))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Points
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.stars, color: Color(0xFF006E2E), size: 22),
                            SizedBox(width: 8),
                            Text('Điểm tích lũy tài xế: ', style: TextStyle(fontSize: 14, color: Color(0xFF151C27))),
                            Text('+15 điểm', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF006E2E))),
                          ],
                        ),
                        const Icon(Icons.chevron_right, color: Color(0xFF3D4A3D)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Action Button
                  SizedBox(
                    width: double.infinity, height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/driver/home');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B14F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('HOÀN TẤT & TIẾP TỤC NHẬN CUỐC', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), SizedBox(width: 8), Icon(Icons.arrow_forward, size: 20)]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(IconData icon, String label, String value, {Color iconColor = const Color(0xFF3D4A3D)}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(children: [Icon(icon, size: 18, color: iconColor), const SizedBox(width: 6), Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF3D4A3D)))]),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: iconColor == const Color(0xFF006E2E) ? iconColor : const Color(0xFF151C27))),
        ],
      ),
    );
  }

  Widget _buildTipBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF87FB9D).withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Row(children: [Icon(Icons.volunteer_activism, size: 18, color: Color(0xFF006D2F)), SizedBox(width: 6), Text('Tiền tip thêm', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF007433)))]),
          const SizedBox(height: 2),
          const Text('+10.000 đ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF006D2F))),
          const SizedBox(height: 2),
          Row(children: const [Text('⭐ 5.0 ', style: TextStyle(fontSize: 10)), Text('Lái xe êm ái', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D)))]),
        ],
      ),
    );
  }
}
