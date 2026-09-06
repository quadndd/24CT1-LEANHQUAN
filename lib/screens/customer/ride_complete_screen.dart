import 'package:flutter/material.dart';
import '../../core/theme.dart';

class RideCompleteScreen extends StatefulWidget {
  const RideCompleteScreen({super.key});

  @override
  State<RideCompleteScreen> createState() => _RideCompleteScreenState();
}

class _RideCompleteScreenState extends State<RideCompleteScreen> {
  int _rating = 5;
  final Set<String> _selectedTags = {};
  int? _selectedTip;
  final _commentController = TextEditingController();

  final List<String> _ratingTexts = [
    'Rất không hài lòng (1 sao)',
    'Chưa hài lòng (2 sao)',
    'Bình thường (3 sao)',
    'Hài lòng (4 sao)',
    'Tuyệt vời! (5 sao)',
  ];

  final List<Map<String, dynamic>> _tags = [
    {'icon': Icons.airline_seat_recline_extra, 'label': 'Lái xe êm ái'},
    {'icon': Icons.clean_hands, 'label': 'Xe sạch sẽ'},
    {'icon': Icons.alarm_on, 'label': 'Đón đúng giờ'},
    {'icon': Icons.sentiment_satisfied_alt, 'label': 'Thân thiện lịch sự'},
  ];

