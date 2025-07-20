import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:ecommerce/models/product.dart';
import 'package:ecommerce/models/category.dart';

/// Provider لإدارة البيانات في وضع عدم الاتصال
class OfflineDataProvider with ChangeNotifier {
  static const String _productsKey = 'offline_products';
  static const String _categoriesKey = 'offline_categories';
  static const String _lastUpdateKey = 'last_update_timestamp';
  
  List<Product> _cachedProducts = [];
  List<Category> _cachedCategories = [];
  DateTime? _lastUpdate;
  bool _isOfflineMode = false;

  List<Product> get cachedProducts => _cachedProducts;
  List<Category> get cachedCategories => _cachedCategories;
  DateTime? get lastUpdate => _lastUpdate;
  bool get isOfflineMode => _isOfflineMode;

  /// تحديد ما إذا كان التطبيق في وضع عدم الاتصال
  void setOfflineMode(bool offline) {
    _isOfflineMode = offline;
    notifyListeners();
  }

  /// حفظ المنتجات للعمل بدون اتصال
  Future<void> saveProductsForOffline(List<Product> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // تحويل المنتجات إلى JSON
      final productsJson = products.map((product) => product.toMap()).toList();
      final jsonString = json.encode(productsJson);
      
      // حفظ البيانات
      await prefs.setString(_productsKey, jsonString);
      await prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
      
      _cachedProducts = List.from(products);
      _lastUpdate = DateTime.now();
      
      debugPrint('تم حفظ ${products.length} منتج للعمل بدون اتصال');
    } catch (e) {
      debugPrint('خطأ في حفظ المنتجات للعمل بدون اتصال: $e');
    }
  }

  /// حفظ الفئات للعمل بدون اتصال
  Future<void> saveCategoriesForOffline(List<Category> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // تحويل الفئات إلى JSON
      final categoriesJson = categories.map((category) => category.toMap()).toList();
      final jsonString = json.encode(categoriesJson);
      
      // حفظ البيانات
      await prefs.setString(_categoriesKey, jsonString);
      
      _cachedCategories = List.from(categories);
      
      debugPrint('تم حفظ ${categories.length} فئة للعمل بدون اتصال');
    } catch (e) {
      debugPrint('خطأ في حفظ الفئات للعمل بدون اتصال: $e');
    }
  }

  /// تحميل البيانات المحفوظة للعمل بدون اتصال
  Future<void> loadOfflineData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // تحميل المنتجات
      final productsJson = prefs.getString(_productsKey);
      if (productsJson != null) {
        final List<dynamic> productsList = json.decode(productsJson);
        _cachedProducts = productsList
            .map((productMap) => Product.fromMap(productMap))
            .toList();
      }
      
      // تحميل الفئات
      final categoriesJson = prefs.getString(_categoriesKey);
      if (categoriesJson != null) {
        final List<dynamic> categoriesList = json.decode(categoriesJson);
        _cachedCategories = categoriesList
            .map((categoryMap) => Category.fromMap(categoryMap))
            .toList();
      }
      
      // تحميل آخر موعد تحديث
      final lastUpdateString = prefs.getString(_lastUpdateKey);
      if (lastUpdateString != null) {
        _lastUpdate = DateTime.parse(lastUpdateString);
      }
      
      if (_cachedProducts.isNotEmpty || _cachedCategories.isNotEmpty) {
        debugPrint(
            'تم تحميل ${_cachedProducts.length} منتج و ${_cachedCategories.length} فئة من البيانات المحفوظة');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('خطأ في تحميل البيانات المحفوظة: $e');
    }
  }

  /// البحث في المنتجات المحفوظة
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _cachedProducts;
    
    final lowerQuery = query.toLowerCase();
    return _cachedProducts.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
             product.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// الحصول على المنتجات حسب الفئة
  List<Product> getProductsByCategory(String categoryId) {
    return _cachedProducts.where((product) => 
        product.categoryId == categoryId).toList();
  }

  /// الحصول على المنتجات المميزة
  List<Product> getFeaturedProducts() {
    return _cachedProducts.where((product) => product.isHot).toList();
  }

  /// الحصول على المنتجات الجديدة
  List<Product> getNewProducts() {
    return _cachedProducts.where((product) => product.isNew).toList();
  }

  /// الحصول على المنتجات المخفضة
  List<Product> getSaleProducts() {
    return _cachedProducts.where((product) => product.onSale).toList();
  }

  /// التحقق من وجود بيانات محفوظة
  bool get hasOfflineData => _cachedProducts.isNotEmpty || _cachedCategories.isNotEmpty;

  /// الحصول على عمر البيانات المحفوظة
  Duration? get cacheAge {
    if (_lastUpdate == null) return null;
    return DateTime.now().difference(_lastUpdate!);
  }

  /// التحقق من أن البيانات المحفوظة قديمة (أكثر من ساعة)
  bool get isCacheStale {
    final age = cacheAge;
    return age == null || age.inHours > 1;
  }

  /// محو البيانات المحفوظة
  Future<void> clearOfflineData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await Future.wait([
        prefs.remove(_productsKey),
        prefs.remove(_categoriesKey),
        prefs.remove(_lastUpdateKey),
      ]);
      
      _cachedProducts.clear();
      _cachedCategories.clear();
      _lastUpdate = null;
      
      notifyListeners();
      debugPrint('تم محو جميع البيانات المحفوظة');
    } catch (e) {
      debugPrint('خطأ في محو البيانات المحفوظة: $e');
    }
  }

  /// دمج البيانات الجديدة مع المحفوظة
  Future<void> mergeWithOnlineData(List<Product> onlineProducts, List<Category> onlineCategories) async {
    // حفظ البيانات الجديدة
    await Future.wait([
      saveProductsForOffline(onlineProducts),
      saveCategoriesForOffline(onlineCategories),
    ]);
    
    notifyListeners();
  }
}
