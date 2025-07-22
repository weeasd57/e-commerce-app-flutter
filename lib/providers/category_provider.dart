import 'package:flutter/material.dart';
import 'package:ecommerce/models/category.dart';
import 'package:ecommerce/services/supabase_service.dart';
import 'package:ecommerce/providers/cache_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class CategoryProvider with ChangeNotifier {
  final _db = SupabaseService.client;
  final CacheProvider _cacheProvider = CacheProvider();
  
  // Internal data
  List<Category> _categories = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  DateTime? _lastFetch;
  bool _isOffline = false;
  
  // Constants
  static const Duration _cacheExpiry = Duration(hours: 1);
  
  // Regular getters
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  bool get isOffline => _isOffline;
  
  CategoryProvider() {
    _checkConnectivity();
    _loadCachedData();
  }
  
  Future<void> _loadCachedData() async {
    try {
      final cachedCategories = await _cacheProvider.getCachedCategories();
      if (cachedCategories.isNotEmpty) {
        final lastUpdate = await _cacheProvider.getLastCategoriesUpdateTime();
        
        // Check if cache is still valid
        if (lastUpdate != null && 
            DateTime.now().difference(lastUpdate) < _cacheExpiry) {
          _categories = cachedCategories;
          _lastFetch = lastUpdate;
          notifyListeners();
          debugPrint('📱 Loaded ${_categories.length} categories from cache');
          return;
        }
      }
      
      // If no valid cache, fetch from server
      if (!_isOffline) {
        await fetchCategories();
      }
    } catch (e) {
      debugPrint('❌ Error loading cached categories: $e');
      if (!_isOffline) {
        await fetchCategories();
      }
    }
  }
  
  Future<void> fetchCategories({bool forceRefresh = false}) async {
    // Don't fetch if already loading
    if (_isLoading && !forceRefresh) return;
    
    // Check if cache is still valid and we don't need to force refresh
    if (!forceRefresh && _lastFetch != null && 
        DateTime.now().difference(_lastFetch!) < _cacheExpiry &&
        _categories.isNotEmpty) {
      debugPrint('📱 Using cached categories (still valid)');
      return;
    }
    
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
    
    try {
      debugPrint('🔄 Fetching categories from server...');
      
      final response = await _db
          .from('categories')
          .select()
          .order('name', ascending: true);
      
      _categories = response.map<Category>((json) {
        return Category.fromMap({
          'id': json['id']?.toString() ?? '',
          ...json,
        });
      }).toList();

      _lastFetch = DateTime.now();
      
      // Cache the data
      await _cacheProvider.cacheCategories(_categories);
      await _cacheProvider.setLastCategoriesUpdateTime(_lastFetch!);
      
      // Cache images in background
      _cacheImagesInBackground();
      
      debugPrint('✅ Fetched ${_categories.length} categories successfully');
      
    } catch (error) {
      debugPrint('❌ Error fetching categories: $error');
      _hasError = true;
      _errorMessage = error.toString();
      
      // Try to load from cache as fallback
      try {
        final cachedCategories = await _cacheProvider.getCachedCategories();
        if (cachedCategories.isNotEmpty) {
          _categories = cachedCategories;
          debugPrint('📱 Loaded ${_categories.length} categories from cache as fallback');
        }
      } catch (cacheError) {
        debugPrint('❌ Cache fallback failed: $cacheError');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void _cacheImagesInBackground() {
    for (final category in _categories) {
      if (category.imageUrl?.isNotEmpty == true) {
        _cacheProvider.cacheImage(category.imageUrl!);
      }
    }
  }
  
  Future<void> _checkConnectivity() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    _isOffline = connectivityResults.any((result) => result == ConnectivityResult.none);
    
    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final wasOffline = _isOffline;
      _isOffline = results.any((result) => result == ConnectivityResult.none);
      
      if (wasOffline && !_isOffline) {
        debugPrint('🔄 Connection restored, fetching fresh categories');
        fetchCategories(forceRefresh: true);
      }
      
      notifyListeners();
    });
  }
  
  Future<void> refresh() async {
    await fetchCategories(forceRefresh: true);
  }
  
  Future<void> clearCache() async {
    await _cacheProvider.clearCategoriesCache();
    _categories.clear();
    _lastFetch = null;
    notifyListeners();
    debugPrint('🗑️ Categories cache cleared');
  }
  
  // Helper methods
  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }
  
  List<Category> searchCategories(String query) {
    if (query.isEmpty) return _categories;
    
    final lowercaseQuery = query.toLowerCase();
    return _categories.where((category) {
      return category.name.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}
