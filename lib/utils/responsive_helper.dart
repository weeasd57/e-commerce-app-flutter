import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static EdgeInsets scaffoldPadding(BuildContext context) {
    if (isDesktop(context)) {
      return EdgeInsets.symmetric(
          horizontal: width(context) * 0.15, vertical: 20);
    }
    if (isTablet(context)) {
      return EdgeInsets.symmetric(
          horizontal: width(context) * 0.1, vertical: 16);
    }
    return const EdgeInsets.all(16);
  }

  static int gridCrossAxisCount(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 3;
    return 2;
  }

  static double fontSize(BuildContext context, double size) {
    if (isDesktop(context)) return size * 1.2;
    if (isTablet(context)) return size * 1.1;
    return size;
  }

  // دالة للحصول على حجم الخط المتجاوب
  static double getFontSize(BuildContext context, double size) {
    if (isDesktop(context)) return size * 1.2;
    if (isTablet(context)) return size * 1.1;
    return size;
  }

  // دالة للحصول على الحشو المتجاوب
  static double getPadding(BuildContext context, double padding) {
    if (isDesktop(context)) return padding * 1.3;
    if (isTablet(context)) return padding * 1.15;
    return padding;
  }

  // دالة للحصول على الهوامش المتجاوبة
  static double getMargin(BuildContext context, double margin) {
    if (isDesktop(context)) return margin * 1.2;
    if (isTablet(context)) return margin * 1.1;
    return margin;
  }

  // دالة للحصول على ارتفاع العنصر المتجاوب
  static double getHeight(BuildContext context, double height) {
    if (isDesktop(context)) return height * 1.2;
    if (isTablet(context)) return height * 1.1;
    return height;
  }

  // دالة للحصول على عرض العنصر المتجاوب
  static double getWidth(BuildContext context, double width) {
    if (isDesktop(context)) return width * 1.2;
    if (isTablet(context)) return width * 1.1;
    return width;
  }
}
