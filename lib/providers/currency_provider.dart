import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class CurrencyProvider with ChangeNotifier {
  String _currencyCode = 'SAR'; // Default currency code
  String get currencyCode => _currencyCode;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _currencyKey = 'app_currency_code';
  static const String _settingsCollection = 'settings';
  static const String _settingsDocId =
      'fdXUm3cdsGlvhfo0Jggk'; // The exact document ID from your Firestore screenshot

  CurrencyProvider() {
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    // Try to load from SharedPreferences first
    final prefs = await SharedPreferences.getInstance();
    _currencyCode =
        prefs.getString(_currencyKey) ?? 'SAR'; // Use default if not found

    // Then try to fetch from Firestore
    try {
      final docSnapshot = await _firestore
          .collection(_settingsCollection)
          .doc(_settingsDocId)
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final newCurrencyCode = docSnapshot.data()!['currency_code'] as String?;
        if (newCurrencyCode != null && newCurrencyCode != _currencyCode) {
          _currencyCode = newCurrencyCode;
          // Save to SharedPreferences for future use
          await prefs.setString(_currencyKey, _currencyCode);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading currency from Firestore: $e');
    }
  }

  // Method to update currency if needed (e.g., from admin panel or feature)
  Future<void> updateCurrency(String newCode) async {
    _currencyCode = newCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, _currencyCode);
    notifyListeners();

    // Optionally update Firestore as well if this method is used for admin changes
    try {
      await _firestore.collection(_settingsCollection).doc(_settingsDocId).set(
        {'currency_code': newCode},
        SetOptions(merge: true), // Merge to avoid overwriting other fields
      );
    } catch (e) {
      debugPrint('Error updating currency to Firestore: $e');
    }
  }
}
