import 'package:flutter/material.dart';
import 'package:ecommerce/models/product.dart';
import 'package:ecommerce/services/supabase_service.dart';
import 'package:ecommerce/providers/cache_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ecommerce/services/offline_image_service.dart';

enum SortOption {
  newest,
  priceHighToLow,
  priceLowToHigh,
}

/// نسخة محسنة من ProductProvider مع دعم أفضل للوضع غير المتصل
class EnhancedProductProvider with ChangeNotifier {
  final _db = SupabaseService.client;
  final CacheProvider _cacheProvider = CacheProvider();
  final OfflineImageService _imageService = OfflineImageService();
  
  // Internal data
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  DateTime? _lastFetch;
  bool _isOffline = false;
  bool _isInitialized = false;
  
  // Filter states
  bool _showOnSale = false;
  bool _showHotItems = false;
  bool _showNewArrivals = false;
  SortOption _sortOption = SortOption.newest;
  
  // Constants
  static const Duration _cacheExpiry = Duration(hours: 2); // زيادة مدة الكاش إلى ساعتين
  static const Duration _offlineCacheExpiry = Duration(days: 7); // كاش للوضع غير المتصل لمدة أسبوع
  
  // Regular getters
  List<Product> get products => _filteredProducts.isEmpty ? _products : _filteredProducts;
  List<Product> get newProducts => _products.where((product) => product.isNew).toList();
  List<Product> get saleProducts => _products.where((product) => product.onSale).toList();
  List<Product> get hotProducts => _products.where((product) => product.isHot).toList();
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  bool get isOffline => _isOffline;
  bool get isInitialized => _isInitialized;
  
  bool get showOnSale => _showOnSale;
  bool get showHotItems => _showHotItems;
  bool get showNewArrivals => _showNewArrivals;
  SortOption get sortOption => _sortOption;
  
  EnhancedProductProvider() {
    _initialize();
  }
  
  /// تهيئة المزود
  Future<void> _initialize() async {
    await _checkConnectivity();
    await _loadCachedData();
    _isInitialized = true;
    notifyListeners();
  }
  
