import 'package:flutter/material.dart';
import 'dart:async';
import 'package:ecommerce/models/category.dart';
import 'package:ecommerce/services/supabase_service.dart';
import 'package:ecommerce/providers/cache_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class FlutterStreamCategoryProvider with ChangeNotifier {
  final _db = SupabaseService.client;
  final CacheProvider _cacheProvider = CacheProvider();
  
  // Data streams
  final StreamController<List<Category>> _categoriesController = StreamController<List<Category>>.broadcast();
  final StreamController<bool> _loadingController = StreamController<bool>.broadcast();
  
  // Internal data
  List<Category> _categories = [];
  bool _isLoading = false;
  bool _hasError = false;
  DateTime? _lastFetch;
  bool _isOffline = false;
  
  // Subscriptions
  Timer? _refreshTimer;
  StreamSubscription? _connectivitySubscription;
  
  // Constants
  static const Duration _refreshInterval = Duration(minutes: 10);
  static const Duration _cacheExpiry = Duration(hours: 2);
  
  // Getters for streams
  Stream<List<Category>> get categoriesStream => _categoriesController.stream;
  Stream<bool> get loadingStream => _loadingController.stream;
  
  // Regular getters
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  bool get isOffline => _isOffline;
  
  FlutterStreamCategoryProvider() {
    _initializeProvider();
  }
  
  void _initializeProvider() {
    debugPrint('🚀 Initializing Flutter Stream Category Provider');
    _startConnectivityMonitoring();
    _loadCachedData();
    _startPeriodicRefresh();
  }
  
  void _updateStreams() {
    if (!_categoriesController.isClosed) {
      _categoriesController.add(_categories);
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
      final cachedCategories = await _cacheProvider.getCachedCategories();
      if (cachedCategories.isNotEmpty) {
        _categories = cachedCategories;
        _lastFetch = await _cacheProvider.getLastCategoriesUpdateTime();
        _updateStreams();
        debugPrint('📱 Loaded ${_categories.length} categories from cache');
      }
    } catch (e) {
      debugPrint('❌ Error loading cached categories: $e');
    }
  }
  
  Future<void> fetchCategories({bool forceRefresh = false}) async {
    // Avoid multiple simultaneous fetches
    if (_isLoading && !forceRefresh) return;
    
    // Check if cache is still valid
    if (!forceRefresh && _lastFetch != null && _categories.isNotEmpty) {
      final timeSinceLastFetch = DateTime.now().difference(_lastFetch!);
      if (timeSinceLastFetch < _cacheExpiry) {
        debugPrint('📦 Using cached categories (age: ${timeSinceLastFetch.inMinutes} min)');
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
        if (_categories.isEmpty) {
          await _loadCachedData();
        }
        _setLoading(false);
        return;
      } else {
        _isOffline = false;
      }
      
      debugPrint('🌐 Fetching categories from Supabase...');
      
      // Fetch categories from Supabase
      final List<Map<String, dynamic>> categoriesData = await _db
          .from('categories')
          .select();
      
      if (categoriesData.isEmpty) {
        debugPrint('No categories found in database, creating sample data...');
        await _createSampleCategories();
        
        // Try fetching again after creating sample data
        final retryData = await _db
            .from('categories')
            .select();
        
        if (retryData.isNotEmpty) {
          debugPrint('Sample categories created successfully, processing...');
          _processFetchedCategories(retryData);
        } else {
          debugPrint('Failed to create sample categories');
          _categories = [];
        }
      } else {
        _processFetchedCategories(categoriesData);
      }
      
      _lastFetch = DateTime.now();
      
      // Cache the data
      await _cacheProvider.cacheCategories(_categories);
      await _cacheProvider.setLastCategoriesUpdateTime(_lastFetch!);
      
      // Cache category images in background
      _cacheImagesInBackground();
      
      debugPrint('✅ Successfully fetched ${_categories.length} categories');
      
    } catch (e) {
      debugPrint('❌ Error fetching categories: $e');
      _hasError = true;
      
      // Try to load cached data as fallback
      if (_categories.isEmpty) {
        await _loadCachedData();
      }
    } finally {
      _setLoading(false);
    }
  }
  
  void _processFetchedCategories(List<Map<String, dynamic>> categoriesData) {
    try {
      _categories = categoriesData.map((data) {
        return Category.fromMap({
          'id': data['id']?.toString() ?? '',
          'name': data['name']?.toString() ?? 'Unknown',
          'icon': data['icon']?.toString(),
          'imageUrl': data['image_url']?.toString(),
          ...data,
        });
      }).toList();
      
      _updateStreams();
      
    } catch (e) {
      debugPrint('❌ Error processing categories: $e');
      _categories = [];
      _updateStreams();
    }
  }
  
  void _cacheImagesInBackground() {
    for (final category in _categories) {
      if (category.imageUrl != null && category.imageUrl!.isNotEmpty) {
        _cacheProvider.cacheImage(category.imageUrl!);
      }
    }
  }
  
  Future<void> _createSampleCategories() async {
    try {
      final sampleCategories = [
        {
          'name': 'public',
          'description': 'Public category',
          'icon': 'public',
          'color': '#2196F3',
        },
        {
          'name': 'المدارس',
          'description': 'Schools category',
          'icon': 'school',
          'color': '#4CAF50',
        },
        {
          'name': 'المنزل والحديقة',
          'description': 'Home and garden category',
          'icon': 'home',
          'color': '#FF9800',
        },
      ];
      
      await _db.from('categories').insert(sampleCategories);
      debugPrint('✅ Sample categories inserted successfully');
    } catch (e) {
      debugPrint('❌ Error creating sample categories: $e');
    }
  }
  
  void _startConnectivityMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final wasOffline = _isOffline;
        _isOffline = results.any((result) => result == ConnectivityResult.none);
        
        if (wasOffline && !_isOffline) {
          // Connection restored - fetch fresh data
          debugPrint('🔄 Connection restored, fetching fresh categories');
          fetchCategories(forceRefresh: true);
        } else if (!wasOffline && _isOffline) {
          // Connection lost - use cached data
          debugPrint('📱 Connection lost, using cached categories');
          _loadCachedData();
        }
        
        notifyListeners();
      },
    );
  }
  
  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(_refreshInterval, (timer) {
      if (!_isOffline && !_isLoading) {
        debugPrint('⏰ Periodic categories refresh triggered');
        fetchCategories();
      }
    });
  }
  
  Future<void> refresh() async {
    await fetchCategories(forceRefresh: true);
  }
  
  Future<void> clearCache() async {
    await _cacheProvider.clearCategoriesCache();
    _categories.clear();
    _lastFetch = null;
    _updateStreams();
    notifyListeners();
    debugPrint('🗑️ Categories cache cleared');
  }
  
  // Helper method to get category by ID
  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Helper method to search categories
  List<Category> searchCategories(String query) {
    if (query.isEmpty) return _categories;
    
    return _categories.where((category) {
      return category.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
  
  @override
  void dispose() {
    debugPrint('🧹 Disposing Flutter Stream Category Provider');
    _refreshTimer?.cancel();
    _connectivitySubscription?.cancel();
    
    _categoriesController.close();
    _loadingController.close();
    
    super.dispose();
  }
}
