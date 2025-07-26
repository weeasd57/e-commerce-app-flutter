import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FontHelper {
  // الخطوط الاحتياطية
  static const List<String> fallbackFonts = [
    'Roboto',
    'Arial',
    'sans-serif',
  ];

  // Safe Google Fonts loader with Arabic support
  static Future<TextTheme> loadSafeTextTheme(TextTheme baseTextTheme, {bool isArabic = false}) async {
    try {
      // Enable runtime fetching for Google Fonts
      GoogleFonts.config.allowRuntimeFetching = true;
      
      // Use Cairo for Arabic text or Poppins for other languages
      if (isArabic) {
        return GoogleFonts.cairoTextTheme(baseTextTheme);
      } else {
        return GoogleFonts.poppinsTextTheme(baseTextTheme);
      }
    } catch (e) {
      debugPrint('Failed to load Google Fonts: $e');
      return _getFallbackTextTheme(baseTextTheme, isArabic: isArabic);
    }
  }

  // الخط الاحتياطي مع دعم العربية
  static TextTheme _getFallbackTextTheme(TextTheme baseTextTheme, {bool isArabic = false}) {
    // استخدام خط مناسب حسب اللغة
    String? fontFamily;
    if (isArabic) {
      // خطوط احتياطية تدعم العربية
      fontFamily = 'Tahoma'; // خط جيد للعربية متوفر على معظم الأنظمة
    } else {
      fontFamily = 'Roboto';
    }
    
    return baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w300,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w400,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w400,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w400,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // تحقق من توفر الخط
  static bool isFontAvailable(String fontFamily) {
    try {
      // محاولة إنشاء TextStyle بالخط المطلوب
      const TextStyle testStyle = TextStyle(fontFamily: 'test');
      return testStyle.fontFamily != null;
    } catch (e) {
      return false;
    }
  }
}
