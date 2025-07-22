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

class ProductProvider with ChangeNotifier {
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
  
  // Filter states
  bool _showOnSale = false;
  bool _showHotItems = false;
  bool _showNewArrivals = false;
  SortOption _sortOption = SortOption.newest;
  
  // Constants
  static const Duration _cacheExpiry = Duration(hours: 1);
  
  // Regular getters
  List<Product> get products => _filteredProducts.isEmpty ? _products : _filteredProducts;
  List<Product> get newProducts => _products.where((product) => product.isNew).toList();
  List<Product> get saleProducts => _products.where((product) => product.onSale).toList();
  List<Product> get hotProducts => _products.where((product) => product.isHot).toList();
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  bool get isOffline => _isOffline;
  
  bool get showOnSale => _showOnSale;
  bool get showHotItems => _showHotItems;
  bool get showNewArrivals => _showNewArrivals;
  SortOption get sortOption => _sortOption;
  
  ProductProvider() {
    _checkConnectivity();
    _loadCachedData();
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
  
  Future<void> _loadCachedData() async {
    try {
      final cachedProducts = await _cacheProvider.getCachedProducts();
      if (cachedProducts.isNotEmpty) {
        final lastUpdate = await _cacheProvider.getLastProductsUpdateTime();
        
        // Check if cache is still valid
        if (lastUpdate != null && 
            DateTime.now().difference(lastUpdate) < _cacheExpiry) {
          _products = cachedProducts;
          _lastFetch = lastUpdate;
          _applyFilters();
          debugPrint('📱 Loaded ${_products.length} products from cache');
          return;
        }
      }
      
      // If no valid cache, fetch from server
      if (!_isOffline) {
        await fetchProducts();
      }
    } catch (e) {
      debugPrint('❌ Error loading cached data: $e');
      if (!_isOffline) {
        await fetchProducts();
      }
    }
  }
  
  Future<void> fetchProducts({bool forceRefresh = false}) async {
    // Don't fetch if already loading
    if (_isLoading && !forceRefresh) return;
    
    // Check if cache is still valid and we don't need to force refresh
    if (!forceRefresh && _lastFetch != null && 
        DateTime.now().difference(_lastFetch!) < _cacheExpiry &&
        _products.isNotEmpty) {
      debugPrint('📱 Using cached products (still valid)');
      return;
    }
    
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
    
    try {
      debugPrint('🔄 Fetching products from server...');
      
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
      
      // Cache the data
      await _cacheProvider.cacheProducts(_products);
      await _cacheProvider.setLastProductsUpdateTime(_lastFetch!);
      
      // Cache images using offline image service
      _preloadProductImages();
      
      debugPrint('✅ Fetched ${_products.length} products successfully');
      
    } catch (error) {
      debugPrint('❌ Error fetching products: $error');
      _hasError = true;
      _errorMessage = error.toString();
      
      // Try to load from cache as fallback
      try {
        final cachedProducts = await _cacheProvider.getCachedProducts();
        if (cachedProducts.isNotEmpty) {
          _products = cachedProducts;
          _applyFilters();
          debugPrint('📱 Loaded ${_products.length} products from cache as fallback');
        }
      } catch (cacheError) {
        debugPrint('❌ Cache fallback failed: $cacheError');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<List<Product>> fetchProductsByCategory(String categoryId) async {
    try {
      debugPrint('🔄 Fetching products for category: $categoryId');
      
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
      debugPrint('❌ Error fetching category products: $error');
      rethrow;
    }
  }
  
  /// تحميل صور المنتجات مسبقاً باستخدام الخدمة المحسنة
  void _preloadProductImages() {
    if (_products.isEmpty) return;
    
    // تحميل الصور عالية الأولوية أولاً في المقدمة
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
    
    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final wasOffline = _isOffline;
      _isOffline = results.any((result) => result == ConnectivityResult.none);
      
      if (wasOffline && !_isOffline) {
        debugPrint('🔄 Connection restored, fetching fresh data');
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
    debugPrint('🗑️ Products cache cleared');
  }
}
