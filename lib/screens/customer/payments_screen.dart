import 'package:flutter/material.dart';
import '../../core/theme.dart';

class CustomerPaymentsScreen extends StatelessWidget {
  const CustomerPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Phương thức thanh toán', style: TextStyle(color: Color(0xFF151C27), fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF151C27)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPaymentMethod(Icons.money, 'Tiền mặt', 'Thanh toán trực tiếp cho tài xế', true),
          const SizedBox(height: 12),
          _buildPaymentMethod(Icons.account_balance_wallet, 'Ví MoMo', 'Liên kết ví MoMo của bạn', false),
          const SizedBox(height: 12),
          _buildPaymentMethod(Icons.credit_card, 'Thẻ Tín dụng / Ghi nợ', 'Thêm thẻ Visa, Mastercard', false),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(IconData icon, String title, String subtitle, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? const Color(0xFF00B14F) : Colors.transparent, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFFE7EEFE), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: const Color(0xFF006E2E)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF00B14F)) : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
      ),
    );
  }
}
