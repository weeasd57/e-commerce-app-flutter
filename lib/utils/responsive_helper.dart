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
}
