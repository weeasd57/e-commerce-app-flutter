import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/product.dart';
import '../models/category.dart' as CategoryModel;
import '../utils/image_cache_manager.dart';

/// خدمة إدارة الصور في الوضع غير المتصل
class OfflineImageService {
  static final OfflineImageService _instance = OfflineImageService._internal();
  factory OfflineImageService() => _instance;
  OfflineImageService._internal();

  final CustomImageCacheManager _cacheManager = CustomImageCacheManager();
  bool _isPreloadingImages = false;

  /// حالة تحميل الصور مسبقاً
  bool get isPreloadingImages => _isPreloadingImages;

  /// تحميل صور المنتجات مسبقاً
  Future<void> preloadProductImages(List<Product> products) async {
    if (_isPreloadingImages) return;

    try {
      _isPreloadingImages = true;
      
      // جمع جميع روابط الصور
      final Set<String> allImageUrls = {};
      
      for (final product in products) {
        for (final imageUrl in product.imageUrls) {
          if (imageUrl.isNotEmpty && 
              (imageUrl.startsWith('http') || imageUrl.startsWith('https'))) {
            allImageUrls.add(imageUrl);
          }
        }
      }

      if (allImageUrls.isEmpty) return;

      debugPrint('🖼️ بدء تحميل ${allImageUrls.length} صورة مسبقاً للمنتجات');

      // تحميل الصور في مجموعات صغيرة
      const batchSize = 5;
      final imageUrlsList = allImageUrls.toList();
      
      for (int i = 0; i < imageUrlsList.length; i += batchSize) {
        final endIndex = (i + batchSize < imageUrlsList.length) 
            ? i + batchSize 
            : imageUrlsList.length;
        final batch = imageUrlsList.sublist(i, endIndex);
        
        await _preloadBatch(batch);
        
        // استراحة قصيرة بين المجموعات
        await Future.delayed(const Duration(milliseconds: 100));
      }

      debugPrint('✅ تم تحميل صور المنتجات مسبقاً بنجاح');
      
    } catch (e) {
      debugPrint('❌ خطأ في تحميل صور المنتجات مسبقاً: $e');
    } finally {
      _isPreloadingImages = false;
    }
  }

  /// تحميل صور الفئات مسبقاً
  Future<void> preloadCategoryImages(List<CategoryModel.Category> categories) async {
    try {
      final List<String> imageUrls = [];
      
      for (final category in categories) {
        if (category.imageUrl != null && 
            category.imageUrl!.isNotEmpty &&
            (category.imageUrl!.startsWith('http') || 
             category.imageUrl!.startsWith('https'))) {
          imageUrls.add(category.imageUrl!);
        }
      }

      if (imageUrls.isEmpty) return;

      debugPrint('🖼️ بدء تحميل ${imageUrls.length} صورة مسبقاً للفئات');

      await _cacheManager.preloadImages(imageUrls);
      
      debugPrint('✅ تم تحميل صور الفئات مسبقاً بنجاح');
      
    } catch (e) {
      debugPrint('❌ خطأ في تحميل صور الفئات مسبقاً: $e');
    }
  }

  /// تحميل مجموعة من الصور
  Future<void> _preloadBatch(List<String> imageUrls) async {
    final List<Future> futures = imageUrls.map((url) async {
      try {
        await _cacheManager.downloadFile(url);
        debugPrint('✅ تم تحميل: ${_getShortUrl(url)}');
      } catch (e) {
        debugPrint('❌ فشل تحميل: ${_getShortUrl(url)} - $e');
      }
    }).toList();

    await Future.wait(futures);
  }

