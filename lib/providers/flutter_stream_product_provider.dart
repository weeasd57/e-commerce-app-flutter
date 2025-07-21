import 'package:flutter/material.dart';
import 'dart:async';
import 'package:ecommerce/models/product.dart';
import 'package:ecommerce/services/supabase_service.dart';
import 'package:ecommerce/providers/cache_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum SortOption {
  newest,
  priceHighToLow,
  priceLowToHigh,
}

class FlutterStreamProductProvider with ChangeNotifier {
  final _db = SupabaseService.client;
  final CacheProvider _cacheProvider = CacheProvider();
  
  // Data streams
  final StreamController<List<Product>> _productsController = StreamController<List<Product>>.broadcast();
  final StreamController<List<Product>> _newProductsController = StreamController<List<Product>>.broadcast();
  final StreamController<List<Product>> _saleProductsController = StreamController<List<Product>>.broadcast();
  final StreamController<List<Product>> _hotProductsController = StreamController<List<Product>>.broadcast();
  final StreamController<bool> _loadingController = StreamController<bool>.broadcast();
  
  // Internal data
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  bool _hasError = false;
  DateTime? _lastFetch;
  bool _isOffline = false;
  
  // Subscriptions
  Timer? _refreshTimer;
  StreamSubscription? _connectivitySubscription;
  
  // Filter states
  bool _showOnSale = false;
  bool _showHotItems = false;
  bool _showNewArrivals = false;
  SortOption _sortOption = SortOption.newest;
  
  // Constants
  static const Duration _refreshInterval = Duration(minutes: 5);
  static const Duration _cacheExpiry = Duration(hours: 1);
  
  // Getters for streams
  Stream<List<Product>> get productsStream => _productsController.stream;
  Stream<List<Product>> get newProductsStream => _newProductsController.stream;
  Stream<List<Product>> get saleProductsStream => _saleProductsController.stream;
  Stream<List<Product>> get hotProductsStream => _hotProductsController.stream;
  Stream<bool> get loadingStream => _loadingController.stream;
  
  // Regular getters
  List<Product> get products => _filteredProducts.isEmpty ? _products : _filteredProducts;
  List<Product> get newProducts => _products.where((product) => product.isNew).toList();
  List<Product> get saleProducts => _products.where((product) => product.onSale).toList();
  List<Product> get hotProducts => _products.where((product) => product.isHot).toList();
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  bool get isOffline => _isOffline;
  
  bool get showOnSale => _showOnSale;
  bool get showHotItems => _showHotItems;
  bool get showNewArrivals => _showNewArrivals;
  SortOption get sortOption => _sortOption;
  
  FlutterStreamProductProvider() {
    _initializeProvider();
  }
  
  void _initializeProvider() {
    debugPrint('🚀 Initializing Flutter Stream Product Provider');
    _startConnectivityMonitoring();
    _loadCachedData();
    _startPeriodicRefresh();
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
    _updateStreams();
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
    
    _updateStreams();
    notifyListeners();
  }
  
