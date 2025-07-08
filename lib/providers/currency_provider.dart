import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class CurrencyProvider with ChangeNotifier {
  String _currencyCode = 'SAR'; // Default currency code
  double _deliveryCost = 0.0; // Default delivery cost

  String get currencyCode => _currencyCode;
  double get deliveryCost => _deliveryCost;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _currencyKey = 'app_currency_code';
  static const String _deliveryCostKey =
      'app_delivery_cost'; // New key for delivery cost
  static const String _settingsCollection = 'settings';
  static const String _settingsDocId =
      'app_settings'; // Using the correct document ID 'app_settings'

  StreamSubscription<DocumentSnapshot>? _currencySubscription;

  CurrencyProvider() {
    _loadInitialValuesAndListen();
  }

  Future<void> _loadInitialValuesAndListen() async {
    final prefs = await SharedPreferences.getInstance();
    _currencyCode = prefs.getString(_currencyKey) ?? 'SAR';
    _deliveryCost =
        prefs.getDouble(_deliveryCostKey) ?? 0.0; // Load initial delivery cost
    notifyListeners(); // Notify immediately with initial values

    _listenToCurrencyChanges(); // Start listening to Firestore changes
  }

  void _listenToCurrencyChanges() {
    _currencySubscription?.cancel(); // Cancel any existing subscription
    _currencySubscription = _firestore
        .collection(_settingsCollection)
        .doc(_settingsDocId)
        .snapshots()
        .listen((docSnapshot) async {
      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        final newCurrencyCode = data['currency_code'] as String?;
        final newDeliveryCost = data['delivery_cost'] as double?;

        bool changed = false;

        if (newCurrencyCode != null && newCurrencyCode != _currencyCode) {
          _currencyCode = newCurrencyCode;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_currencyKey, _currencyCode);
          changed = true;
        }

        if (newDeliveryCost != null && newDeliveryCost != _deliveryCost) {
          _deliveryCost = newDeliveryCost;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setDouble(
              _deliveryCostKey, _deliveryCost); // Save to SharedPreferences
          changed = true;
        }

        if (changed) {
          notifyListeners();
        }
      }
    }, onError: (e) {
      debugPrint('Error listening to app settings changes from Firestore: $e');
    });
  }

  @override
  void dispose() {
    _currencySubscription?.cancel();
    super.dispose();
  }

  // Method to update currency (local changes only, Firestore not updated from here)
  Future<void> updateCurrency(String newCode) async {
    _currencyCode = newCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, _currencyCode);
    notifyListeners();

    // Removed Firestore update logic as changes come from Admin App
  }

  // Method to update delivery cost (local changes only, Firestore not updated from here)
  Future<void> updateDeliveryCost(double newCost) async {
    _deliveryCost = newCost;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_deliveryCostKey, _deliveryCost);
    notifyListeners();
  }
}
