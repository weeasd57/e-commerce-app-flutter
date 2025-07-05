import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LanguageProvider() {
    _loadLanguage();
  }

  void setLanguage(String languageCode) {
    _locale = Locale(languageCode);
    _saveLanguage();
    notifyListeners();
  }

  void changeLanguage(Locale newLocale) {
    _locale = newLocale;
    _saveLanguage();
    notifyListeners();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('language') ?? 'en';
    _locale = Locale(language);
    notifyListeners();
  }

  Future<void> _saveLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _locale.languageCode);
  }
}
