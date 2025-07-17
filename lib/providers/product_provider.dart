import 'package:flutter/material.dart';
// Import Supabase
import 'package:ecommerce/models/product.dart';
import 'package:ecommerce/services/supabase_service.dart'; // Import SupabaseService

enum SortOption {
  newest,
  priceHighToLow,
  priceLowToHigh,
}

class ProductProvider with ChangeNotifier {
  final _db = SupabaseService.client; // Use Supabase client
  List<Product> _products = [];
  List<Product> _newProducts = [];
  List<Product> _saleProducts = [];
  List<Product> _hotProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  bool _hasError = false;
  DateTime? _lastFetch; // تتبع آخر مرة تم فيها تحديث البيانات

  // Filter states
  bool _showOnSale = false;
  bool _showHotItems = false;
  bool _showNewArrivals = false;
  SortOption _sortOption = SortOption.newest;
  
  // التحقق مما إذا كانت البيانات محدثة
  bool get _isDataStale {
    if (_lastFetch == null) return true;
    final difference = DateTime.now().difference(_lastFetch!);
    return difference.inMinutes > 15; // تحديث كل 15 دقيقة
  }

  List<Product> get products =>
      _filteredProducts.isEmpty ? _products : _filteredProducts;
  List<Product> get newProducts => _newProducts;
  List<Product> get saleProducts => _saleProducts;
  List<Product> get hotProducts => _hotProducts;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  bool get showOnSale => _showOnSale;
  bool get showHotItems => _showHotItems;
  bool get showNewArrivals => _showNewArrivals;
  SortOption get sortOption => _sortOption;

  void setShowOnSale(bool value) {
    _showOnSale = value;
    _applyFilters();
  }

  void setShowHotItems(bool value) {
    _showHotItems = value;
    _applyFilters();
  }

  void setShowNewArrivals(bool value) {
    _showNewArrivals = value;
    _applyFilters();
  }

  void setSortOption(SortOption option) {
    _sortOption = option;
    _applyFilters();
  }

  void clearFilters() {
    _showOnSale = false;
    _showHotItems = false;
    _showNewArrivals = false;
    _sortOption = SortOption.newest;
    _filteredProducts = [];
    notifyListeners();
  }

  void _applyFilters() {
    _filteredProducts = List.from(_products);

    // Apply category filters
    if (_showOnSale) {
      _filteredProducts =
          _filteredProducts.where((product) => product.onSale).toList();
    }

    if (_showHotItems) {
      _filteredProducts =
          _filteredProducts.where((product) => product.isHot).toList();
    }

    if (_showNewArrivals) {
      _filteredProducts =
          _filteredProducts.where((product) => product.isNew).toList();
    }

    // Apply sorting
    switch (_sortOption) {
      case SortOption.newest:
        _filteredProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.priceHighToLow:
        _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.priceLowToHigh:
        _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
    }

    notifyListeners();
  }

  Future<void> fetchProducts({bool forceRefresh = false}) async {
    // تجنب التحميل المتكرر إذا كانت البيانات محدثة
    if (_isLoading || (!forceRefresh && !_isDataStale && _products.isNotEmpty)) {
      return;
    }

    // تحديث حالة التحميل بدون إخطار المستمعين
    _isLoading = true;
    _hasError = false;
    // تأخير الإخطار للإطار التالي
    Future.microtask(() => notifyListeners());

    try {
      final List<Map<String, dynamic>> data = await _db
          .from('products')
          .select()
          .order('created_at');
      
      _products = data.map((json) {
        DateTime createdAt;
        String? age;

        try {
          final createdAtData = json['created_at'];
          if (createdAtData is String) {
            createdAt = DateTime.parse(createdAtData);
          } else {
            createdAt = DateTime.now();
          }
        } catch (e) {
          createdAt = DateTime.now();
        }

        age = json['age'] as String?;

        return Product.fromMap({
          'id': json['id']?.toString() ?? '',
          ...json,
          'createdAt': createdAt.toIso8601String(),
          'age': age,
        });
      }).toList();

      _newProducts = _products.where((product) => product.isNew).toList();
      _saleProducts = _products.where((product) => product.onSale).toList();
      _hotProducts = _products.where((product) => product.isHot).toList();
      _lastFetch = DateTime.now();
      _applyFilters();
    } catch (e) {
      debugPrint('خطأ في تحميل المنتجات: $e');
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<List<Product>> fetchProductsByCategory(String categoryId) async {
    try {
      final List<Map<String, dynamic>> productsData = await _db
          .from('products')
          .select()
          .eq('category_id', categoryId) // Use .eq for where clause
          .order('created_at', ascending: false);

      return productsData.map((data) {
        DateTime createdAt;
        String? age;

        try {
          final createdAtData = data['created_at'];
          if (createdAtData is String) {
            createdAt = DateTime.parse(createdAtData);
          } else {
            createdAt = DateTime.now(); // Fallback
          }
        } catch (e) {
          createdAt = DateTime.now(); // Fallback
        }

        age = data['age'] as String?;

        return Product.fromMap({
          'id': data['id'],
          ...data,
          'createdAt': createdAt.toIso8601String(),
          'age': age,
        });
      }).toList();
    } catch (e) {
      debugPrint('Error fetching products by category: $e');
      return [];
    }
  }
}


