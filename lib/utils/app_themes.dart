import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';

class AppThemes {
  // Light theme colors
  static const Color _lightSurface = Color(0xFFFAFAFA);
  static const Color _lightOnSurface = Color(0xFF1A1A1A);
  
  // Dark theme colors
  static const Color _darkSurface = Color(0xFF1E1E1E);
  static const Color _darkOnSurface = Color(0xFFE0E0E0);

  // Safe Google Fonts loader with fallback and Arabic support
  static TextTheme _getSafeTextTheme(ThemeData baseTheme, {bool isArabic = false}) {
    try {
      // Allow runtime fetching for Google Fonts
      GoogleFonts.config.allowRuntimeFetching = true;
      
      // Use Cairo for Arabic text or Poppins for other languages
      if (isArabic) {
        return GoogleFonts.cairoTextTheme(baseTheme.textTheme);
      } else {
        return GoogleFonts.poppinsTextTheme(baseTheme.textTheme);
      }
    } catch (e) {
      // Fallback to system fonts
      debugPrint('Google Fonts failed to load: $e');
      return _getFallbackTextTheme(baseTheme, isArabic: isArabic);
    }
  }

  // Fallback text theme using system fonts with Arabic support
  static TextTheme _getFallbackTextTheme(ThemeData baseTheme, {bool isArabic = false}) {
    // Use appropriate fallback font based on language
    String? fallbackFont;
    if (kIsWeb) {
      fallbackFont = isArabic ? 'Tahoma, Arial, sans-serif' : 'Roboto';
    } else {
      // On mobile, system will handle Arabic fonts automatically
      fallbackFont = null;
    }
    
    return baseTheme.textTheme.copyWith(
      displayLarge: baseTheme.textTheme.displayLarge?.copyWith(
        fontFamily: fallbackFont,
        fontWeight: FontWeight.w300,
      ),
      displayMedium: baseTheme.textTheme.displayMedium?.copyWith(
        fontFamily: fallbackFont,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: baseTheme.textTheme.headlineLarge?.copyWith(
        fontFamily: fallbackFont,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: baseTheme.textTheme.titleLarge?.copyWith(
        fontFamily: fallbackFont,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(
        fontFamily: fallbackFont,
      ),
      bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(
        fontFamily: fallbackFont,
      ),
      labelLarge: baseTheme.textTheme.labelLarge?.copyWith(
        fontFamily: fallbackFont,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static ThemeData getTheme({
    required bool isDark,
    required Color primaryColor,
    List<Color>? gradientColors,
    Locale? locale,
  }) {
    final colorScheme = isDark
        ? ColorScheme.dark(
            primary: primaryColor,
            surface: _darkSurface,
            onSurface: _darkOnSurface,
            surfaceContainerHighest: const Color(0xFF2A2A2A),
            outline: const Color(0xFF4A4A4A),
          )
        : ColorScheme.light(
            primary: primaryColor,
            surface: _lightSurface,
            onSurface: _lightOnSurface,
            surfaceContainerHighest: const Color(0xFFF5F5F5),
            outline: const Color(0xFFE0E0E0),
          );

    final baseTheme = isDark ? ThemeData.dark() : ThemeData.light();
    final isArabic = locale?.languageCode == 'ar';
    final textTheme = _getSafeTextTheme(baseTheme, isArabic: isArabic);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: primaryColor,
      textTheme: textTheme,
      
      // Modern AppBar design
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? _darkSurface : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black87,
        ),
        surfaceTintColor: Colors.transparent,
      ),
      
      // Modern Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // Modern Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? _darkSurface : const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE8EAED),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // Modern Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? _darkSurface : Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: textTheme.labelSmall,
      ),
      
      // Modern Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? _darkSurface : const Color(0xFFF8F9FA),
        selectedColor: primaryColor.withValues(alpha: 0.2),
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE8EAED),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
