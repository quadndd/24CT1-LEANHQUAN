// ============================================================
// home_screen.dart — Trang chủ Tài xế
// Chờ nhận chuyến mới qua Supabase Realtime
// Hiển thị bản đồ GPS thực, trạng thái online/offline và thông tin tài xế
// ============================================================
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
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
  
  RealtimeChannel? _ridesChannel;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    if (isOnline) {
      _startRealtimeListener();
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
      } catch (e) {}
    }
    
    if (mounted && name != null) {
      setState(() {
        _driverName = name;
      });
    }
  }

  void _startRealtimeListener() {
    if (!mounted || !isOnline) return;
    
    _ridesChannel?.unsubscribe();
    _ridesChannel = Supabase.instance.client
        .channel('public:rides')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'rides',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'status',
            value: 'pending',
          ),
          callback: (payload) async {
            if (!isOnline) return;
            final newRide = payload.newRecord;
            if (newRide.isNotEmpty) {
              final pickupStr = newRide['pickup_location']?.toString() ?? '';
              final parts = pickupStr.split('|');
              
              if (parts.length >= 3) {
                try {
                  final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                  final plat = double.tryParse(parts[1]) ?? 0.0;
                  final plng = double.tryParse(parts[2]) ?? 0.0;
                  final dist = Geolocator.distanceBetween(
                    position.latitude, position.longitude,
                    plat, plng,
                  );
                  // Bỏ qua nếu cách xa hơn 5km
                  if (dist > 5000) return;
                } catch (e) {
                  debugPrint('Lỗi lấy vị trí: $e');
                }
              }
              _showIncomingRideDialog(newRide);
            }
          },
        )
        .subscribe();
  }

  void _stopRealtimeListener() {
    _ridesChannel?.unsubscribe();
    _ridesChannel = null;
  }

  Future<void> _scanForExistingRides() async {
    try {
      final pendingRides = await Supabase.instance.client
          .from('rides')
          .select()
          .eq('status', 'pending');
      
      if (pendingRides.isNotEmpty) {
        final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        for (var ride in pendingRides) {
          final pickupStr = ride['pickup_location']?.toString() ?? '';
          final parts = pickupStr.split('|');
          if (parts.length >= 3) {
            final plat = double.tryParse(parts[1]) ?? 0.0;
            final plng = double.tryParse(parts[2]) ?? 0.0;
            final dist = Geolocator.distanceBetween(
              position.latitude, position.longitude,
              plat, plng,
            );
            if (dist <= 5000) {
              _showIncomingRideDialog(ride);
              return; // Chỉ hiện 1 cuốc xe
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Lỗi quét cuốc cũ: $e');
    }
  }

  void _showIncomingRideDialog(Map<String, dynamic> ride) {
    if (!mounted) return;
    
    String pickup = ride['pickup_location']?.toString().split('|')[0] ?? 'Điểm đón';
    String dropoff = ride['dropoff_location']?.toString().split('|')[0] ?? 'Điểm đến';
    String price = ride['amount'] != null ? '${ride['amount'].toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')} đ' : 'Thỏa thuận';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('CUỐC XE MỚI!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF006E2E))),
            const SizedBox(height: 16),
            
            // Pickup
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 24, height: 24, decoration: const BoxDecoration(color: Color(0xFF00B14F), shape: BoxShape.circle), child: const Icon(Icons.trip_origin, size: 14, color: Colors.white)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('ĐIỂM ĐÓN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF3D4A3D))),
                Text(pickup, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ])),
            ]),
            const SizedBox(height: 12),
            
            // Dropoff
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 24, height: 24, decoration: const BoxDecoration(color: Color(0xFFBA1A1A), shape: BoxShape.circle), child: const Icon(Icons.location_on, size: 14, color: Colors.white)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('ĐIỂM ĐẾN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF3D4A3D))),
                Text(dropoff, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ])),
            ]),
            const SizedBox(height: 20),
            
            // Price
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: Column(
                  children: [
                    const Text('Thu nhập dự kiến', style: TextStyle(fontSize: 13, color: Color(0xFF3D4A3D))),
                    Text(price, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF006E2E))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: Color(0xFF3D4A3D)),
                    ),
                    child: const Text('BỎ QUA', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF3D4A3D))),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      _acceptRide(ride['id']);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF00B14F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('NHẬN CUỐC', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptRide(int rideId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('id');
      if (userId == null) return;
      
      final updateResponse = await Supabase.instance.client.from('rides').update({
        'status': 'accepted',
        'driver_id': userId,
      }).eq('id', rideId).eq('status', 'pending').select().maybeSingle();
      
      if (updateResponse == null) {
        throw Exception('Chuyến xe đã bị nhận bởi người khác!');
      }
      
      if (mounted) {
        Navigator.pushNamed(context, '/driver/active-ride', arguments: rideId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  void dispose() {
    _stopRealtimeListener();
    super.dispose();
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
                Positioned.fill(
                  bottom: 220,
                  child: const RealMapWidget(),
                ),
                
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
                                    if (isOnline) Container(width: 10, height: 10, margin: const EdgeInsets.only(right: 8), decoration: const BoxDecoration(color: Color(0xFF00B14F), shape: BoxShape.circle)),
                                    Text(isOnline ? 'ĐANG HOẠT ĐỘNG' : 'ĐANG NGHỈ NGƠI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isOnline ? const Color(0xFF151C27) : const Color(0xFF3D4A3D))),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(isOnline ? 'Sẵn sàng nhận chuyến mới quanh khu vực của bạn' : 'Bật trực tuyến để tiếp tục nhận cuốc xe', style: const TextStyle(fontSize: 13, color: Color(0xFF3D4A3D))),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (!isOnline) {
                                // Kiểm tra xem có bị khóa do nợ không trước khi bật
                                final prefs = await SharedPreferences.getInstance();
                                final userId = prefs.getString('id');
                                if (userId != null) {
                                  final profile = await Supabase.instance.client
                                      .from('driver_profiles')
                                      .select('is_locked_by_debt')
                                      .eq('user_id', userId)
                                      .maybeSingle();
                                      
                                  if (profile != null && profile['is_locked_by_debt'] == true) {
                                    if (mounted) {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Tài khoản bị tạm khóa'),
                                          content: const Text('Vui lòng thanh toán công nợ trong Ví tài xế để tiếp tục nhận chuyến!'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ĐÓNG'))
                                          ],
                                        )
                                      );
                                    }
                                    return; // Bị khóa, không cho bật
                                  }
                                }
                              }

                              setState(() => isOnline = !isOnline);
                              if (isOnline) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Đang tìm kiếm cuốc xe gần bạn...')),
                                );
                                _startRealtimeListener();
                                _scanForExistingRides();
                              } else {
                                _stopRealtimeListener();
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
                        Row(
                          children: [
                            Expanded(child: _buildFilterBtn(Icons.near_me, const Color(0xFF006E2E), 'Điểm đến ưu tiên', 'Về nhà (Bình Thạnh)')),
                            const SizedBox(width: 12),
                            Expanded(child: _buildFilterBtn(Icons.radar, const Color(0xFF006D2F), 'Bán kính quét', '5.0 km')),
                          ],
                        ),
                        const SizedBox(height: 12),
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