  final List<Map<String, dynamic>> _tips = [
    {'amount': 10000, 'label': 'Cảm ơn'},
    {'amount': 20000, 'label': 'Rất tốt'},
    {'amount': 50000, 'label': 'Xuất sắc'},
  ];

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF151C27)), onPressed: () => Navigator.pop(context)),
        title: const Text('Chi Tiết Chuyến Đi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF151C27))),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Celebration Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE7EEFE), Color(0xFFF9F9FF)],
                ),
              ),
              child: Column(
                children: [
                  // Icon thành công
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(color: const Color(0xFF006E2E), shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFF006E2E).withOpacity(0.25), blurRadius: 12)]),
                        child: const Icon(Icons.check_circle, size: 36, color: Colors.white),
                      ),
                      Positioned(top: -4, right: -4, child: Container(
                        width: 24, height: 24,
                        decoration: const BoxDecoration(color: Color(0xFF87FB9D), shape: BoxShape.circle),
                        child: const Icon(Icons.celebration, size: 14, color: Color(0xFF002109)),
                      )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Chuyến đi hoàn tất!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF151C27))),
                  const SizedBox(height: 4),
                  const Text('Cảm ơn bạn đã lựa chọn dịch vụ xanh tiện lợi', style: TextStyle(fontSize: 14, color: Color(0xFF3D4A3D))),
                  const SizedBox(height: 16),

                  // Giá cước
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                    child: Column(children: [
                      const Text('CƯỚC PHÍ THANH TOÁN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF3D4A3D), letterSpacing: 0.8)),
                      const SizedBox(height: 4),
                      const Text('45.000 đ', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Color(0xFF006E2E), letterSpacing: -1)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFE2E8F8), borderRadius: BorderRadius.circular(20)),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.account_balance_wallet, size: 18, color: Color(0xFFAE2070)),
                          SizedBox(width: 6),
                          Text('Thanh toán tự động qua ', style: TextStyle(fontSize: 13, color: Color(0xFF3D4A3D))),
                          Text('MoMo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF151C27))),
                        ]),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 12),

                  // Thông tin lộ trình
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(12)),
                    child: Column(children: [
                      Row(children: [
                        Container(width: 10, height: 10, decoration: BoxDecoration(color: const Color(0xFF00B14F), shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        const Expanded(child: Text('22 Lê Duẩn, Bến Nghé, Quận 1', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        Container(width: 10, height: 10, decoration: BoxDecoration(color: const Color(0xFFBA1A1A), borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 8),
                        const Expanded(child: Text('Landmark 81, Vinhomes Central Park', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                      ]),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFE2E8F8).withOpacity(0.4), borderRadius: BorderRadius.circular(8)),
                        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.route, size: 16, color: Color(0xFF3D4A3D)),
                          SizedBox(width: 6),
                          Text('5.4 km', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF3D4A3D))),
                          SizedBox(width: 12),
                          Icon(Icons.schedule, size: 16, color: Color(0xFF3D4A3D)),
                          SizedBox(width: 6),
                          Text('14 phút di chuyển', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF3D4A3D))),
                        ]),
                      ),
                    ]),
                  ),
                ],
              ),
            ),

            // Rating & Review
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                child: Column(children: [
                  // Tài xế
                  const CircleAvatar(radius: 40, backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuA9IemJmH933gvRAYYaGwkGpH-wCYhxIiuIvaH88MrGxGbgJulDuQHxXnZAYDyiTMwMlRIuQf4ultYsx-XyOUBj3n-LK5MLe718QxkVbpgX9Wvvp-2SnOnQu27m1dWG3e_8-7ArcUU7ISNHnn-4AOWuZGirN7RFY4Ucf0JGV4VS1drYMoLieC_vTjEsTfyh6L0nJ_r3GwwfhZadPqhoPxjI35fcUDPrpKFg91Ix_kUSbzSycx9wZ0Q')),
                  const SizedBox(height: 8),
                  const Text('Nguyễn Văn Tuấn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.directions_car, size: 18, color: Color(0xFF3D4A3D)),
                    const SizedBox(width: 6),
                    const Text('Toyota Vios', style: TextStyle(fontSize: 14, color: Color(0xFF3D4A3D))),
                    const SizedBox(width: 8),
                    const Text('•', style: TextStyle(color: Color(0xFF3D4A3D))),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFE7EEFE), borderRadius: BorderRadius.circular(4)),
                      child: const Text('51K-892.45', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // Rating
                  Text(_ratingTexts[_rating - 1], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF006E2E))),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) {
                    return GestureDetector(
                      onTap: () => setState(() => _rating = i + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          i < _rating ? Icons.star : Icons.star_border,
                          size: 36,
                          color: i < _rating ? const Color(0xFFFFB703) : const Color(0xFFBCCBB9),
                        ),
                      ),
                    );
                  })),
                  const SizedBox(height: 16),

                  // Tags
                  Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: _tags.map((tag) {
                    final isSelected = _selectedTags.contains(tag['label']);
                    return GestureDetector(
                      onTap: () => setState(() {
                        if (isSelected) _selectedTags.remove(tag['label']);
                        else _selectedTags.add(tag['label']);
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF87FB9D) : const Color(0xFFE7EEFE),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(tag['icon'], size: 16, color: const Color(0xFF006E2E)),
                          const SizedBox(width: 6),
                          Text(tag['label'], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? const Color(0xFF007433) : const Color(0xFF151C27))),
                        ]),
                      ),
                    );
                  }).toList()),
                  const SizedBox(height: 16),

                  // Comment
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(12)),
                    child: TextField(
                      controller: _commentController,
                      maxLines: 2,
                      decoration: const InputDecoration.collapsed(hintText: 'Nhập lời khen hoặc góp ý cho tài xế...', hintStyle: TextStyle(color: Color(0xFF6D7B6C))),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tip
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Row(children: [
                      Icon(Icons.volunteer_activism, size: 18, color: Color(0xFF006E2E)),
                      SizedBox(width: 6),
                      Text('Tip thêm cho tài xế', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    ]),
                    const Text('Tùy chọn', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF3D4A3D))),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: _tips.map((tip) {
                    final isSelected = _selectedTip == tip['amount'];
                    return Expanded(child: GestureDetector(
                      onTap: () => setState(() => _selectedTip = isSelected ? null : tip['amount']),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 56,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF006E2E) : const Color(0xFFE7EEFE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text('+${_formatPrice(tip['amount'])} đ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : const Color(0xFF151C27))),
                          Text(tip['label'], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isSelected ? Colors.white.withOpacity(0.8) : const Color(0xFF3D4A3D))),
                        ]),
                      ),
                    ));
                  }).toList()),
                ]),
              ),
            ),

            // Submit Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/customer/home', (route) => false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B14F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 24),
                    SizedBox(width: 8),
                    Text('GỬI ĐÁNH GIÁ & VỀ TRANG CHỦ', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Text('Đánh giá của bạn sẽ giúp tài xế hoàn thiện chất lượng phục vụ hơn', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D)), textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}
