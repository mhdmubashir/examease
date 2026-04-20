import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (Defaults)
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color primaryGreen = Color(0xFF43A047);
  static const Color primaryRed = Color(0xFFE53935);

  // Neutral Colors
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF263238);
  static const Color textSecondary = Color(0xFF78909C);
  static const Color divider = Color(0xFFECEFF1);

  // Functional Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFFC107);
}

class AppThemeMapper {
  static Color getPrimaryColor(String? backendValue) {
    if (backendValue == null) return AppColors.primaryBlue;

    if (backendValue.startsWith('#')) {
      final hex = backendValue.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    }

    switch (backendValue.toUpperCase()) {
      case 'PRIMARY_BLUE':
        return AppColors.primaryBlue;
      case 'PRIMARY_GREEN':
        return AppColors.primaryGreen;
      case 'PRIMARY_RED':
        return AppColors.primaryRed;
      default:
        return AppColors.primaryBlue;
    }
  }

  static ThemeData createTheme(String? primaryColorKey) {
    final primaryColor = getPrimaryColor(primaryColorKey);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        margin: EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
