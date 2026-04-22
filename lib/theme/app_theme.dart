import 'package:flutter/material.dart';

class AppColors {
  static const primary      = Color(0xFF1B5E20);
  static const primaryLight = Color(0xFF4CAF50);
  static const primaryDark  = Color(0xFF003300);
  static const accent       = Color(0xFFFF6F00);
  static const accentLight  = Color(0xFFFFB300);
  static const background   = Color(0xFFF5F5F5);
  static const surface      = Color(0xFFFFFFFF);
  static const error        = Color(0xFFD32F2F);
  static const success      = Color(0xFF388E3C);
  static const warning      = Color(0xFFF57C00);
  static const textPrimary  = Color(0xFF212121);
  static const textSecondary= Color(0xFF757575);
  static const divider      = Color(0xFFE0E0E0);
  static const cardShadow   = Color(0x1A000000);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary:    AppColors.primary,
      secondary:  AppColors.accent,
      surface:    AppColors.surface,
      error:      AppColors.error,
    ),
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    // Fix: pakai CardThemeData bukan CardTheme
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shadowColor: AppColors.cardShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 10,
    ),
  );
}
