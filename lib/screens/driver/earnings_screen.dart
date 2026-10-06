// ============================================================
// earnings_screen.dart — Màn hình Thống kê Doanh thu (Tài xế)
// Tổng hợp thu nhập theo ngày/tuần/tháng từ Supabase
// Hiển thị biểu đồ và danh sách chuyến đã hoàn thành
// ============================================================
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../core/theme.dart';

class DriverEarningsScreen extends StatefulWidget {
  const DriverEarningsScreen({super.key});

  @override
  State<DriverEarningsScreen> createState() => _DriverEarningsScreenState();
}

class _DriverEarningsScreenState extends State<DriverEarningsScreen> {
  int _totalBalance = 0;
  int _todayEarnings = 0;
  int _completedRidesCount = 0;
  int _currentDebt = 0;
  bool _isLocked = false;
  String _userId = '';
  List<dynamic> _recentRides = [];
  List<Map<String, dynamic>> _transactions = [];
  String _avatar = 'https://lh3.googleusercontent.com/aida-public/AB6AXuBcB6uHyYEU_xr6DEBl4XDbCaR2T_IUrX2ZvjTcafV3yUJMctgzZBGZwbEAykn9A-78ZYd0E5TXtUJ705T4b57S4jpCYEv5w21xQYh9s0wfQtlXWNv9mHSxDPQXDvOW734cp8YSD7L6th4MzpnSzlvguzm8CrOP3OuOXhAWhLVDJDuqoKs8OjA8EG8W7eXukmKbOvrSzTbiO9Grld-lb10dkRe05sInKX2Ri4nbhBhlYa_jo4EZUyA';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEarnings();
  }

  Future<void> _fetchEarnings() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('id') ?? '';
    if (_userId.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final profile = await Supabase.instance.client
          .from('driver_profiles')
          .select('face_image, wallet_balance, current_debt, is_locked_by_debt')
          .eq('user_id', _userId)
          .maybeSingle();
      
      int balance = 0;
      int debt = 0;
      bool locked = false;
      if (profile != null && mounted) {
        if (profile['face_image'] != null) {
          _avatar = profile['face_image'];
        }
        if (profile['wallet_balance'] != null) {
          balance = (profile['wallet_balance'] as num).toInt();
        }
        debt = profile['current_debt'] ?? 0;
        locked = profile['is_locked_by_debt'] ?? false;
      }

      final rides = await Supabase.instance.client
          .from('rides')
          .select('id, amount, created_at, dropoff_location')
          .eq('driver_id', _userId)
          .eq('status', 'completed')
          .order('created_at', ascending: false);

      int todayTotal = 0;
      final today = DateTime.now();
      
      for (var r in rides) {
        String amountStr = r['amount'].toString().replaceAll(RegExp(r'[^0-9]'), '');
        int amt = int.tryParse(amountStr) ?? 0;
        
        DateTime created = DateTime.parse(r['created_at']);
        if (created.year == today.year && created.month == today.month && created.day == today.day) {
          todayTotal += amt;
        }
      }

      final tx = await Supabase.instance.client
          .from('wallet_transactions')
          .select()
          .eq('driver_id', _userId)
          .order('created_at', ascending: false)
          .limit(10);

      if (mounted) {
        setState(() {
          _totalBalance = balance;
          _currentDebt = debt;
          _isLocked = locked;
          _todayEarnings = todayTotal;
          _completedRidesCount = rides.length;
          _recentRides = rides;
          _transactions = List<Map<String, dynamic>>.from(tx);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _processTopUp(int amount) async {
    try {
      int newBalance = _totalBalance + amount;
      int newDebt = _currentDebt;
      bool isLocked = _isLocked;
      
      int debtPayment = 0;
      if (newDebt > 0) {
        if (newBalance >= newDebt) {
          debtPayment = newDebt;
          newBalance -= newDebt;
          newDebt = 0;
        } else {
          debtPayment = newBalance;
          newDebt -= newBalance;
          newBalance = 0;
        }
      }
      if (newDebt <= 0) isLocked = false;

      await Supabase.instance.client.from('driver_profiles').update({
        'wallet_balance': newBalance,
        'current_debt': newDebt,
        'is_locked_by_debt': isLocked,
      }).eq('user_id', _userId);

      await Supabase.instance.client.from('wallet_transactions').insert({
        'driver_id': int.parse(_userId),
        'type': 'TOP_UP',
        'amount': amount,
        'description': 'Nạp tiền vào ví',
      });

      if (debtPayment > 0) {
        await Supabase.instance.client.from('wallet_transactions').insert({
          'driver_id': int.parse(_userId),
          'type': 'DEBT_PAYMENT',
          'amount': debtPayment,
          'description': 'Tự động cấn trừ công nợ',
        });
      }

      await _fetchEarnings();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nạp tiền thành công!')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi nạp tiền: $e')));
    }
  }

  Future<void> _processWithdraw(int amount) async {
    if (amount > _totalBalance) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Số dư không đủ!')));
      return;
    }
    try {
      await Supabase.instance.client.from('driver_profiles').update({
        'wallet_balance': _totalBalance - amount,
      }).eq('user_id', _userId);

      await Supabase.instance.client.from('wallet_transactions').insert({
        'driver_id': int.parse(_userId),
        'type': 'WITHDRAW',
        'amount': amount,
        'description': 'Rút tiền về ngân hàng',
      });

      await _fetchEarnings();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã tạo lệnh rút tiền!')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi rút tiền: $e')));
    }
  }

  void _showTransactionDialog(bool isTopUp) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isTopUp ? 'Nạp tiền vào ví' : 'Rút tiền về thẻ', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Nhập số tiền (VNĐ)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('HỦY')),
          ElevatedButton(
            onPressed: () {
              final amount = int.tryParse(controller.text) ?? 0;
              if (amount > 0) {
                Navigator.pop(ctx);
                if (isTopUp) _processTopUp(amount);
                else _processWithdraw(amount);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('XÁC NHẬN'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            const Icon(Icons.drive_eta, color: Color(0xFF006E2E)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('TÀI XẾ', style: TextStyle(fontSize: 10, color: Color(0xFF3D4A3D), letterSpacing: 1.0)),
                Text('Thu Nhập', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF151C27))),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications, color: Color(0xFF3D4A3D)), onPressed: () {}),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: _avatar.startsWith('data:image') ? MemoryImage(base64Decode(_avatar.split(',')[1])) as ImageProvider : NetworkImage(_avatar),
            ),
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00B14F)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
            // Tabs
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: const Color(0xFFE7EEFE), borderRadius: BorderRadius.circular(24)),
              child: Row(
                children: [
                  Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)]), child: const Center(child: Text('Hôm nay', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF006E2E)))))),
                  Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 8), child: const Center(child: Text('Tuần này', style: TextStyle(fontSize: 13, color: Color(0xFF3D4A3D)))))),
                  Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 8), child: const Center(child: Text('30 ngày', style: TextStyle(fontSize: 13, color: Color(0xFF3D4A3D)))))),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Wallet Balance
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(width: 36, height: 36, decoration: const BoxDecoration(color: Color(0xFF87FB9D), shape: BoxShape.circle), child: const Icon(Icons.account_balance_wallet, size: 20, color: Color(0xFF007433))),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Số dư khả dụng', style: TextStyle(fontSize: 12, color: Color(0xFF3D4A3D))),
                              Text(NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(_totalBalance), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF151C27))),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Công nợ (20%)', style: TextStyle(fontSize: 12, color: Color(0xFF3D4A3D))),
                          Text(NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(_currentDebt), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showTransactionDialog(true),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('NẠP TIỀN', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showTransactionDialog(false),
                          icon: const Icon(Icons.arrow_upward, size: 18),
                          label: const Text('RÚT TIỀN', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                    ],
                  ),
                  if (_isLocked) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(8)),
                      child: const Row(
                        children: [
                          Icon(Icons.warning, color: Color(0xFFEF4444), size: 16),
                          SizedBox(width: 8),
                          Expanded(child: Text('Tài khoản đang bị khóa do chưa thanh toán công nợ.', style: TextStyle(color: Color(0xFFEF4444), fontSize: 12))),
                        ],
                      ),
                    ),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Hero Earnings Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF003A15), Color(0xFF006E2E), Color(0xFF00B14F)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('THU NHẬP HÔM NAY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.8))),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: const Row(children: [Icon(Icons.trending_up, size: 14, color: Colors.white), SizedBox(width: 4), Text('+18.4%', style: TextStyle(fontSize: 11, color: Colors.white))])),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [Text(NumberFormat('#,###').format(_todayEarnings).replaceAll(',', '.'), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white)), const SizedBox(width: 4), const Text('đ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white))]),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.white70),
                      Text('Tuần: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(_totalBalance)}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                      const Text('•', style: TextStyle(color: Colors.white70)),
                      const Icon(Icons.local_taxi, size: 14, color: Colors.white70),
                      Text('$_completedRidesCount chuyến', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Bonus Quest
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF0F3FF), borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF87FB9D), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.military_tech, color: Color(0xFF007433))),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('Thưởng vượt mốc hôm nay', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF151C27)), overflow: TextOverflow.ellipsis),
                                  Text('Đã đạt 0/15 cuốc', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF006E2E))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF87FB9D), borderRadius: BorderRadius.circular(12)), child: const Text('+0 đ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF007433)))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: const LinearProgressIndicator(value: 0.0, backgroundColor: Color(0xFFDCE2F3), valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF006E2E)), minHeight: 8),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                    children: [
                      Flexible(child: Text('Nhận thêm 100.000đ khi hoàn thành 15 cuốc', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D)), overflow: TextOverflow.ellipsis)), 
                      SizedBox(width: 8),
                      Text('0%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF151C27)))
                    ]
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Chart
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Biểu đồ thu nhập tuần', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF151C27))),
                          Text('Chưa có dữ liệu', style: TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))),
                        ],
                      ),
                      const Icon(Icons.bar_chart, color: Color(0xFF6D7B6C)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildChartBar('T2', 0.0),
                        _buildChartBar('T3', 0.0),
                        _buildChartBar('T4', 0.0),
                        _buildChartBar('T5', 0.0),
                        _buildChartBar('T6', 0.0),
                        _buildChartBar('T7', 0.0),
                        _buildChartBar('CN', 0.0, isToday: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Recent Transactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Lịch sử thu nhập gần đây', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF151C27))),
                Text('Xem tất cả >', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF006E2E))),
              ],
            ),
            const SizedBox(height: 12),
            if (_recentRides.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: Text('Chưa có lịch sử thu nhập', style: TextStyle(color: Colors.grey))),
              )
            else
              ..._recentRides.take(5).map((ride) {
                DateTime created = DateTime.parse(ride['created_at']);
                String formattedTime = DateFormat('dd/MM HH:mm').format(created);
                String dropoff = ride['dropoff_location'] ?? 'Điểm đến';
                if (dropoff.length > 20) dropoff = '${dropoff.substring(0, 20)}...';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _buildTxItem(
                    Icons.two_wheeler, 
                    'Cuốc #${ride['id']}', 
                    'Đến: $dropoff • $formattedTime', 
                    '${ride['amount']}', 
                    'Tự động'
                  ),
                );
              }).toList(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
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
          // if (index == 1) Navigator.pushReplacementNamed(context, '/driver/trips');
          if (index == 3) Navigator.pushReplacementNamed(context, '/driver/profile');
        },
      ),
    );
  }

  Widget _buildChartBar(String label, double heightRatio, {bool isToday = false}) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 100 * heightRatio,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: isToday ? const Color(0xFF00B14F) : const Color(0xFFDCE2F3),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: isToday ? FontWeight.bold : FontWeight.normal, color: isToday ? const Color(0xFF006E2E) : const Color(0xFF3D4A3D))),
        ],
      ),
    );
  }

  Widget _buildTxItem(IconData icon, String title, String subtitle, String amount, String method, {bool isBonus = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: isBonus ? const Color(0xFF87FB9D) : const Color(0xFF006E2E).withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: isBonus ? const Color(0xFF007433) : const Color(0xFF006E2E))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF151C27))),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF3D4A3D))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF006E2E))),
              Text(method, style: TextStyle(fontSize: 11, fontWeight: isBonus ? FontWeight.bold : FontWeight.normal, color: isBonus ? const Color(0xFF007433) : const Color(0xFF3D4A3D))),
            ],
          ),
        ],
      ),
    );
  }
}
