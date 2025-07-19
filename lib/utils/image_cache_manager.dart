import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/material.dart';

/// مدير التخزين المؤقت المخصص للصور
class CustomImageCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'ecommerceImageCache';
  static CustomImageCacheManager? _instance;

  factory CustomImageCacheManager() {
    return _instance ??= CustomImageCacheManager._();
  }

  CustomImageCacheManager._()
      : super(
          Config(
            key,
            stalePeriod: const Duration(days: 30), // فترة انتهاء الصلاحية 30 يوم
            maxNrOfCacheObjects: 1000, // أقصى عدد من الكائنات المخزنة مؤقتا
            repo: JsonCacheInfoRepository(databaseName: key),
            fileService: HttpFileService(),
          ),
        );

  /// محو الصور القديمة غير المستخدمة
  Future<void> cleanOldImages() async {
    try {
      // محو الملفات القديمة التي تجاوزت المدة المحددة
      await emptyCache();
      debugPrint('تم تنظيف ذاكرة التخزين المؤقت للصور');
    } catch (e) {
      debugPrint('خطأ في تنظيف ذاكرة التخزين المؤقت: $e');
    }
  }

  /// تحميل مسبق للصور الهامة
  Future<void> preloadImages(List<String> imageUrls) async {
    for (String url in imageUrls) {
      if (url.isNotEmpty && (url.startsWith('http') || url.startsWith('https'))) {
        try {
          await downloadFile(url);
          debugPrint('تم تحميل الصورة مسبقاً: $url');
        } catch (e) {
          debugPrint('فشل في تحميل الصورة مسبقاً: $url - $e');
        }
      }
    }
  }

  /// التحقق من وجود الصورة في التخزين المؤقت
  Future<bool> isImageCached(String url) async {
    try {
      final fileInfo = await getFileFromCache(url);
      return fileInfo != null;
    } catch (e) {
      return false;
    }
  }

  /// الحصول على حجم التخزين المؤقت
  Future<int> getCacheSize() async {
    try {
      final cacheFiles = await getFilesFromCache();
      int totalSize = 0;
      for (var fileInfo in cacheFiles) {
        final file = fileInfo.file;
        if (await file.exists()) {
          totalSize += await file.length();
        }
      }
      return totalSize;
    } catch (e) {
      debugPrint('خطأ في حساب حجم التخزين المؤقت: $e');
      return 0;
    }
  }

  /// تحويل حجم البايتات إلى نص قابل للقراءة
  static String formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    var i = 0;
    double size = bytes.toDouble();
    
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    
    return "${size.toStringAsFixed(2)} ${suffixes[i]}";
  }
}

/// كلاس مساعد لإدارة الصور في السلة
class CartImageManager {
  static final CustomImageCacheManager _cacheManager = CustomImageCacheManager();
  
  /// تحميل الصور مسبقاً للعناصر في السلة
  static Future<void> preloadCartImages(List<String> imageUrls) async {
    final validUrls = imageUrls
        .where((url) => url.isNotEmpty && (url.startsWith('http') || url.startsWith('https')))
        .toList();
    
    if (validUrls.isNotEmpty) {
      await _cacheManager.preloadImages(validUrls);
      debugPrint('تم تحميل ${validUrls.length} صورة للسلة مسبقاً');
    }
  }
  
  /// التحقق من حالة التخزين المؤقت
  static Future<Map<String, dynamic>> getCacheStatus() async {
    final cacheSize = await _cacheManager.getCacheSize();
    final cacheFiles = await _cacheManager.getFilesFromCache();
    
    return {
      'size': cacheSize,
      'sizeFormatted': CustomImageCacheManager.formatBytes(cacheSize),
      'filesCount': cacheFiles.length,
    };
  }
  
  /// تنظيف التخزين المؤقت
  static Future<void> clearCache() async {
    await _cacheManager.cleanOldImages();
  }
}
