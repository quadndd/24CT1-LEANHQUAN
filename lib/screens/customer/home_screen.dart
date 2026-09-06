import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/auth_service.dart';
import '../../widgets/real_map_widget.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentIndex = 0;
  String _username = 'Thu Hà';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final name = await AuthService.getSavedUsername();
    if (name != null && name.isNotEmpty) {
      setState(() {
        _username = name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      body: _buildHomeTab(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: 0,
            onTap: (index) {
              if (index == 1) Navigator.pushReplacementNamed(context, '/customer/trips');
              if (index == 2) Navigator.pushReplacementNamed(context, '/customer/notifications');
              if (index == 3) Navigator.pushReplacementNamed(context, '/customer/profile');
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color(0xFF006E2E), // primary
            unselectedItemColor: const Color(0xFF6D7B6C), // outline
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Trang chủ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'Chuyến đi',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_outlined),
                activeIcon: Icon(Icons.notifications),
                label: 'Thông báo',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Cá nhân',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return Stack(
      children: [
        // 1. Header (App bar giả)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              bottom: 8,
              left: 16,
              right: 16,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9FF).withOpacity(0.85),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.network(
                      'https://lh3.googleusercontent.com/aida/AEtjO1UadSbZ_GnbE6Q-ZKhr0EChZXzbtEbeYAW-Iwhjn4zpQ8iHYEETKVgsikXfQOjxFdBDPUje1d7j4de1TgAqJPc7aXJ5dfcu-4GxE4OsxnhV20IzJWLpYBFTtIPxzSfkiJZDkNxwjh_tNDV-Ac-3ucmooXAIaeGtIZvEx9RRXDZipVO5dt4iBc5IKGRjTPy-Hv7MlJR4Bm2sABA3beS8HfDrZOI2qipHwX9ACC3sY2IBOwYCTtkNFBWibA',
                      width: 32,
                      height: 32,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Ứng dụng Đặt xe',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF151C27),
                          ),
                        ),
                        Text(
                          'Trang Chu',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF3D4A3D),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_none, color: Color(0xFF3D4A3D)),
                          onPressed: () {},
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFBA1A1A), // error
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    const CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuA9IemJmH933gvRAYYaGwkGpH-wCYhxIiuIvaH88MrGxGbgJulDuQHxXnZAYDyiTMwMlRIuQf4ultYsx-XyOUBj3n-LK5MLe718QxkVbpgX9Wvvp-2SnOnQu27m1dWG3e_8-7ArcUU7ISNHnn-4AOWuZGirN7RFY4Ucf0JGV4VS1drYMoLieC_vTjEsTfyh6L0nJ_r3GwwfhZadPqhoPxjI35fcUDPrpKFg91Ix_kUSbzSycx9wZ0Q'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // 2. Nội dung chính: Map + Bottom Sheet
        Positioned.fill(
          top: MediaQuery.of(context).padding.top + 56, // Dưới Header
          child: Stack(
            children: [
              // --- Bản đồ ---
              Positioned.fill(
                bottom: 100, // Để chừa khoảng trống cho DraggableSheet không bị đè mất
                child: RealMapWidget(
                  onLocationSelected: (latLng) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã chọn vị trí: ${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}')),
                    );
                  },
                ),
              ),

              // --- Bottom Sheet (Có thể kéo lên xuống) ---
              DraggableScrollableSheet(
                initialChildSize: 0.45,
                minChildSize: 0.35,
                maxChildSize: 0.85,
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -4)),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.zero,
                      children: [
                        // Handle notch
                        Center(
                          child: Container(
                            width: 40,
                            height: 6,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCE2F3),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        
                        // Header "Bạn muốn đi đâu hôm nay?"
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: const Text(
                                'Bạn muốn đi đâu hôm nay?',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF87FB9D), // secondary-container
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Giá ưu đãi',
                                style: TextStyle(
                                  color: Color(0xFF007433),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Form đặt xe
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F3FF), // surface-container-low
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              // Điểm đón
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/customer/booking'),
                                child: Row(
                                  children: [
                                    const Icon(Icons.radio_button_checked, color: Color(0xFF006E2E), size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: const [
                                          Text('Điểm đón', style: TextStyle(color: Color(0xFF3D4A3D), fontSize: 11)),
                                          Text(
                                            'Chạm để chọn điểm đón',
                                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFE7EEFE),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.edit_location_alt, size: 16, color: Color(0xFF3D4A3D)),
                                    ),
                                  ],
                                ),
                              ),
                              // Dấu chấm nổi
                              Padding(
                                padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(width: 4, height: 12, decoration: BoxDecoration(color: const Color(0xFFDCE2F3), borderRadius: BorderRadius.circular(2))),
                                ),
                              ),
                              // Điểm đến
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/customer/booking'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.location_on, color: Color(0xFFBA1A1A), size: 22),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Điểm đến', style: TextStyle(color: Color(0xFFBA1A1A), fontSize: 11, fontWeight: FontWeight.w600)),
                                            Text('Nhập điểm bạn muốn đến...', style: TextStyle(color: Color(0xFF6D7B6C), fontSize: 15, fontWeight: FontWeight.w700)),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.search, color: Color(0xFF3D4A3D), size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        const SizedBox(height: 24),

                        // Nút Đặt xe ngay
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/customer/booking'),
                            icon: const Icon(Icons.electric_bolt, color: Colors.white, size: 22),
                            label: const Text('Đặt xe ngay', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00B14F), // primary-container
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 4,
                            ),
                          ),
                        ),
                        
                        // Spacer dưới cùng
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapBtn(IconData icon, Color iconColor) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: 20),
        onPressed: () {},
      ),
    );
  }

  Widget _buildLocationChip(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF151C27)),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))),
            ],
          ),
        ],
      ),
    );
  }
}
