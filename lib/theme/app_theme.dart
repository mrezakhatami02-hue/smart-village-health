import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF1976D2);
  static const Color background = Color(0xFFF5F8FC);
  static const Color darkBlue = Color(0xFF123B64);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
      ),
    );
  }
}
