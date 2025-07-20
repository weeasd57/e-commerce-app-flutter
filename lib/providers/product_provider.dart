import 'package:flutter/material.dart';
import 'dart:async';
// Import Supabase
import 'package:ecommerce/models/product.dart';
import 'package:ecommerce/services/supabase_service.dart'; // Import SupabaseService
import 'package:ecommerce/providers/offline_data_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
  bool _isOffline = false;
  OfflineDataProvider? _offlineProvider;
  
  // Stream subscription للتحديث في الوقت الفعلي
  StreamSubscription? _productsStreamSubscription;
  StreamSubscription? _connectivitySubscription;

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
  bool get isOffline => _isOffline;

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
      List<ConnectivityResult> connectivityResults = await (Connectivity().checkConnectivity());
      if (connectivityResults.contains(ConnectivityResult.none) && _offlineProvider != null) {
        // في حالة عدم وجود اتصال، استخدم البيانات المخزنة مؤقتًا
        _isOffline = true;
        _products = _offlineProvider!.cachedProducts;
        _newProducts = _offlineProvider!.getNewProducts();
        _saleProducts = _offlineProvider!.getSaleProducts();
        _hotProducts = _offlineProvider!.getFeaturedProducts();
        _lastFetch = _offlineProvider!.lastUpdate;
        _applyFilters();
        notifyListeners();
        return;
      } else {
        _isOffline = false;
      }

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

      // حفظ البيانات للتخزين المؤقت
      if (_offlineProvider != null) {
        await _offlineProvider!.saveProductsForOffline(_products);
      }
    } catch (e) {
      debugPrint('خطأ في تحميل المنتجات: $e');
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// بدء الاستماع للتحديثات في الوقت الفعلي
  void startRealTimeUpdates() {
    // إلغاء الاشتراك السابق إذا كان موجود
    _productsStreamSubscription?.cancel();
    
    debugPrint('🚀 بدء Real-time updates للمنتجات...');
    
    // بدء الاستماع للتغييرات في جدول المنتجات
    _productsStreamSubscription = _db
        .from('products')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .listen(
          (List<Map<String, dynamic>> data) {
            try {
              debugPrint('🔄 Real-time update received at ${DateTime.now()}: ${data.length} منتج');
              
              // Log some product IDs to verify data changes
              if (data.isNotEmpty) {
                final firstFewIds = data.take(3).map((p) => p['id']).toList();
                debugPrint('📦 First few product IDs: $firstFewIds');
              }
              
              final oldProductsCount = _products.length;
              final oldSaleProductsCount = _saleProducts.length;
              
              // Store old products for comparison
              final oldProductsMap = {for (var p in _products) p.id: p};
              
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
              _hasError = false;
              
              // Detailed change logging
              if (oldProductsCount != _products.length) {
                debugPrint('📊 تغيير عدد المنتجات: $oldProductsCount → ${_products.length}');
              }
              if (oldSaleProductsCount != _saleProducts.length) {
                debugPrint('🏷️ تغيير عدد العروض: $oldSaleProductsCount → ${_saleProducts.length}');
              }
              
              // Check for updated products
              int updatedCount = 0;
              for (var newProduct in _products) {
                final oldProduct = oldProductsMap[newProduct.id];
                if (oldProduct != null) {
                  // Compare key fields
                  if (oldProduct.name != newProduct.name ||
                      oldProduct.price != newProduct.price ||
                      oldProduct.onSale != newProduct.onSale ||
                      oldProduct.salePrice != newProduct.salePrice ||
                      oldProduct.description != newProduct.description ||
                      oldProduct.isHot != newProduct.isHot ||
                      oldProduct.isNew != newProduct.isNew) {
                    updatedCount++;
                    debugPrint('🔄 Updated product: ${newProduct.id} - ${newProduct.name}');
                    debugPrint('   Old price: ${oldProduct.price}, New price: ${newProduct.price}');
                    debugPrint('   Old onSale: ${oldProduct.onSale}, New onSale: ${newProduct.onSale}');
                  }
                }
              }
              
              if (updatedCount > 0) {
                debugPrint('🆕 Total updated products: $updatedCount');
              }
              
              _applyFilters();
              debugPrint('✅ Real-time update applied successfully! Notifying listeners...');
            } catch (e) {
              debugPrint('❌ خطأ في تحديث البيانات في الوقت الفعلي: $e');
              _hasError = true;
              notifyListeners();
            }
          },
          onError: (error) {
            debugPrint('خطأ في stream المنتجات: $error');
            _hasError = true;
            notifyListeners();
          },
        );
  }

  /// إيقاف الاستماع للتحديثات في الوقت الفعلي
  void stopRealTimeUpdates() {
    _productsStreamSubscription?.cancel();
    _productsStreamSubscription = null;
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

  /// تهيئة الـ offline data provider
  void initOfflineDataProvider(OfflineDataProvider offlineProvider) {
    _offlineProvider = offlineProvider;
    // تحميل البيانات المخزنة مؤقتًا عند البدء
    _loadOfflineDataIfNeeded();
  }

  /// تحميل البيانات المخزنة مؤقتًا عند الحاجة
  Future<void> _loadOfflineDataIfNeeded() async {
    if (_offlineProvider != null && _products.isEmpty) {
      await _offlineProvider!.loadOfflineData();
      if (_offlineProvider!.cachedProducts.isNotEmpty) {
        _products = _offlineProvider!.cachedProducts;
        _newProducts = _offlineProvider!.getNewProducts();
        _saleProducts = _offlineProvider!.getSaleProducts();
        _hotProducts = _offlineProvider!.getFeaturedProducts();
        _lastFetch = _offlineProvider!.lastUpdate;
        _applyFilters();
        debugPrint('تم تحميل ${_products.length} منتج من البيانات المحفوظة');
      }
    }
  }

  /// بدء مراقبة حالة الاتصال
  void startConnectivityMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final wasOffline = _isOffline;
        _isOffline = results.contains(ConnectivityResult.none) || results.isEmpty;
        
        if (wasOffline && !_isOffline) {
          // عاد الاتصال - جلب البيانات الجديدة
          fetchProducts(forceRefresh: true);
        } else if (!wasOffline && _isOffline) {
          // فُقد الاتصال - التبديل للبيانات المحفوظة
          _loadOfflineDataIfNeeded();
        }
        
        notifyListeners();
      },
    );
  }

  /// إيقاف مراقبة حالة الاتصال
  void stopConnectivityMonitoring() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// تنظيف الموارد عند إزالة الـ Provider
  @override
  void dispose() {
    stopRealTimeUpdates();
    stopConnectivityMonitoring();
    super.dispose();
  }
}