  void _updateStreams() {
    if (!_productsController.isClosed) {
      _productsController.add(products);
    }
    if (!_newProductsController.isClosed) {
      _newProductsController.add(newProducts);
    }
    if (!_saleProductsController.isClosed) {
      _saleProductsController.add(saleProducts);
    }
    if (!_hotProductsController.isClosed) {
      _hotProductsController.add(hotProducts);
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (!_loadingController.isClosed) {
      _loadingController.add(_isLoading);
    }
    notifyListeners();
  }
  
  Future<void> _loadCachedData() async {
    try {
      final cachedProducts = await _cacheProvider.getCachedProducts();
      if (cachedProducts.isNotEmpty) {
        _products = cachedProducts;
        _lastFetch = await _cacheProvider.getLastProductsUpdateTime();
        _applyFilters();
        debugPrint('📱 Loaded ${_products.length} products from cache');
      }
    } catch (e) {
      debugPrint('❌ Error loading cached data: $e');
    }
  }
  
  Future<void> fetchProducts({bool forceRefresh = false}) async {
    // Avoid multiple simultaneous fetches
    if (_isLoading && !forceRefresh) return;
    
    // Check if cache is still valid
    if (!forceRefresh && _lastFetch != null && _products.isNotEmpty) {
      final timeSinceLastFetch = DateTime.now().difference(_lastFetch!);
      if (timeSinceLastFetch < _cacheExpiry) {
        debugPrint('📦 Using cached products (age: ${timeSinceLastFetch.inMinutes} min)');
        return;
      }
    }
    
    _setLoading(true);
    _hasError = false;
    
    try {
      // Check connectivity
      List<ConnectivityResult> connectivityResults = await Connectivity().checkConnectivity();
      if (connectivityResults.contains(ConnectivityResult.none)) {
        _isOffline = true;
        // Use cached data if available
        if (_products.isEmpty) {
          await _loadCachedData();
        }
        _setLoading(false);
        return;
      } else {
        _isOffline = false;
      }
      
      debugPrint('🌐 Fetching products from Supabase...');
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
      
      _lastFetch = DateTime.now();
      _applyFilters();
      
      // Cache the data
      await _cacheProvider.cacheProducts(_products);
      await _cacheProvider.setLastProductsUpdateTime(_lastFetch!);
      
      // Cache images in background
      _cacheImagesInBackground();
      
      debugPrint('✅ Successfully fetched ${_products.length} products');
      
    } catch (e) {
      debugPrint('❌ Error fetching products: $e');
      _hasError = true;
      
      // Try to load cached data as fallback
      if (_products.isEmpty) {
        await _loadCachedData();
      }
    } finally {
      _setLoading(false);
    }
  }
  
  void _cacheImagesInBackground() {
    for (final product in _products) {
      if (product.imageUrls.isNotEmpty) {
        for (final imageUrl in product.imageUrls) {
          _cacheProvider.cacheImage(imageUrl);
        }
      }
    }
  }
  
  Future<List<Product>> fetchProductsByCategory(String categoryId) async {
    try {
      final List<Map<String, dynamic>> productsData = await _db
          .from('products')
          .select()
          .eq('category_id', categoryId)
          .order('created_at', ascending: false);
      
      return productsData.map((data) {
        DateTime createdAt;
        String? age;
        
        try {
          final createdAtData = data['created_at'];
          if (createdAtData is String) {
            createdAt = DateTime.parse(createdAtData);
          } else {
            createdAt = DateTime.now();
          }
        } catch (e) {
          createdAt = DateTime.now();
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
      debugPrint('❌ Error fetching products by category: $e');
      return [];
    }
  }
  
  void _startConnectivityMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final wasOffline = _isOffline;
        _isOffline = results.any((result) => result == ConnectivityResult.none);
        
        if (wasOffline && !_isOffline) {
          // Connection restored - fetch fresh data
          debugPrint('🔄 Connection restored, fetching fresh data');
          fetchProducts(forceRefresh: true);
        } else if (!wasOffline && _isOffline) {
          // Connection lost - use cached data
          debugPrint('📱 Connection lost, using cached data');
          _loadCachedData();
        }
        
        notifyListeners();
      },
    );
  }
  
  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(_refreshInterval, (timer) {
      if (!_isOffline && !_isLoading) {
        debugPrint('⏰ Periodic refresh triggered');
        fetchProducts();
      }
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
    _updateStreams();
    notifyListeners();
    debugPrint('🗑️ Products cache cleared');
  }
  
  @override
  void dispose() {
    debugPrint('🧹 Disposing Flutter Stream Product Provider');
    _refreshTimer?.cancel();
    _connectivitySubscription?.cancel();
    
    _productsController.close();
    _newProductsController.close();
    _saleProductsController.close();
    _hotProductsController.close();
    _loadingController.close();
    
    super.dispose();
  }
}
