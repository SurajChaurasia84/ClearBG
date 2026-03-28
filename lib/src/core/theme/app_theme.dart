import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color start = Color(0xFF5B247A);
  static const Color end = Color(0xFF1BCEDF);
  static const Color panel = Color(0x33FFFFFF);
  static const Color stroke = Color(0x4DFFFFFF);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFFD7E7F5);

  static ThemeData build() {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: start,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      useMaterial3: true,
    );

    final textTheme = GoogleFonts.soraTextTheme(
      base.textTheme,
    ).apply(bodyColor: textPrimary, displayColor: textPrimary);

    return base.copyWith(
      textTheme: textTheme,
      colorScheme: base.colorScheme.copyWith(
        primary: end,
        secondary: start,
        surface: const Color(0xFF101A28),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xEE101A28),
        contentTextStyle: TextStyle(color: textPrimary),
      ),
    );
  }
}
