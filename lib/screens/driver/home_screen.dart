import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme.dart';
import '../../widgets/real_map_widget.dart';
import '../../core/auth_service.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  static bool isOnline = false;
  bool _trafficVisible = true;
  String _driverName = 'Tài xế';
  String _avatar = 'https://lh3.googleusercontent.com/aida-public/AB6AXuBcB6uHyYEU_xr6DEBl4XDbCaR2T_IUrX2ZvjTcafV3yUJMctgzZBGZwbEAykn9A-78ZYd0E5TXtUJ705T4b57S4jpCYEv5w21xQYh9s0wfQtlXWNv9mHSxDPQXDvOW734cp8YSD7L6th4MzpnSzlvguzm8CrOP3OuOXhAWhLVDJDuqoKs8OjA8EG8W7eXukmKbOvrSzTbiO9Grld-lb10dkRe05sInKX2Ri4nbhBhlYa_jo4EZUyA';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    if (isOnline) {
      _startAutoDispatch();
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('id');
    final name = prefs.getString('username');
    
    if (userId != null) {
      try {
        final profile = await Supabase.instance.client
            .from('driver_profiles')
            .select('face_image')
            .eq('user_id', userId)
            .maybeSingle();
        if (profile != null && profile['face_image'] != null && mounted) {
          setState(() {
            _driverName = name ?? 'Tài xế';
            _avatar = profile['face_image'];
          });
          return;
        }
      } catch (e) {
        // fallback
      }
    }
    
    if (mounted && name != null) {
      setState(() {
        _driverName = name;
      });
    }
  }

  void _startAutoDispatch() {
    if (!mounted || !isOnline) return;
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && isOnline) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Đã tự động nhận chuyến mới!'), backgroundColor: Color(0xFF00B14F), duration: Duration(seconds: 2)),
        );
        Navigator.pushNamed(context, '/driver/active-ride');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          // AppBar
          SliverAppBar(
            backgroundColor: Colors.white.withOpacity(0.9),
            pinned: true,
            elevation: 1,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                const Icon(Icons.drive_eta, color: Color(0xFF006E2E)),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('TÀI XẾ', style: TextStyle(fontSize: 10, color: Color(0xFF3D4A3D), letterSpacing: 1.0)),
                    Text('Trang Chủ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF151C27))),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(icon: const Icon(Icons.bug_report, color: Colors.red), onPressed: () => Navigator.pushNamed(context, '/driver/ride-request')),
              IconButton(icon: const Icon(Icons.notifications, color: Color(0xFF3D4A3D)), onPressed: () {}),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: _avatar.startsWith('data:image') 
                    ? MemoryImage(base64Decode(_avatar.split(',')[1])) as ImageProvider
                    : NetworkImage(_avatar),
                ),
              ),
            ],
          ),

          SliverFillRemaining(
            child: Stack(
              children: [
                // Bản đồ (chiếm phần lớn màn hình)
                Positioned.fill(
                  bottom: 220,
                  child: const RealMapWidget(), // Thay thế bằng bản đồ có radar
                ),
                
                // Overlays trên bản đồ
                Positioned(
                  top: 16, left: 16, right: 16,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
                          ),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(radius: 20, backgroundImage: _avatar.startsWith('data:image') ? MemoryImage(base64Decode(_avatar.split(',')[1])) as ImageProvider : NetworkImage(_avatar)),
                                  Positioned(bottom: 0, right: 0, child: Container(width: 12, height: 12, decoration: BoxDecoration(color: const Color(0xFF006E2E), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [Text(_driverName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(width: 4), const Icon(Icons.verified, size: 16, color: Color(0xFF006E2E))]),
                                    const SizedBox(height: 4),
                                    Row(children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: const Color(0xFF87FB9D), borderRadius: BorderRadius.circular(12)),
                                        child: const Row(children: [Text('★ 4.9', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF002109))), Text(' • 1.420 chuyến', style: TextStyle(fontSize: 11, color: Color(0xFF002109)))]),
                                      ),
                                    ]),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(color: const Color(0xFFE7EEFE), borderRadius: BorderRadius.circular(24)),
                        child: const Icon(Icons.volume_up, color: Color(0xFF3D4A3D)),
                      ),
                    ],
                  ),
                ),

                // Trạng thái hoạt động
                Positioned(
                  top: 90, left: 16, right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Row(
                                  children: [
                                    if (isOnline) Container(width: 10, height: 10, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(color: const Color(0xFF00B14F), shape: BoxShape.circle)),
                                    Text(isOnline ? 'ĐANG HOẠT ĐỘNG' : 'ĐANG NGHỈ NGƠI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isOnline ? const Color(0xFF151C27) : const Color(0xFF3D4A3D))),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(isOnline ? 'Sẵn sàng nhận chuyến mới quanh Quận 1, TP.HCM' : 'Bật trực tuyến để tiếp tục nhận cuốc xe', style: const TextStyle(fontSize: 13, color: Color(0xFF3D4A3D))),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() => isOnline = !isOnline);
                              if (isOnline) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Đang tìm kiếm cuốc xe gần bạn...')),
                                );
                                _startAutoDispatch();
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 64, height: 36,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isOnline ? const Color(0xFF00B14F) : const Color(0xFFDCE2F3),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: AnimatedAlign(
                                duration: const Duration(milliseconds: 300),
                                alignment: isOnline ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  width: 28, height: 28,
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)]),
                                  child: Icon(Icons.power_settings_new, size: 16, color: isOnline ? const Color(0xFF006E2E) : const Color(0xFF5F5E5E)),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Floating Map Controls
                Positioned(
                  right: 16, top: 180,
                  child: Column(
                    children: [
                      _buildMapButton(Icons.traffic, _trafficVisible ? const Color(0xFF87FB9D) : Colors.white54, () => setState(() => _trafficVisible = !_trafficVisible)),
                      const SizedBox(height: 10),
                      _buildMapButton(Icons.my_location, const Color(0xFF71FE91), () {}),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(color: const Color(0xFF2A313D).withOpacity(0.85), borderRadius: BorderRadius.circular(24)),
                        child: Column(
                          children: [
                            IconButton(icon: const Icon(Icons.add, color: Colors.white), onPressed: () {}),
                            Container(width: 24, height: 1, color: Colors.white24),
                            IconButton(icon: const Icon(Icons.remove, color: Colors.white), onPressed: () {}),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 48, height: 48,
                        decoration: const BoxDecoration(color: Color(0xFF87FB9D), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                        child: const Center(child: Text('+1.4x', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF007433)))),
                      ),
                    ],
                  ),
                ),

                // (Đã xóa Quick Stats Pill chứa dữ liệu ảo theo yêu cầu)

                // Bottom Cockpit
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    height: 220,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, -4))],
                    ),
                    child: Column(
                      children: [
                        // Auto-Dispatch
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFF71FE91), shape: BoxShape.circle), child: const Icon(Icons.bolt, color: Color(0xFF002109))),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(children: [const Expanded(child: Text('Tự động nhận cuốc', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)), const SizedBox(width: 4), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF006E2E), borderRadius: BorderRadius.circular(12)), child: const Text('BẬT', style: TextStyle(fontSize: 11, color: Colors.white)))]),
                                          const SizedBox(height: 2),
                                          const Text('Ưu tiên chuyến gần nhất', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D)), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.tune, color: Color(0xFF3D4A3D)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Filters
                        Row(
                          children: [
                            Expanded(child: _buildFilterBtn(Icons.near_me, const Color(0xFF006E2E), 'Điểm đến ưu tiên', 'Về nhà (Bình Thạnh)')),
                            const SizedBox(width: 12),
                            Expanded(child: _buildFilterBtn(Icons.radar, const Color(0xFF006D2F), 'Bán kính quét', '5.0 km')),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Banner
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(color: const Color(0xFFDCE2F3), borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: const [
                                    Icon(Icons.local_fire_department, size: 20, color: Color(0xFF006E2E)), 
                                    SizedBox(width: 8), 
                                    Expanded(child: Text('Khu vực Quận 1 đang có nhu cầu đặt xe cao', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                  ]
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('Xem bản đồ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF006E2E))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF006E2E),
        unselectedItemColor: const Color(0xFF3D4A3D),
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Chuyến xe'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Thu nhập'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
        ],
        onTap: (index) {
          if (index == 1) Navigator.pushReplacementNamed(context, '/driver/trips');
          if (index == 2) Navigator.pushReplacementNamed(context, '/driver/earnings');
          if (index == 3) Navigator.pushReplacementNamed(context, '/driver/profile');
        },
      ),
    );
  }

  Widget _buildMapButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(color: const Color(0xFF2A313D).withOpacity(0.85), shape: BoxShape.circle, boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
        child: Icon(icon, color: color),
      ),
    );
  }

  Widget _buildFilterBtn(IconData icon, Color iconColor, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFE7EEFE), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))),
                Text(subtitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF3D4A3D)),
        ],
      ),
    );
  }
}