  /// فحص الاتصال بالإنترنت
  Future<bool> isOnline() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      debugPrint('خطأ في فحص الاتصال: $e');
      return false;
    }
  }

  /// التحقق من وجود صورة في التخزين المؤقت
  Future<bool> isImageCached(String imageUrl) async {
    if (imageUrl.isEmpty) return false;
    try {
      return await _cacheManager.isImageCached(imageUrl);
    } catch (e) {
      debugPrint('خطأ في فحص التخزين المؤقت للصورة: $e');
      return false;
    }
  }

  /// حذف الصور القديمة
  Future<void> cleanOldImages() async {
    try {
      await _cacheManager.cleanOldImages();
      debugPrint('✅ تم تنظيف الصور القديمة');
    } catch (e) {
      debugPrint('❌ خطأ في تنظيف الصور القديمة: $e');
    }
  }

  /// الحصول على إحصائيات التخزين المؤقت
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final size = await _cacheManager.getCacheSize();
      return {
        'size': size,
        'sizeFormatted': CustomImageCacheManager.formatBytes(size),
        'isPreloading': _isPreloadingImages,
      };
    } catch (e) {
      debugPrint('خطأ في الحصول على إحصائيات التخزين المؤقت: $e');
      return {
        'size': 0,
        'sizeFormatted': '0 B',
        'isPreloading': false,
      };
    }
  }

  /// تحميل صور عربة التسوق مسبقاً
  Future<void> preloadCartImages(List<String> imageUrls) async {
    if (imageUrls.isEmpty) return;

    try {
      final validUrls = imageUrls
          .where((url) => url.isNotEmpty && 
                        (url.startsWith('http') || url.startsWith('https')))
          .toList();

      if (validUrls.isEmpty) return;

      debugPrint('🛒 بدء تحميل ${validUrls.length} صورة للسلة مسبقاً');
      
      await _cacheManager.preloadImages(validUrls);
      
      debugPrint('✅ تم تحميل صور السلة مسبقاً بنجاح');
      
    } catch (e) {
      debugPrint('❌ خطأ في تحميل صور السلة مسبقاً: $e');
    }
  }

  /// تحميل صور منتج واحد مسبقاً
  Future<void> preloadSingleProductImages(Product product) async {
    if (product.imageUrls.isEmpty) return;

    try {
      final validUrls = product.imageUrls
          .where((url) => url.isNotEmpty && 
                        (url.startsWith('http') || url.startsWith('https')))
          .toList();

      if (validUrls.isEmpty) return;

      debugPrint('📱 بدء تحميل ${validUrls.length} صورة للمنتج ${product.name} مسبقاً');
      
      await _cacheManager.preloadImages(validUrls);
      
      debugPrint('✅ تم تحميل صور المنتج ${product.name} مسبقاً بنجاح');
      
    } catch (e) {
      debugPrint('❌ خطأ في تحميل صور المنتج ${product.name} مسبقاً: $e');
    }
  }

  /// تحميل أهم الصور أولاً (الصور الأولى لكل منتج)
  Future<void> preloadPriorityImages(List<Product> products) async {
    try {
      final priorityUrls = <String>[];
      
      for (final product in products) {
        // أخذ أول صورة فقط من كل منتج
        if (product.imageUrls.isNotEmpty) {
          final firstImage = product.imageUrls.first;
          if (firstImage.isNotEmpty && 
              (firstImage.startsWith('http') || firstImage.startsWith('https'))) {
            priorityUrls.add(firstImage);
          }
        }
      }

      if (priorityUrls.isEmpty) return;

      debugPrint('⭐ بدء تحميل ${priorityUrls.length} صورة عالية الأولوية مسبقاً');
      
      await _cacheManager.preloadImages(priorityUrls);
      
      debugPrint('✅ تم تحميل الصور عالية الأولوية مسبقاً بنجاح');
      
    } catch (e) {
      debugPrint('❌ خطأ في تحميل الصور عالية الأولوية مسبقاً: $e');
    }
  }

  /// إعادة تعيين الخدمة
  void reset() {
    _isPreloadingImages = false;
  }

  /// الحصول على URL مختصر للطباعة
  String _getShortUrl(String url) {
    if (url.length <= 50) return url;
    return '${url.substring(0, 25)}...${url.substring(url.length - 20)}';
  }
}
