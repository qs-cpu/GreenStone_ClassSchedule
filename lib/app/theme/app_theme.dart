import 'package:flutter/material.dart';

class AppTheme {
  // 糖果色主色调
  static const Color seedColor = Color(0xFFFFB6C1);
  static const Color primaryColor = Color(0xFFFF9EBB);
  static const Color secondaryColor = Color(0xFFAEC6CF);
  static const Color surfaceColor = Color(0xFFFFF5F8);
  static const Color backgroundColor = Color(0xFFFAFAFA);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: surfaceColor,
      ),
    );
  }

  static ThemeData get darkTheme {
    // 这里可以定义暗色主题的糖果色变体，暂时提供一个基础深色
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
    );
  }
}
