import 'package:flutter/material.dart';

class AppThemes {
  static ThemeData getTheme({
    required bool isDark,
    required Color primaryColor,
    List<Color>? gradientColors,
  }) {
    final colorScheme = isDark
        ? ColorScheme.dark(primary: primaryColor)
        : ColorScheme.light(primary: primaryColor);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: primaryColor,
      appBarTheme: AppBarTheme(
        backgroundColor: gradientColors?.first ?? primaryColor,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: gradientColors?.first ?? primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
      ),
    );
  }
}
