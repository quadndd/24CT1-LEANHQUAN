import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme.dart';
import '../../core/auth_service.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  String _fullname = 'Đang tải...';
  String _phone = '';
  String _email = 'driver@example.com';
  String _licensePlate = '...';
  String _licenseNumber = 'Đang tải...';
  String _avatar = 'https://lh3.googleusercontent.com/aida-public/AB6AXuBcB6uHyYEU_xr6DEBl4XDbCaR2T_IUrX2ZvjTcafV3yUJMctgzZBGZwbEAykn9A-78ZYd0E5TXtUJ705T4b57S4jpCYEv5w21xQYh9s0wfQtlXWNv9mHSxDPQXDvOW734cp8YSD7L6th4MzpnSzlvguzm8CrOP3OuOXhAWhLVDJDuqoKs8OjA8EG8W7eXukmKbOvrSzTbiO9Grld-lb10dkRe05sInKX2Ri4nbhBhlYa_jo4EZUyA';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('id');
    final name = prefs.getString('username');
    final phone = prefs.getString('phone');
    
    if (userId != null) {
      try {
        final profile = await Supabase.instance.client
            .from('driver_profiles')
            .select()
            .eq('user_id', userId)
            .maybeSingle();
            
        if (profile != null && mounted) {
          setState(() {
            _fullname = name ?? 'Tài xế';
            _phone = phone ?? '';
            if (_phone.length >= 10) _phone = '${_phone.substring(0, 4)} ${_phone.substring(4, 7)} ${_phone.substring(7)}';
            
            _email = profile['email'] ?? 'Chưa cập nhật email';
            _licensePlate = profile['license_plate'] ?? 'Chưa có biển số';
            _licenseNumber = profile['license_number'] != null ? 'GPLX: ${profile['license_number']}' : 'Chưa cập nhật GPLX';
            if (profile['face_image'] != null) {
              _avatar = profile['face_image'];
            }
          });
          return;
        }
      } catch (e) {
        // Fallback
      }
    }
    
    if (mounted) {
      setState(() {
        _fullname = name ?? 'Tài xế';
        _phone = phone ?? '';
        if (_phone.length >= 10) _phone = '${_phone.substring(0, 4)} ${_phone.substring(4, 7)} ${_phone.substring(7)}';
      });
    }
  }

  void _showAvatarDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _avatar.startsWith('data:image') 
                ? Image.memory(base64Decode(_avatar.split(',')[1]), width: 300, height: 300, fit: BoxFit.cover)
                : Image.network(_avatar, width: 300, height: 300, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final picker = ImagePicker();
                final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50, maxWidth: 500);
                if (image != null) {
                  final bytes = await image.readAsBytes();
                  final base64String = "data:image/jpeg;base64,${base64Encode(bytes)}";
                  setState(() {
                    _avatar = base64String;
                  });
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật ảnh đại diện')));
                  }
                }
              },
              icon: const Icon(Icons.photo_camera, color: Colors.white),
              label: const Text('Thay đổi Avatar', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006E2E)),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    await AuthService.clearSession();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ImageProvider avatarProvider = _avatar.startsWith('data:image') 
      ? MemoryImage(base64Decode(_avatar.split(',')[1])) as ImageProvider
      : NetworkImage(_avatar);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 1,
        title: Row(
          children: [
            const Icon(Icons.drive_eta, color: Color(0xFF006E2E)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Tài xế', style: TextStyle(fontSize: 10, color: Color(0xFF3D4A3D), letterSpacing: 0.8)),
                Text('Cá Nhân', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF151C27))),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications, color: Color(0xFF3D4A3D)), onPressed: () {}),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _showAvatarDialog,
              child: CircleAvatar(
                radius: 16,
                backgroundImage: avatarProvider,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Driver Hero Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
              child: Column(
                children: [
                  Row(
                    children: [
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: _showAvatarDialog,
                            child: CircleAvatar(
                              radius: 32,
                              backgroundImage: avatarProvider,
                            ),
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: Container(
                              width: 20, height: 20,
                              decoration: BoxDecoration(color: const Color(0xFF006E2E), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                              child: const Icon(Icons.check, color: Colors.white, size: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_fullname, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF151C27))),
                            const Row(
                              children: [
                                Icon(Icons.verified, size: 14, color: Color(0xFF006E2E)),
                                SizedBox(width: 4),
                                Text('Đối tác Tài xế Tiêu Biểu', style: TextStyle(fontSize: 11, color: Color(0xFF006E2E))),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('$_phone • $_email', style: const TextStyle(fontSize: 14, color: Color(0xFF3D4A3D))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Stats
                  Row(
                    children: [
                      _buildStatBox(Icons.star, const Color(0xFFEAB308), '4.98', '1.420 đánh giá'),
                      const SizedBox(width: 8),
                      _buildStatBox(Icons.touch_app, const Color(0xFF006E2E), '99%', 'Chấp nhận'),
                      const SizedBox(width: 8),
                      _buildStatBox(Icons.do_not_disturb_on, const Color(0xFF006D2F), '0.8%', 'Tỉ lệ hủy'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Vehicle Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(width: 32, height: 32, decoration: BoxDecoration(color: const Color(0xFFE2E8F8), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.directions_car, color: Color(0xFF006E2E))),
                          const SizedBox(width: 8),
                          const Text('Phương tiện hoạt động', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFF006E2E).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                        child: const Row(children: [Icon(Icons.verified, size: 12, color: Color(0xFF006E2E)), SizedBox(width: 4), Text('Hợp lệ', style: TextStyle(fontSize: 11, color: Color(0xFF006E2E)))]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Toyota Vios', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFE7EEFE), borderRadius: BorderRadius.circular(4)), child: const Text('Đã xác thực', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D)))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              const Text('BIỂN SỐ:', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))),
                              const SizedBox(width: 8),
                              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)), child: Text(_licensePlate, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 1.0))),
                            ]),
                            const Row(children: [Icon(Icons.task_alt, size: 15, color: Color(0xFF006E2E)), SizedBox(width: 4), Text('Đã duyệt', style: TextStyle(fontSize: 11, color: Color(0xFF006E2E)))]),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Menu Options
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
              child: Column(
                children: [
                  _buildMenuItem(Icons.badge, 'Thông tin cá nhân & Giấy phép lái xe', _licenseNumber),
                  _buildMenuItem(Icons.minor_crash, 'Hồ sơ phương tiện & Bảo hiểm xe', 'Bảo hiểm bắt buộc & tự nguyện TNDS'),
                  _buildMenuItem(Icons.account_balance_wallet, 'Phương thức & tài khoản đã lưu', 'Quản lý thẻ, ví điện tử liên kết'),
                  _buildMenuItem(Icons.settings, 'Cài đặt ứng dụng', 'Ngôn ngữ, Thông báo, Vị trí, Bảo mật', isDark: true, onTap: () => Navigator.pushNamed(context, '/customer/settings')),
                  _buildMenuItem(Icons.security, 'Trung tâm An toàn & Cuộc gọi khẩn cấp SOS', 'Hỗ trợ khẩn cấp 113 & Định vị trực tiếp', isError: true),
                  _buildMenuItem(Icons.support_agent, 'Trợ giúp & Hỗ trợ tài xế (24/7)', 'Tổng đài đối tác, gửi yêu cầu sự cố', isDark: true),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Logout
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(
                onPressed: () => _handleLogout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFDAD6),
                  foregroundColor: const Color(0xFF93000A),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.logout, size: 20),
                  SizedBox(width: 8),
                  Text('Đăng xuất tài khoản', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Phiên bản tài xế 4.28.0 (Build 9042)', style: TextStyle(fontSize: 11, color: Color(0xFF6D7B6C))),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
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
          if (index == 0) Navigator.pushReplacementNamed(context, '/driver/home');
          if (index == 1) Navigator.pushReplacementNamed(context, '/driver/trips');
          if (index == 2) Navigator.pushReplacementNamed(context, '/driver/earnings');
        },
      ),
    );
  }

  Widget _buildStatBox(IconData icon, Color iconColor, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: iconColor),
                const SizedBox(width: 4),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF151C27))),
              ],
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, {bool isDark = false, bool isError = false, VoidCallback? onTap}) {
    Color iconColor = isError ? const Color(0xFFBA1A1A) : (isDark ? const Color(0xFF3D4A3D) : const Color(0xFF006E2E));
    Color bgColor = isError ? const Color(0xFFFFDAD6) : const Color(0xFFF0F3FF);
    Color subColor = isError ? const Color(0xFFBA1A1A) : const Color(0xFF3D4A3D);

    return ListTile(
      onTap: onTap,
      leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 20, color: iconColor)),
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF151C27))),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: subColor)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Color(0xFF6D7B6C)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
