import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/real_map_widget.dart';

class VehicleSelectScreen extends StatefulWidget {
  const VehicleSelectScreen({super.key});

  @override
  State<VehicleSelectScreen> createState() => _VehicleSelectScreenState();
}

class _VehicleSelectScreenState extends State<VehicleSelectScreen> {
  String _selectedVehicleId = 'car4';

  final List<Map<String, dynamic>> _vehicles = [
    {
      'id': 'bike',
      'name': 'Xe máy (Bike)',
      'desc': 'Xe máy 2 bánh nhanh chóng, luồn lách linh hoạt',
      'icon': Icons.two_wheeler,
      'price': 28000,
      'originalPrice': 48000,
      'eta': '2 phút',
      'badge': null,
      'promo': null,
    },
    {
      'id': 'car4',
      'name': 'Ô tô 4 chỗ (Car)',
      'desc': 'Xe ô tô tiện nghi, máy lạnh mát mẻ',
      'icon': Icons.directions_car,
      'price': 65000,
      'originalPrice': null,
      'eta': '3 phút',
      'badge': 'Đề xuất',
      'promo': '-20K Promo',
    },
    {
      'id': 'premium',
      'name': 'Xe cao cấp (Premium)',
      'desc': 'Xe hạng sang êm ái, tài xế phục vụ 5 sao',
      'icon': Icons.local_taxi,
      'price': 110000,
      'originalPrice': null,
      'eta': '5 phút',
      'badge': null,
      'promo': 'Hạng thương gia',
    },
  ];

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _vehicles.firstWhere((v) => v['id'] == _selectedVehicleId);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Map phía trên
          Positioned.fill(
            bottom: MediaQuery.of(context).size.height * 0.50,
            child: Stack(
              children: [
                const RealMapWidget(),
                // Badge khoảng cách + thời gian
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF151C27).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10, height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00B14F),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('5.4 km • 14 phút', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                // Badge tình trạng giao thông
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.traffic, color: Color(0xFF006E2E), size: 18),
                        SizedBox(width: 4),
                        Text('Đường thoáng', style: TextStyle(color: Color(0xFF006E2E), fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
                // Nút quay lại
                Positioned(
                  top: MediaQuery.of(context).padding.top + 52,
                  left: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44, height: 44,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                      child: const Icon(Icons.arrow_back, size: 22, color: Color(0xFF151C27)),
                    ),
                  ),
                ),
                // Card Điểm đón / Điểm đến phía dưới bản đồ
                Positioned(
                  bottom: 16, left: 16, right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
                    ),
                    child: Column(
                      children: [
                        Row(children: [
                          Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFF006E2E), shape: BoxShape.circle)),
                          const SizedBox(width: 10),
                          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('ĐIỂM ĐÓN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF3D4A3D), letterSpacing: 0.8)),
                            Text('22 Lê Duẩn, Bến Nghé, Quận 1', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          ])),
                        ]),
                        Container(height: 2, margin: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: const Color(0xFFE2E8F8), borderRadius: BorderRadius.circular(1))),
                        Row(children: [
                          Container(width: 12, height: 12, decoration: BoxDecoration(color: const Color(0xFFBA1A1A), borderRadius: BorderRadius.circular(3))),
                          const SizedBox(width: 10),
                          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('ĐIỂM ĐẾN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF3D4A3D), letterSpacing: 0.8)),
                            Text('Landmark 81, Vinhomes Central Park', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          ])),
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Sheet: Chọn phương tiện
          Positioned(
            bottom: 0, left: 0, right: 0,
            top: MediaQuery.of(context).size.height * 0.46,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -4))],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: const Color(0xFFDCE2F3), borderRadius: BorderRadius.circular(2)))),
                    
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Chọn phương tiện di chuyển', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF151C27))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(6)),
                          child: const Text('Ưu đãi sẵn sàng', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF006E2E))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Vehicle Options
                    ..._vehicles.map((v) => _buildVehicleCard(v)),

                    const SizedBox(height: 16),

                    // Payment & Voucher
                    Row(children: [
                      // Payment
                      Expanded(child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(12)),
                        child: Row(children: [
                          Container(width: 28, height: 28, decoration: const BoxDecoration(color: Color(0xFFA50064), shape: BoxShape.circle), child: const Center(child: Text('M', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)))),
                          const SizedBox(width: 8),
                          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Ví MoMo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                            Text('Dư: 350.000 đ', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))),
                          ])),
                          const Icon(Icons.expand_more, size: 16, color: Color(0xFF3D4A3D)),
                        ]),
                      )),
                      const SizedBox(width: 8),
                      // Voucher
                      Expanded(child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(12)),
                        child: const Row(children: [
                          Icon(Icons.confirmation_number, color: Color(0xFF006E2E), size: 20),
                          SizedBox(width: 8),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('GIAM20K', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF006E2E))),
                            Text('-20.000 đ cước', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFFBA1A1A))),
                          ])),
                          Icon(Icons.check_circle, color: Color(0xFF006E2E), size: 16),
                        ]),
                      )),
                    ]),
                    const SizedBox(height: 12),

                    // Total price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          const Text('Tổng thanh toán: ', style: TextStyle(fontSize: 14, color: Color(0xFF3D4A3D))),
                          Text('${_formatPrice(selected['price'])} đ', style: const TextStyle(fontSize: 14, color: Color(0xFF3D4A3D), decoration: TextDecoration.lineThrough)),
                        ]),
                        Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                          Text('45.000', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF006E2E))),
                          const Text(' đ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF006E2E))),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // CTA Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/customer/finding-driver'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006E2E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.check_circle, color: Colors.white, size: 22),
                          const SizedBox(width: 8),
                          Text('XÁC NHẬN ĐẶT XE (${selected['name']})', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> v) {
    final isSelected = _selectedVehicleId == v['id'];
    return GestureDetector(
      onTap: () => setState(() => _selectedVehicleId = v['id']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF87FB9D).withOpacity(0.25) : const Color(0xFFF0F3FF),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : [],
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF00B14F) : const Color(0xFFE7EEFE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(v['icon'], size: 28, color: isSelected ? Colors.white : const Color(0xFF3D4A3D)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(v['name'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  if (v['badge'] != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFF006E2E), borderRadius: BorderRadius.circular(10)),
                      child: Text(v['badge'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ]),
                Text(v['desc'], style: const TextStyle(fontSize: 14, color: Color(0xFF3D4A3D)), maxLines: 1, overflow: TextOverflow.ellipsis),
                if (isSelected)
                  Row(children: [
                    const Icon(Icons.schedule, size: 14, color: Color(0xFF006E2E)),
                    const SizedBox(width: 4),
                    Text('Đón trong ${v['eta']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF006E2E))),
                  ]),
              ],
            )),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${_formatPrice(v['price'])} đ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: isSelected ? const Color(0xFF006E2E) : const Color(0xFF151C27))),
                if (v['originalPrice'] != null)
                  Text('${_formatPrice(v['originalPrice'])} đ', style: const TextStyle(fontSize: 11, color: Color(0xFF3D4A3D), decoration: TextDecoration.lineThrough)),
                if (v['promo'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(color: const Color(0xFFFFDAD6), borderRadius: BorderRadius.circular(4)),
                    child: Text(v['promo'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF93000A))),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
