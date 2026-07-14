import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color lightGreen = Color(0xFFA5D6A7);
  static const Color earthBrown = Color(0xFF795548);
  static const Color skyBlue = Color(0xFF42A5F5);
  static const Color sunOrange = Color(0xFFFF9800);
  static const Color riskLow = Color(0xFF4CAF50);
  static const Color riskMedium = Color(0xFFFFC107);
  static const Color riskHigh = Color(0xFFF44336);
  static const Color soilColor = Color(0xFF8D6E63);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
        primary: primaryGreen,
        secondary: earthBrown,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFFF1F8E9),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: darkGreen,
      ),
      fontFamily: 'Roboto',
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: lightGreen,
        brightness: Brightness.dark,
        primary: lightGreen,
        secondary: earthBrown,
      ),
      scaffoldBackgroundColor: const Color(0xFF1B2E1B),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}

class AppColors {
  static const fieldGrid = Color(0xFFE8F5E9);
  static const fieldBorder = Color(0xFF81C784);
  static const soilWet = Color(0xFF6D4C41);
  static const soilDry = Color(0xFFA1887F);
  static const leafGreen = Color(0xFF66BB6A);
  static const diseaseWarning = Color(0xFFFFAB00);
  static const waterBlue = Color(0xFF29B6F6);
}
