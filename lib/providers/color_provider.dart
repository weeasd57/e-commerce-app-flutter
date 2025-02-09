import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/color_option.dart';

class ColorProvider extends ChangeNotifier {
  static const String _colorKey = 'selected_color_option';
  ColorOption? _selectedColorOption;
  final SharedPreferences _prefs;

  ColorProvider(this._prefs) {
    _loadSelectedColor();
  }

  ColorOption? get selectedColorOption => _selectedColorOption;

  final List<ColorOption> solidColorOptions = [
    // Solid Colors
    ColorOption.solid(Colors.blue),
    ColorOption.solid(Colors.red),
    ColorOption.solid(Colors.green),
    ColorOption.solid(Colors.purple),
    ColorOption.solid(Colors.orange),
    ColorOption.solid(Colors.teal),
    ColorOption.solid(Colors.indigo),
    ColorOption.solid(Colors.pink),
    ColorOption.solid(Colors.amber),
    ColorOption.solid(Colors.cyan),
    ColorOption.solid(Colors.deepPurple),
    ColorOption.solid(Colors.lightBlue),
    ColorOption.solid(Colors.deepOrange),
    ColorOption.solid(Colors.lime),
    ColorOption.solid(Colors.brown),
    ColorOption.solid(Colors.blueGrey),
    ColorOption.solid(Colors.lightGreen),
    ColorOption.solid(Colors.grey.shade700),
    ColorOption.solid(Colors.indigoAccent),
    ColorOption.solid(Colors.pinkAccent),
    ColorOption.solid(Colors.tealAccent),
    ColorOption.solid(Colors.purpleAccent),
    ColorOption.solid(Colors.deepOrangeAccent),
    ColorOption.solid(Colors.greenAccent),
    ColorOption.solid(Colors.cyanAccent),
    ColorOption.solid(Colors.amberAccent),
  ];

  final List<ColorOption> gradientOptions = [
    // Existing gradients
    ColorOption.gradient([Colors.blue, Colors.purple], name: 'Blue Purple'),
    ColorOption.gradient([Colors.pink, Colors.orange], name: 'Sunset'),
    ColorOption.gradient([Colors.green, Colors.teal], name: 'Forest'),
    ColorOption.gradient([Colors.indigo, Colors.cyan], name: 'Ocean'),

    // New gradients
    ColorOption.gradient([Color(0xFF2E3192), Color(0xFF1BFFFF)],
        name: 'Deep Ocean'),
    ColorOption.gradient([Color(0xFFFF512F), Color(0xFFDD2476)],
        name: 'Sweet Pink'),
    ColorOption.gradient(
        [Color(0xFF134E5E), Color.fromARGB(255, 197, 179, 152)],
        name: 'Emerald'),
    ColorOption.gradient([Color(0xFF8E2DE2), Color(0xFF4A00E0)],
        name: 'Royal Purple'),
    ColorOption.gradient([Color(0xFFFFB75E), Color(0xFFED8F03)],
        name: 'Golden'),
    ColorOption.gradient([Color(0xFFFF6B6B), Color(0xFF556270)],
        name: 'Dusty Rose'),
    ColorOption.gradient([Color(0xFF0F2027), Color(0xFF203A43)],
        name: 'Dark Night'),
    ColorOption.gradient([Color(0xFF00B09B), Color(0xFF96C93D)],
        name: 'Spring'),
    ColorOption.gradient([Color(0xFF654EA3), Color(0xFFEAAFC8)],
        name: 'Lavender'),
    ColorOption.gradient([Color(0xFF4776E6), Color(0xFF8E54E9)],
        name: 'Electric'),
    ColorOption.gradient([Color(0xFFFF758C), Color(0xFFFF7EB3)],
        name: 'Soft Pink'),
    ColorOption.gradient([Color(0xFFA8C0FF), Color(0xFF3F2B96)],
        name: 'Night Sky'),
    ColorOption.gradient([Color(0xFFD4145A), Color(0xFFFBB03B)],
        name: 'Passion'),
    ColorOption.gradient([Color(0xFF009FFF), Color(0xFFec2F4B)],
        name: 'Fire Ice'),
    ColorOption.gradient([Color(0xFF662D8C), Color(0xFFED1E79)], name: 'Berry'),
    ColorOption.gradient([Color(0xFF6190E8), Color(0xFFA7BFE8)], name: 'Cloud'),
    ColorOption.gradient([Color(0xFFFF0844), Color(0xFFFFB199)],
        name: 'Peachy'),
    ColorOption.gradient([Color(0xFF34E89E), Color(0xFF0F3443)],
        name: 'Forest Lake'),
    ColorOption.gradient([Color(0xFFb721ff), Color(0xFF21d4fd)],
        name: 'Neon Life'),
    ColorOption.gradient([Color(0xFF6D6027), Color(0xFFD3CBB8)], name: 'Desert')
  ];

  bool get isGradientMode => _selectedColorOption?.isGradient ?? false;

  void setColor(ColorOption colorOption) {
    _selectedColorOption = colorOption;
    _saveSelectedColor();
    notifyListeners();
  }

  void _loadSelectedColor() {
    final colorString = _prefs.getString(_colorKey);
    if (colorString != null) {
      _selectedColorOption = ColorOption.fromJson(jsonDecode(colorString));
    }
  }

  void _saveSelectedColor() {
    final colorString = jsonEncode(_selectedColorOption?.toJson());
    _prefs.setString(_colorKey, colorString);
  }

  List<Color> get currentThemeColors {
    if (_selectedColorOption?.isGradient ?? false) {
      return _selectedColorOption!.gradientColors!;
    }
    return [_selectedColorOption?.solidColor ?? Colors.blue];
  }

  Color get primaryColor {
    if (_selectedColorOption?.isGradient ?? false) {
      return _selectedColorOption!.gradientColors!.first;
    }
    return _selectedColorOption?.solidColor ?? Colors.blue;
  }
}
