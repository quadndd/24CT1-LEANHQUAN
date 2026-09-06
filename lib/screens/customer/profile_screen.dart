import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../../core/theme.dart';
import '../../core/auth_service.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  String _fullname = 'Đang tải...';
  String _phone = '';
  String _email = 'Chưa cập nhật email';
  String _avatar = 'https://lh3.googleusercontent.com/aida-public/AB6AXuA9IemJmH933gvRAYYaGwkGpH-wCYhxIiuIvaH88MrGxGbgJulDuQHxXnZAYDyiTMwMlRIuQf4ultYsx-XyOUBj3n-LK5MLe718QxkVbpgX9Wvvp-2SnOnQu27m1dWG3e_8-7ArcUU7ISNHnn-4AOWuZGirN7RFY4Ucf0JGV4VS1drYMoLieC_vTjEsTfyh6L0nJ_r3GwwfhZadPqhoPxjI35fcUDPrpKFg91Ix_kUSbzSycx9wZ0Q';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await AuthService.getSavedUsername();
    final phone = await AuthService.getSavedPhone();
    
    // Tạm thời lấy email/avatar từ database giả định, cần update Auth để lấy thật sau
    
    if (mounted) {
      setState(() {
        _fullname = name ?? 'Người dùng';
        _phone = phone ?? '';
        
        if (_phone.length >= 10) {
          _phone = '${_phone.substring(0, 4)} ••• ${_phone.substring(_phone.length - 3)}';
        }
      });
    }
  }

  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: _fullname == 'Người dùng' ? '' : _fullname);
    final emailCtrl = TextEditingController(text: _email == 'Chưa cập nhật email' ? '' : _email);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24, right: 24, top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Chỉnh sửa Hồ sơ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: 'Tên hiển thị', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _fullname = nameCtrl.text.isNotEmpty ? nameCtrl.text : 'Người dùng';
                      _email = emailCtrl.text.isNotEmpty ? emailCtrl.text : 'Chưa cập nhật email';
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật (Bản Demo)')));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006E2E)),
                  child: const Text('Lưu thay đổi', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
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
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine which ImageProvider to use
    final ImageProvider avatarProvider = _avatar.startsWith('data:image') 
      ? MemoryImage(base64Decode(_avatar.split(',')[1])) as ImageProvider
      : NetworkImage(_avatar);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // AppBar
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              pinned: true,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: const BoxDecoration(color: Color(0xFF006E2E), shape: BoxShape.circle),
                    child: const Icon(Icons.directions_car, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Ứng dụng Đặt xe', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF151C27))),
                      Text('Trang Chủ', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))),
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

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Profile Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Stack(
                                children: [
                                  GestureDetector(
                                    onTap: _showAvatarDialog,
                                    child: Container(
                                      width: 64, height: 64,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(colors: [Color(0xFF006E2E), Color(0xFF71FE91)]),
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(2),
                                      child: CircleAvatar(backgroundImage: avatarProvider),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0, right: 0,
                                    child: Container(width: 24, height: 24, decoration: const BoxDecoration(color: Color(0xFF006E2E), shape: BoxShape.circle), child: const Icon(Icons.verified, color: Colors.white, size: 14)),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(_fullname, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        ),
                                        const SizedBox(width: 8),
                                        InkWell(
                                          onTap: _showEditProfileDialog,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(20)),
                                            child: const Row(children: [Icon(Icons.edit, size: 15, color: Color(0xFF006E2E)), SizedBox(width: 4), Text('Sửa', style: TextStyle(fontSize: 11, color: Color(0xFF006E2E)))]),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(_phone, style: const TextStyle(fontSize: 14, color: Color(0xFF3D4A3D))),
                                    Text(_email, style: const TextStyle(fontSize: 11, color: Color(0xFF6D7B6C))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: const Color(0xFFF0F3FF).withOpacity(0.7), borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(children: [
                                      Container(width: 24, height: 24, decoration: const BoxDecoration(color: Color(0xFF87FB9D), shape: BoxShape.circle), child: const Icon(Icons.workspace_premium, size: 16, color: Color(0xFF007433))),
                                      const SizedBox(width: 6),
                                      const Text('Thành viên Vàng', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                    ]),
                                    const Text('850 / 1.000 điểm', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF006E2E))),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ClipRRect(borderRadius: BorderRadius.circular(4), child: const LinearProgressIndicator(value: 0.85, minHeight: 8, backgroundColor: Color(0xFFE2E8F8), valueColor: AlwaysStoppedAnimation(Color(0xFF00B14F)))),
                                const SizedBox(height: 8),
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text('Còn 150 điểm để thăng hạng Bạch Kim', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D)), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ),
                                    SizedBox(width: 8),
                                    Text('Chi tiết >', style: TextStyle(fontSize: 11, color: Color(0xFF006E2E))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Bento Tiles
                  Row(
                    children: [
                      _buildBentoTile(Icons.account_balance_wallet, const Color(0xFF87FB9D), 'Ví liên kết', '350.000đ', 'Nạp ví'),
                      const SizedBox(width: 10),
                      _buildBentoTile(Icons.confirmation_number, const Color(0xFFE7EEFE), 'Ưu đãi của tôi', '5 mã giảm', 'Dùng ngay'),
                      const SizedBox(width: 10),
                      _buildBentoTile(Icons.loyalty, const Color(0xFFE7EEFE), 'Điểm thưởng', '850 xu', 'Đổi quà'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Menu Groups
                  _buildMenuGroup('Chuyến đi & Thanh toán', [
                    _buildMenuItem(Icons.history, 'Lịch sử chuyến đi', 'Tất cả cuốc xe & hoá đơn điện tử VAT', null, onTap: () => Navigator.pushNamed(context, '/customer/trips')),
                    _buildMenuItem(Icons.credit_card, 'Phương thức thanh toán', 'Visa, MoMo, ZaloPay & Tiền mặt', '3 thẻ', onTap: () => Navigator.pushNamed(context, '/customer/payments')),
                    _buildMenuItem(Icons.bookmark, 'Địa điểm đã lưu', 'Nhà riêng, Cơ quan, Điểm hẹn thường đến', null, onTap: () => Navigator.pushNamed(context, '/customer/saved-locations')),
                  ]),
                  const SizedBox(height: 16),

                  _buildMenuGroup('An toàn & Hỗ trợ', [
                    _buildMenuItem(Icons.shield, 'Trung tâm An toàn chuyến đi', 'Chia sẻ lộ trình người thân, trợ giúp SOS 24/7', 'dot'),
                    _buildMenuItem(Icons.help_center, 'Trợ giúp & Khiếu nại', 'Hỏi đáp thường gặp, hỗ trợ hoàn tiền cuốc xe', null),
                  ]),
                  const SizedBox(height: 16),
                  
                  _buildMenuGroup('Cài đặt & Tiện ích', [
                    _buildMenuItem(Icons.tune, 'Cài đặt ứng dụng', 'Ngôn ngữ Tiếng Việt, Face ID, Thông báo', null, isDarkIcon: true, onTap: () => Navigator.pushNamed(context, '/customer/settings')),
                    _buildMenuItem(Icons.policy, 'Chính sách & Điều khoản', 'Bảo vệ dữ liệu cá nhân & quy chế hoạt động', null, isDarkIcon: true),
                  ]),
                  const SizedBox(height: 24),

                  // Logout
                  SizedBox(
                    width: double.infinity, height: 56,
                    child: ElevatedButton(
                      onPressed: () => _handleLogout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFDAD6).withOpacity(0.6),
                        foregroundColor: const Color(0xFFBA1A1A),
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
                  const SizedBox(height: 16),
                  const Text('Phiên bản v2.4.0 (Flutter Mobile Build)', style: TextStyle(fontSize: 11, color: Color(0xFF6D7B6C))),
                  const Text('Ứng dụng Đặt xe - An toàn trên mọi cung đường', style: TextStyle(fontSize: 11, color: Color(0xFF6D7B6C))),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF006E2E),
        unselectedItemColor: const Color(0xFF6D7B6C),
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Chuyến đi'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), activeIcon: Icon(Icons.notifications), label: 'Thông báo'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Cá nhân'),
        ],
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/customer/home');
          if (index == 1) Navigator.pushReplacementNamed(context, '/customer/trips');
          if (index == 2) Navigator.pushReplacementNamed(context, '/customer/notifications');
        },
      ),
    );
  }

  Widget _buildBentoTile(IconData icon, Color iconBg, String title, String value, String action) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 32, height: 32, decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle), child: Icon(icon, color: const Color(0xFF006E2E), size: 18)),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF151C27))),
            const SizedBox(height: 8),
            Row(children: [
              Text(action, style: const TextStyle(fontSize: 11, color: Color(0xFF006E2E))),
              const Icon(Icons.arrow_forward, size: 12, color: Color(0xFF006E2E)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGroup(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF3D4A3D), letterSpacing: 1.0)),
        ),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, String? trailing, {bool isDarkIcon = false, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(width: 32, height: 32, decoration: const BoxDecoration(color: Color(0xFFE7EEFE), shape: BoxShape.circle), child: Icon(icon, size: 20, color: isDarkIcon ? const Color(0xFF3D4A3D) : const Color(0xFF006E2E))),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF151C27))),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF3D4A3D)), maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: trailing == 'dot' 
        ? const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.circle, size: 8, color: Color(0xFF006E2E)), SizedBox(width: 4), Icon(Icons.chevron_right)])
        : trailing != null 
          ? Row(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF87FB9D).withOpacity(0.5), borderRadius: BorderRadius.circular(20)), child: Text(trailing, style: const TextStyle(fontSize: 11, color: Color(0xFF006E2E)))), const SizedBox(width: 4), const Icon(Icons.chevron_right)])
          : const Icon(Icons.chevron_right),
    );
  }
}
