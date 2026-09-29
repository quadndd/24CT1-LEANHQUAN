// ============================================================
// theme.dart — Định nghĩa bảng màu và theme toàn cục của GoRide VN
// Tất cả màu sắc, style button, input, card đều được cấu hình tại đây
// ============================================================
import 'package:flutter/material.dart';

/// Bảng màu chuẩn của ứng dụng GoRide VN
/// Sử dụng các hằng số này thay vì viết trực tiếp mã màu trong widget
class AppColors {
  // ── Màu chủ đạo (Primary green) ─────────────────────────────
  static const Color primary = Color(0xFF1B5E37);           // Xanh lá đậm — màu chính
  static const Color primaryLight = Color(0xFF2D7A4F);      // Xanh lá nhạt hơn
  static const Color primaryDark = Color(0xFF0D3D20);       // Xanh lá tối hơn
  static const Color primaryContainer = Color(0xFFE8F5EE);  // Nền xanh lá nhạt (container)

  // ── Màu nhấn (Accent) ────────────────────────────────────────
  static const Color accent = Color(0xFF00B14F);            // Xanh lá tươi (Grab Green)
  static const Color accentLight = Color(0xFFE6F7EF);       // Nền accent nhạt

  // ── Màu chữ ──────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A1A);       // Chữ chính (gần đen)
  static const Color textSecondary = Color(0xFF6B7280);     // Chữ phụ (xám)
  static const Color textHint = Color(0xFF9CA3AF);          // Chữ gợi ý (nhạt)

  // ── Màu nền ──────────────────────────────────────────────────
  static const Color background = Color(0xFFF8F9FA);        // Nền toàn app (trắng xám)
  static const Color surface = Color(0xFFFFFFFF);            // Nền card/sheet (trắng)
  static const Color divider = Color(0xFFE5E7EB);           // Đường kẻ phân cách

  // ── Màu trạng thái ───────────────────────────────────────────
  static const Color success = Color(0xFF00B14F);           // Thành công (xanh lá)
  static const Color warning = Color(0xFFF59E0B);           // Cảnh báo (vàng cam)
  static const Color error = Color(0xFFEF4444);             // Lỗi (đỏ)
  static const Color errorLight = Color(0xFFFEE2E2);        // Nền lỗi nhạt

  // ── Màu bản đồ ───────────────────────────────────────────────
  static const Color mapBackground = Color(0xFFE8EFF0);     // Nền bản đồ giả lập
  static const Color mapRoad = Color(0xFFFFFFFF);           // Màu đường trên bản đồ
  static const Color mapGreen = Color(0xFFB8D4BD);          // Màu mảng xanh (công viên)

  // ── Màu xám (Grey scale) ─────────────────────────────────────
  static const Color grey100 = Color(0xFFF3F4F6);           // Xám rất nhạt (nền input)
  static const Color grey200 = Color(0xFFE5E7EB);           // Xám nhạt (divider)
  static const Color grey300 = Color(0xFFD1D5DB);           // Xám vừa
  static const Color grey400 = Color(0xFF9CA3AF);           // Xám trung bình (icon không active)
  static const Color grey600 = Color(0xFF4B5563);           // Xám đậm (text phụ)
}

/// Cấu hình ThemeData cho toàn ứng dụng
class AppTheme {
  /// Theme sáng (light mode) — theme duy nhất hiện tại của app
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,         // Dùng Material Design 3 (phiên bản mới nhất)
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background, // Màu nền mặc định của Scaffold
      fontFamily: 'Roboto',                           // Font chữ mặc định

      // ── AppBar ────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,              // Nền AppBar trắng
        foregroundColor: AppColors.textPrimary,     // Màu chữ/icon trên AppBar
        elevation: 0,                               // Không có bóng đổ
        scrolledUnderElevation: 0,                  // Không đổ bóng khi cuộn
        centerTitle: false,                         // Tiêu đề căn trái
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),

      // ── Nút ElevatedButton (nút nền màu) ─────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,       // Nền xanh lá
          foregroundColor: Colors.white,            // Chữ trắng
          minimumSize: const Size(double.infinity, 52), // Chiều rộng tối đa, cao 52
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),  // Bo góc 12
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ── Nút OutlinedButton (nút viền) ────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,       // Chữ/icon màu xanh
          side: const BorderSide(color: AppColors.primary), // Viền xanh
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ── Trường nhập liệu (TextField/InputDecoration) ─────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,                               // Nền được tô màu
        fillColor: AppColors.grey100,              // Màu nền nhập liệu (xám nhạt)
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,             // Không có viền mặc định
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,             // Không có viền khi không focus
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5), // Viền xanh khi focus
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
      ),

      // ── Thanh điều hướng dưới (BottomNavigationBar) ──────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,      // Màu item được chọn
        unselectedItemColor: AppColors.grey400,    // Màu item không được chọn
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,       // Hiển thị tất cả item (không ẩn khi nhiều)
        elevation: 8,                              // Bóng đổ
      ),

      // ── Card ──────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08), // Bóng nhẹ
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
