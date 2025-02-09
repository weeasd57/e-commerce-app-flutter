import 'package:flutter/material.dart';

class ColorOption {
  final Color? solidColor;
  final List<Color>? gradientColors;
  final bool isGradient;
  final String? name;

  ColorOption.solid(this.solidColor)
      : gradientColors = null,
        isGradient = false,
        name = null;

  ColorOption.gradient(this.gradientColors, {required this.name})
      : solidColor = null,
        isGradient = true;

  Map<String, dynamic> toJson() {
    if (isGradient) {
      return {
        'isGradient': true,
        'colors': gradientColors!.map((c) => c.value).toList(),
        'name': name,
      };
    }
    return {
      'isGradient': false,
      'color': solidColor!.value,
    };
  }

  factory ColorOption.fromJson(Map<String, dynamic> json) {
    if (json['isGradient']) {
      return ColorOption.gradient(
        (json['colors'] as List).map((c) => Color(c as int)).toList(),
        name: json['name'] as String,
      );
    }
    return ColorOption.solid(Color(json['color'] as int));
  }
}
