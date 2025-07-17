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
    
    // تحميل القيم من التخزين المحلي أولاً
    final savedCurrency = prefs.getString(_currencyKey);
    final savedDeliveryCost = prefs.getDouble(_deliveryCostKey);
    
    if (savedCurrency != null) {
      _currencyCode = savedCurrency;
    }
    if (savedDeliveryCost != null) {
      _deliveryCost = savedDeliveryCost;
    }
    
    // إخطار المستمعين فقط إذا وجدنا قيماً محفوظة
    if (savedCurrency != null || savedDeliveryCost != null) {
      notifyListeners();
    }

    // بدء تحديث القيم من السيرفر
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

      final newCurrencyCode = data['currency_code'] as String?;
      final newDeliveryCost = data['delivery_cost'] as double?;

      // تجنب التحديثات غير الضرورية والتأكد من صحة القيم
      if (newCurrencyCode == null || newDeliveryCost == null) {
        debugPrint('تم استلام قيم غير صالحة من السيرفر');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      bool changed = false;

      // تحديث العملة فقط إذا كانت مختلفة
      if (newCurrencyCode != _currencyCode) {
        _currencyCode = newCurrencyCode;
        await prefs.setString(_currencyKey, _currencyCode);
        changed = true;
        debugPrint('تم تحديث العملة إلى: $_currencyCode');
      }

      // تحديث تكلفة التوصيل فقط إذا كانت مختلفة
      if (newDeliveryCost != _deliveryCost) {
        _deliveryCost = newDeliveryCost;
        await prefs.setDouble(_deliveryCostKey, _deliveryCost);
        changed = true;
        debugPrint('تم تحديث تكلفة التوصيل إلى: $_deliveryCost');
      }

      if (changed) {
        notifyListeners();
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


