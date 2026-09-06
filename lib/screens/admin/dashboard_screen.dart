import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/auth_service.dart';

/// Màn hình Admin Dashboard
/// Hoàn toàn độc lập, không có link nào sang màn hình khách hàng hay tài xế
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0; // 0 = Dashboard, 1 = Tài xế, 2 = Bản đồ, 3 = Thêm

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title: const Text(
          'GoRide VN – Admin',
          style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 18),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.grey200,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: const Icon(Icons.person,
                  color: AppColors.primary, size: 20),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _AdminDashboardTab(),
          _AdminDriversTab(),
          _AdminMapTab(),
          _AdminMoreTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Tổng quan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            activeIcon: Icon(Icons.group),
            label: 'Tài xế',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Bản đồ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'Thêm',
          ),
        ],
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey400,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB 0: Tổng quan (Dashboard)
// ─────────────────────────────────────────────
class _AdminDashboardTab extends StatelessWidget {
  const _AdminDashboardTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng quan hệ thống',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            'Thống kê hoạt động trong ngày hôm nay.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 20),

          // Thẻ thống kê chính – 2 cột
          const Row(
            children: [
              const Expanded(
                child: const _DashStatCard(
                  icon: Icons.people_outline,
                  iconColor: AppColors.primary,
                  iconBgColor: AppColors.accentLight,
                  label: 'Khách hàng',
                  value: '12.450',
                  subtitle: '+234 hôm nay',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _DashStatCard(
                  icon: Icons.drive_eta,
                  iconColor: Color(0xFF3B82F6),
                  iconBgColor: Color(0xFFEFF6FF),
                  label: 'Tài xế online',
                  value: '856',
                  subtitle: 'Trên tổng 1.245',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: _DashStatCard(
                  icon: Icons.route,
                  iconColor: Color(0xFF10B981),
                  iconBgColor: Color(0xFFECFDF5),
                  label: 'Chuyến hôm nay',
                  value: '3.240',
                  subtitle: '+18% so với hôm qua',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _DashStatCard(
                  icon: Icons.attach_money,
                  iconColor: Color(0xFFF59E0B),
                  iconBgColor: Color(0xFFFEF3C7),
                  label: 'Doanh thu',
                  value: '48.2M',
                  subtitle: 'VNĐ hôm nay',
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Chuyến đi đang hoạt động
          const Text(
            'Chuyến đi đang diễn ra',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          const _ActiveTripCard(
            driverName: 'Lê Văn Hùng',
            from: 'Vincom Center, Q.1',
            to: 'Sân bay TSN',
            status: 'Đang chở',
            statusColor: AppColors.primary,
          ),
          const SizedBox(height: 8),
          const _ActiveTripCard(
            driverName: 'Trần Thị Mai',
            from: 'Chợ Bến Thành, Q.1',
            to: 'Landmark 81',
            status: 'Đang đến đón',
            statusColor: Colors.orange,
          ),
          const _ActiveTripCard(
            driverName: 'Võ Thành Long',
            from: 'Nhà hàng Bến Nghé',
            to: 'ĐHBK HCM',
            status: 'Đang chở',
            statusColor: AppColors.primary,
          ),

          const SizedBox(height: 20),

          // Báo cáo sự cố
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber,
                    color: AppColors.error, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '4 báo cáo sự cố chờ xử lý',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.error),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Cần xem xét và xử lý kịp thời',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Xem',
                      style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String label;
  final String value;
  final String subtitle;

  const _DashStatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration:
                BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600),
          ),
          Text(
            subtitle,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ActiveTripCard extends StatelessWidget {
  final String driverName;
  final String from;
  final String to;
  final String status;
  final Color statusColor;

  const _ActiveTripCard({
    required this.driverName,
    required this.from,
    required this.to,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
                color: AppColors.grey100, shape: BoxShape.circle),
            child: const Icon(Icons.person, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driverName,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700),
                ),
                Text(
                  '$from → $to',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: statusColor),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB 1: Quản lý Tài xế
// ─────────────────────────────────────────────
class _AdminDriversTab extends StatefulWidget {
  const _AdminDriversTab();

  @override
  State<_AdminDriversTab> createState() => _AdminDriversTabState();
}

class _AdminDriversTabState extends State<_AdminDriversTab> {
  String _selectedFilter = 'Tất cả (1,245)';

  final List<String> _filters = [
    'Tất cả (1,245)',
    'Đang hoạt động (982)',
    'Chờ duyệt (45)',
    'Bị đình chỉ (12)',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quản lý tài xế',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            'Quản lý danh sách, trạng thái và hiệu suất của tài xế.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 16),

          // Nút hành động
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Xuất dữ liệu'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Thêm tài xế'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Tìm kiếm + Lọc
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo tên, SĐT, biển số...',
                    prefixIcon: Icon(Icons.search,
                        color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _filters.map((f) {
                    final isSelected = _selectedFilter == f;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedFilter = f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.grey300,
                          ),
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Thẻ thống kê
          const _StatCard(
            icon: Icons.directions_car,
            iconColor: AppColors.primary,
            iconBgColor: AppColors.accentLight,
            label: 'Tài xế đang online',
            value: '856',
          ),
          const SizedBox(height: 10),
          const _StatCard(
            icon: Icons.route,
            iconColor: Color(0xFF3B82F6),
            iconBgColor: Color(0xFFEFF6FF),
            label: 'Chuyến đi hôm nay',
            value: '3.240',
          ),
          const SizedBox(height: 10),
          const _StatCard(
            icon: Icons.star_outline,
            iconColor: Color(0xFF8B5CF6),
            iconBgColor: Color(0xFFF5F3FF),
            label: 'Đánh giá trung bình',
            value: '4.85',
          ),
          const SizedBox(height: 10),
          const _StatCard(
            icon: Icons.warning_amber,
            iconColor: AppColors.error,
            iconBgColor: AppColors.errorLight,
            label: 'Báo cáo sự cố',
            value: '4',
          ),

          const SizedBox(height: 20),

          const Text(
            'Danh sách tài xế',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          ...MockData.drivers.map((d) => _DriverCard(driver: d)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB 2: Bản đồ (placeholder)
// ─────────────────────────────────────────────
class _AdminMapTab extends StatelessWidget {
  const _AdminMapTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.map_outlined, size: 64, color: AppColors.grey300),
          SizedBox(height: 12),
          Text(
            'Bản đồ trực tiếp',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary),
          ),
          SizedBox(height: 4),
          Text(
            'Tính năng đang phát triển',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB 3: Thêm (tùy chọn admin)
// ─────────────────────────────────────────────
class _AdminMoreTab extends StatelessWidget {
  const _AdminMoreTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quản trị',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              children: [
                _AdminMoreTile(
                    icon: Icons.people,
                    label: 'Quản lý khách hàng',
                    onTap: () {}),
                const Divider(height: 1, indent: 72, color: AppColors.divider),
                _AdminMoreTile(
                    icon: Icons.local_offer,
                    label: 'Khuyến mãi & mã giảm giá',
                    onTap: () {}),
                const Divider(height: 1, indent: 72, color: AppColors.divider),
                _AdminMoreTile(
                    icon: Icons.bar_chart,
                    label: 'Báo cáo & phân tích',
                    onTap: () {}),
                const Divider(height: 1, indent: 72, color: AppColors.divider),
                _AdminMoreTile(
                    icon: Icons.settings,
                    label: 'Cấu hình hệ thống',
                    onTap: () {}),
                const Divider(height: 1, indent: 72, color: AppColors.divider),
                _AdminMoreTile(
                    icon: Icons.logout,
                    label: 'Đăng xuất',
                    color: AppColors.error,
                    onTap: () async {
                      await AuthService.clearSession();
                      if (!context.mounted) return;
                      Navigator.pushReplacementNamed(context, '/login');
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminMoreTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AdminMoreTile({
    required this.icon,
    required this.label,
    this.color = AppColors.textPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
            color: AppColors.grey100, shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20),
      ),
      title:
          Text(label, style: TextStyle(fontSize: 15, color: color, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right,
          color: AppColors.textSecondary),
    );
  }
}

// ─────────────────────────────────────────────
// Widgets dùng chung trong Admin
// ─────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration:
                BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  final MockDriver driver;

  const _DriverCard({required this.driver});

  Color get _statusColor {
    switch (driver.status) {
      case 'Đang hoạt động':
        return AppColors.success;
      case 'Chờ duyệt':
        return Colors.orange;
      case 'Bị đình chỉ':
        return AppColors.error;
      default:
        return AppColors.grey400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.grey300),
                ),
                child: const Icon(Icons.person,
                    color: AppColors.grey400, size: 26),
              ),
              if (driver.isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      driver.name,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        driver.status,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _statusColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(driver.phone,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 12),
                    const SizedBox(width: 3),
                    Text('${driver.rating}',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600)),
                    const Text(' • ',
                        style:
                            TextStyle(color: AppColors.textSecondary)),
                    Text(driver.vehicleType,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary)),
                    const Text(' • ',
                        style:
                            TextStyle(color: AppColors.textSecondary)),
                    Text('${driver.totalTrips} chuyến',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          IconButton(
            icon: const Icon(Icons.more_vert,
                color: AppColors.textSecondary, size: 20),
            onPressed: () => _showDriverActions(context, driver),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  void _showDriverActions(BuildContext context, MockDriver driver) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(driver.name,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            Text(driver.vehicleType,
                style:
                    const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            _ActionTile(
                icon: Icons.visibility,
                label: 'Xem chi tiết',
                onTap: () => Navigator.pop(ctx)),
            _ActionTile(
                icon: Icons.edit,
                label: 'Chỉnh sửa',
                onTap: () => Navigator.pop(ctx)),
            _ActionTile(
              icon: driver.status == 'Bị đình chỉ'
                  ? Icons.check_circle
                  : Icons.block,
              label: driver.status == 'Bị đình chỉ'
                  ? 'Kích hoạt lại'
                  : 'Đình chỉ tài khoản',
              color: driver.status == 'Bị đình chỉ'
                  ? AppColors.success
                  : AppColors.error,
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    this.color = AppColors.textPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label,
          style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}
