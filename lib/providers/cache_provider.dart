import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce/models/product.dart';
import 'package:ecommerce/models/category.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CacheProvider {
  static const String _productsKey = 'cached_products';
  static const String _categoriesKey = 'cached_categories';
  static const String _productsUpdateKey = 'products_last_update';
  static const String _categoriesUpdateKey = 'categories_last_update';
  
  static const Duration _defaultCacheExpiry = Duration(hours: 6);
  
  // Cache products
  Future<void> cacheProducts(List<Product> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = products.map((product) => product.toMap()).toList();
      final jsonString = json.encode(productsJson);
      
      await prefs.setString(_productsKey, jsonString);
      debugPrint('✅ Cached ${products.length} products');
    } catch (e) {
      debugPrint('❌ Error caching products: $e');
    }
  }
  
  Future<List<Product>> getCachedProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_productsKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final List<dynamic> jsonList = json.decode(jsonString);
      final products = jsonList.map((json) => Product.fromMap(json)).toList();
      
      debugPrint('📱 Retrieved ${products.length} cached products');
      return products;
    } catch (e) {
      debugPrint('❌ Error retrieving cached products: $e');
      return [];
    }
  }
  
  // Cache categories
  Future<void> cacheCategories(List<Category> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = categories.map((category) => category.toMap()).toList();
      final jsonString = json.encode(categoriesJson);
      
      await prefs.setString(_categoriesKey, jsonString);
      debugPrint('✅ Cached ${categories.length} categories');
    } catch (e) {
      debugPrint('❌ Error caching categories: $e');
    }
  }
  
  Future<List<Category>> getCachedCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_categoriesKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final List<dynamic> jsonList = json.decode(jsonString);
      final categories = jsonList.map((json) => Category.fromMap(json)).toList();
      
      debugPrint('📱 Retrieved ${categories.length} cached categories');
      return categories;
    } catch (e) {
      debugPrint('❌ Error retrieving cached categories: $e');
      return [];
    }
  }
  
  // Cache timestamps
  Future<void> setLastProductsUpdateTime(DateTime dateTime) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_productsUpdateKey, dateTime.millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('❌ Error setting products update time: $e');
    }
  }
  
  Future<DateTime?> getLastProductsUpdateTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_productsUpdateKey);
      
      if (timestamp == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      debugPrint('❌ Error getting products update time: $e');
      return null;
    }
  }
  
  Future<void> setLastCategoriesUpdateTime(DateTime dateTime) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_categoriesUpdateKey, dateTime.millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('❌ Error setting categories update time: $e');
    }
  }
  
  Future<DateTime?> getLastCategoriesUpdateTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_categoriesUpdateKey);
      
      if (timestamp == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      debugPrint('❌ Error getting categories update time: $e');
      return null;
    }
  }
  
  // Image caching
  Future<void> cacheImage(String imageUrl, [BuildContext? context]) async {
    try {
      // Use flutter_cache_manager to cache the image
      final cacheManager = DefaultCacheManager();
      await cacheManager.downloadFile(imageUrl);
      
      // Pre-cache the image if context is available
      if (context != null && context.mounted) {
        final imageProvider = CachedNetworkImageProvider(imageUrl);
        await precacheImage(imageProvider, context);
      }
      
      debugPrint('✅ Cached image: ${_getShortUrl(imageUrl)}');
    } catch (e) {
      debugPrint('❌ Error caching image: $e');
    }
  }
  
  Future<File?> getCachedImageFile(String imageUrl) async {
    try {
      // على الويب، لا يمكن الوصول إلى ملفات النظام
      if (kIsWeb) {
        debugPrint('🌐 File access not available on web platform');
        return null;
      }
      
      final cacheManager = DefaultCacheManager();
      final fileInfo = await cacheManager.getFileFromCache(imageUrl);
      
      return fileInfo?.file;
    } catch (e) {
      debugPrint('❌ Error getting cached image file: $e');
      return null;
    }
  }
  
  Future<void> preloadImages(List<String> imageUrls) async {
    debugPrint('🖼️ Preloading ${imageUrls.length} images...');
    
    for (int i = 0; i < imageUrls.length; i++) {
      final imageUrl = imageUrls[i];
      try {
        await cacheImage(imageUrl);
        
        // Add small delay to avoid overwhelming the system
        if (i % 5 == 0) {
          await Future.delayed(Duration(milliseconds: 100));
        }
      } catch (e) {
        debugPrint('❌ Failed to preload image $i: $e');
      }
    }
    
    debugPrint('✅ Finished preloading images');
  }
  
  // Cache validation
  Future<bool> isProductsCacheValid([Duration? customExpiry]) async {
    try {
      final lastUpdate = await getLastProductsUpdateTime();
      if (lastUpdate == null) return false;
      
      final expiry = customExpiry ?? _defaultCacheExpiry;
      final now = DateTime.now();
      
      return now.difference(lastUpdate) < expiry;
    } catch (e) {
      debugPrint('❌ Error checking products cache validity: $e');
      return false;
    }
  }
  
  Future<bool> isCategoriesCacheValid([Duration? customExpiry]) async {
    try {
      final lastUpdate = await getLastCategoriesUpdateTime();
      if (lastUpdate == null) return false;
      
      final expiry = customExpiry ?? _defaultCacheExpiry;
      final now = DateTime.now();
      
      return now.difference(lastUpdate) < expiry;
    } catch (e) {
      debugPrint('❌ Error checking categories cache validity: $e');
      return false;
    }
  }
  
  // Clear cache methods
  Future<void> clearProductsCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_productsKey);
      await prefs.remove(_productsUpdateKey);
      debugPrint('🗑️ Products cache cleared');
    } catch (e) {
      debugPrint('❌ Error clearing products cache: $e');
    }
  }
  
  Future<void> clearCategoriesCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_categoriesKey);
      await prefs.remove(_categoriesUpdateKey);
      debugPrint('🗑️ Categories cache cleared');
    } catch (e) {
      debugPrint('❌ Error clearing categories cache: $e');
    }
  }
  
  Future<void> clearImagesCache() async {
    try {
      final cacheManager = DefaultCacheManager();
      await cacheManager.emptyCache();
      debugPrint('🗑️ Images cache cleared');
    } catch (e) {
      debugPrint('❌ Error clearing images cache: $e');
    }
  }
  
  Future<void> clearAllCache() async {
    await Future.wait([
      clearProductsCache(),
      clearCategoriesCache(),
      clearImagesCache(),
    ]);
    debugPrint('🗑️ All cache cleared');
  }
  
  // Cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsCache = prefs.getString(_productsKey);
      final categoriesCache = prefs.getString(_categoriesKey);
      final productsLastUpdate = await getLastProductsUpdateTime();
      final categoriesLastUpdate = await getLastCategoriesUpdateTime();
      
      return {
        'products_cached': productsCache != null,
        'categories_cached': categoriesCache != null,
        'products_cache_size': productsCache?.length ?? 0,
        'categories_cache_size': categoriesCache?.length ?? 0,
        'products_last_update': productsLastUpdate?.toIso8601String(),
        'categories_last_update': categoriesLastUpdate?.toIso8601String(),
        'products_cache_valid': await isProductsCacheValid(),
        'categories_cache_valid': await isCategoriesCacheValid(),
      };
    } catch (e) {
      debugPrint('❌ Error getting cache stats: $e');
      return {};
    }
  }
  
  // Helper methods
  String _getShortUrl(String url) {
    if (url.length > 50) {
      return '${url.substring(0, 25)}...${url.substring(url.length - 25)}';
    }
    return url;
  }
  
}