  // Filter methods
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
      _filteredProducts = _filteredProducts.where((product) => product.onSale).toList();
    }
    
    if (_showHotItems) {
      _filteredProducts = _filteredProducts.where((product) => product.isHot).toList();
    }
    
    if (_showNewArrivals) {
      _filteredProducts = _filteredProducts.where((product) => product.isNew).toList();
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
  
  /// تحميل البيانات المخزنة مؤقتاً مع دعم محسن للوضع غير المتصل
  Future<void> _loadCachedData() async {
    try {
      final cachedProducts = await _cacheProvider.getCachedProducts();
      if (cachedProducts.isNotEmpty) {
        final lastUpdate = await _cacheProvider.getLastProductsUpdateTime();
        
        // في الوضع المتصل، استخدم مدة انتهاء صلاحية أقصر
        // في الوضع غير المتصل، استخدم مدة أطول
        final expiryDuration = _isOffline ? _offlineCacheExpiry : _cacheExpiry;
        
        // تحقق من صحة الكاش
        if (lastUpdate != null && 
            DateTime.now().difference(lastUpdate) < expiryDuration) {
          _products = cachedProducts;
          _lastFetch = lastUpdate;
          _applyFilters();
          
          // تحميل الصور مسبقاً في الخلفية
          _preloadProductImages();
          
          debugPrint('📱 تم تحميل ${_products.length} منتج من الكاش');
          
          // إذا كان متصلاً، حاول جلب تحديثات في الخلفية
          if (!_isOffline) {
            _fetchInBackground();
          }
          return;
        }
      }
      
      // إذا لم يكن هناك كاش صالح، جرب جلب البيانات من الخادم
      if (!_isOffline) {
        await fetchProducts();
      } else {
        // في الوضع غير المتصل، استخدم أي كاش متاح حتى لو انتهت صلاحيته
        if (cachedProducts.isNotEmpty) {
          _products = cachedProducts;
          _applyFilters();
          debugPrint('📱 استخدام كاش منتهي الصلاحية في الوضع غير المتصل: ${_products.length} منتج');
        }
      }
    } catch (e) {
      debugPrint('❌ خطأ في تحميل البيانات المخزنة مؤقتاً: $e');
      if (!_isOffline) {
        await fetchProducts();
      }
    }
  }
  
  /// جلب البيانات في الخلفية دون عرض مؤشر التحميل
  Future<void> _fetchInBackground() async {
    try {
      debugPrint('🔄 جلب التحديثات في الخلفية...');
      
      final response = await _db
          .from('products')
          .select()
          .order('created_at', ascending: false);
      
      final newProducts = response.map<Product>((json) {
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

      // تحديث البيانات فقط إذا كانت مختلفة
      if (_productsChanged(newProducts)) {
        _products = newProducts;
        _lastFetch = DateTime.now();
        _applyFilters();
        
        // حفظ في الكاش
        await _cacheProvider.cacheProducts(_products);
        await _cacheProvider.setLastProductsUpdateTime(_lastFetch!);
        
        // تحميل الصور الجديدة
        _preloadProductImages();
        
        debugPrint('✅ تم تحديث ${_products.length} منتج في الخلفية');
      }
      
    } catch (error) {
      debugPrint('❌ خطأ في جلب التحديثات في الخلفية: $error');
    }
  }
  
  /// تحقق من تغيير المنتجات
  bool _productsChanged(List<Product> newProducts) {
    if (_products.length != newProducts.length) return true;
    
    for (int i = 0; i < _products.length; i++) {
      if (_products[i].id != newProducts[i].id ||
          _products[i].name != newProducts[i].name ||
          _products[i].price != newProducts[i].price) {
        return true;
      }
    }
    
    return false;
  }
  
  Future<void> fetchProducts({bool forceRefresh = false}) async {
    // منع التحميل المتعدد
    if (_isLoading && !forceRefresh) return;
    
    // تحقق من صحة الكاش إذا لم يكن تحديث إجباري
    if (!forceRefresh && _lastFetch != null && 
        DateTime.now().difference(_lastFetch!) < _cacheExpiry &&
        _products.isNotEmpty) {
      debugPrint('📱 استخدام المنتجات المخزنة مؤقتاً (لا تزال صالحة)');
      return;
    }
    
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
    
    try {
      debugPrint('🔄 جلب المنتجات من الخادم...');
      
      final response = await _db
          .from('products')
          .select()
          .order('created_at', ascending: false);
      
      _products = response.map<Product>((json) {
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

      _lastFetch = DateTime.now();
      _applyFilters();
      
      // حفظ البيانات في الكاش
      await _cacheProvider.cacheProducts(_products);
      await _cacheProvider.setLastProductsUpdateTime(_lastFetch!);
      
      // تحميل الصور مسبقاً
      _preloadProductImages();
      
      debugPrint('✅ تم جلب ${_products.length} منتج بنجاح');
      
    } catch (error) {
      debugPrint('❌ خطأ في جلب المنتجات: $error');
      _hasError = true;
      _errorMessage = error.toString();
      
      // محاولة تحميل من الكاش كحل بديل
      await _loadFromCacheAsFallback();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// تحميل من الكاش كحل بديل
  Future<void> _loadFromCacheAsFallback() async {
    try {
      final cachedProducts = await _cacheProvider.getCachedProducts();
      if (cachedProducts.isNotEmpty) {
        _products = cachedProducts;
        _applyFilters();
        _hasError = false; // إخفاء الخطأ لأننا وجدنا بيانات
        debugPrint('📱 تم تحميل ${_products.length} منتج من الكاش كحل بديل');
      }
    } catch (cacheError) {
      debugPrint('❌ فشل الحل البديل للكاش: $cacheError');
    }
  }
  
  Future<List<Product>> fetchProductsByCategory(String categoryId) async {
    try {
      debugPrint('🔄 جلب منتجات الفئة: $categoryId');
      
      final response = await _db
          .from('products')
          .select()
          .eq('category_id', categoryId)
          .order('created_at', ascending: false);
      
      return response.map<Product>((json) {
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
      
    } catch (error) {
      debugPrint('❌ خطأ في جلب منتجات الفئة: $error');
      rethrow;
    }
  }
  
  /// تحميل صور المنتجات مسبقاً باستخدام الخدمة المحسنة
  void _preloadProductImages() {
    if (_products.isEmpty) return;
    
    // تحميل الصور عالية الأولوية أولاً
    Future.microtask(() async {
      if (await _imageService.isOnline()) {
        await _imageService.preloadPriorityImages(_products);
        
        // ثم تحميل باقي الصور في الخلفية
        Future.delayed(const Duration(seconds: 2), () {
          _imageService.preloadProductImages(_products);
        });
      }
    });
  }
  
  /// تحميل صور منتج واحد مسبقاً
  Future<void> preloadSingleProductImages(Product product) async {
    await _imageService.preloadSingleProductImages(product);
  }
  
  /// الحصول على إحصائيات التخزين المؤقت للصور
  Future<Map<String, dynamic>> getImageCacheStats() async {
    return await _imageService.getCacheStats();
  }
  
  /// تنظيف صور التخزين المؤقت
  Future<void> cleanImageCache() async {
    await _imageService.cleanOldImages();
  }
  
  Future<void> _checkConnectivity() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    _isOffline = connectivityResults.any((result) => result == ConnectivityResult.none);
    
    // الاستماع لتغييرات الاتصال
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final wasOffline = _isOffline;
      _isOffline = results.any((result) => result == ConnectivityResult.none);
      
      if (wasOffline && !_isOffline) {
        debugPrint('🔄 تم استعادة الاتصال، جلب البيانات الجديدة');
        fetchProducts(forceRefresh: true);
      }
      
      notifyListeners();
    });
  }
  
  Future<void> refresh() async {
    await fetchProducts(forceRefresh: true);
  }
  
  Future<void> clearCache() async {
    await _cacheProvider.clearProductsCache();
    _products.clear();
    _filteredProducts.clear();
    _lastFetch = null;
    notifyListeners();
    debugPrint('🗑️ تم مسح كاش المنتجات');
  }
  
  /// الحصول على معلومات حالة الكاش
  Future<Map<String, dynamic>> getCacheInfo() async {
    final stats = await _cacheProvider.getCacheStats();
    final imageStats = await getImageCacheStats();
    
    return {
      'products_count': _products.length,
      'last_fetch': _lastFetch?.toIso8601String(),
      'is_offline': _isOffline,
      'cache_valid': _lastFetch != null && 
          DateTime.now().difference(_lastFetch!) < _cacheExpiry,
      'data_cache': stats,
      'image_cache': imageStats,
    };
  }
}

