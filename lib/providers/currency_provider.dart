import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:ecommerce/services/supabase_service.dart';

class CurrencyProvider with ChangeNotifier {
  String _currencyCode = 'SAR'; // Default currency code
  double _deliveryCost = 0.0; // Default delivery cost

  String get currencyCode => _currencyCode;
  double get deliveryCost => _deliveryCost;

  static const String _currencyKey = 'app_currency_code';
  static const String _deliveryCostKey = 'app_delivery_cost';

  Timer? _refreshTimer;

  CurrencyProvider() {
    _loadInitialValuesAndListen();
  }

  Future<void> _loadInitialValuesAndListen() async {
    final prefs = await SharedPreferences.getInstance();
    _currencyCode = prefs.getString(_currencyKey) ?? 'SAR';
    _deliveryCost = prefs.getDouble(_deliveryCostKey) ?? 0.0;
    notifyListeners();

    _startRefreshingCurrency();
  }

  void _startRefreshingCurrency() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _fetchCurrencyAndDeliveryCost();
    });
    _fetchCurrencyAndDeliveryCost(); // Fetch immediately on start
  }

  Future<void> _fetchCurrencyAndDeliveryCost() async {
    try {
      final data = await SupabaseService.getAppSettings();

      if (data != null) {
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
          await prefs.setDouble(_deliveryCostKey, _deliveryCost);
          changed = true;
        }

        if (changed) {
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error fetching app settings from Supabase: $e');
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> updateCurrency(String newCode) async {
    _currencyCode = newCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, _currencyCode);
    notifyListeners();
  }

  Future<void> updateDeliveryCost(double newCost) async {
    _deliveryCost = newCost;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_deliveryCostKey, _deliveryCost);
    notifyListeners();
  }
}


