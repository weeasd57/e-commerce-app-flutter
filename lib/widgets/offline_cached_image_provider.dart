import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/image_cache_manager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Image Provider للصور المحفوظة مؤقتاً مع دعم الوضع غير المتصل
class OfflineCachedImageProvider extends ImageProvider<OfflineCachedImageProvider> {
  final String imageUrl;
  final String? cacheKey;
  final CustomImageCacheManager _cacheManager = CustomImageCacheManager();

  OfflineCachedImageProvider(
    this.imageUrl, {
    this.cacheKey,
  });

  @override
  Future<OfflineCachedImageProvider> obtainKey(ImageConfiguration configuration) {
    return Future.value(this);
  }

  @override
  ImageStreamCompleter loadImage(OfflineCachedImageProvider key, ImageDecoderCallback decode) {
    // استخدام CachedNetworkImageProvider مع مدير التخزين المؤقت المخصص
    final provider = CachedNetworkImageProvider(
      imageUrl,
      cacheKey: cacheKey,
      cacheManager: _cacheManager,
    );
    
    return provider.loadImage(provider, decode);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is OfflineCachedImageProvider
        && other.imageUrl == imageUrl
        && other.cacheKey == cacheKey;
  }

  @override
  int get hashCode => Object.hash(imageUrl, cacheKey);

  @override
  String toString() => 'OfflineCachedImageProvider("$imageUrl", cacheKey: "$cacheKey")';
}

/// Widget شامل للصور المحفوظة مؤقتاً مع دعم الوضع غير المتصل
class OfflineCachedImage extends StatefulWidget {
  final String imageUrl;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final String? cacheKey;
  final Duration fadeInDuration;
  final Duration fadeOutDuration;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Widget? offlineWidget;
  final bool showOfflineIndicator;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final bool enableAutoCache;
  final bool enablePreload;
  final VoidCallback? onLoadComplete;
  final Function(Object)? onError;

  const OfflineCachedImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.memCacheWidth,
    this.memCacheHeight,
    this.cacheKey,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.fadeOutDuration = const Duration(milliseconds: 300),
    this.placeholder,
    this.errorWidget,
    this.offlineWidget,
    this.showOfflineIndicator = true,
    this.borderRadius,
    this.backgroundColor,
    this.enableAutoCache = true,
    this.enablePreload = false,
    this.onLoadComplete,
    this.onError,
  });

  @override
  State<OfflineCachedImage> createState() => _OfflineCachedImageState();
}

class _OfflineCachedImageState extends State<OfflineCachedImage> {
  final CustomImageCacheManager _cacheManager = CustomImageCacheManager();
  bool _isOffline = false;
  bool _isImageCached = false;

  @override
  void initState() {
    super.initState();
    _initializeImageState();
  }

  /// تهيئة حالة الصورة والتحقق من الاتصال
  Future<void> _initializeImageState() async {
    if (!mounted) return;

    // التحقق من حالة الاتصال
    await _checkConnectivity();

    // التحقق من وجود الصورة في التخزين المؤقت
    if (widget.imageUrl.isNotEmpty && _isValidUrl(widget.imageUrl)) {
      _isImageCached = await _cacheManager.isImageCached(widget.imageUrl);
      
      // التحميل المسبق إذا كان مفعلاً
      if (widget.enablePreload && !_isOffline && !_isImageCached) {
        _preloadImage();
      }
    }
  }

  /// التحقق من حالة الاتصال
  Future<void> _checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (mounted) {
        setState(() {
          _isOffline = connectivityResult == ConnectivityResult.none;
        });
      }
    } catch (e) {
      debugPrint('خطأ في التحقق من الاتصال: $e');
      if (mounted) {
        setState(() {
          _isOffline = false; // افتراض وجود اتصال في حالة الخطأ
        });
      }
    }
  }

  /// التحميل المسبق للصورة
  Future<void> _preloadImage() async {
    try {
      await _cacheManager.downloadFile(widget.imageUrl);
      if (mounted) {
        setState(() {
          _isImageCached = true;
        });
      }
      debugPrint('تم تحميل الصورة مسبقاً: ${widget.imageUrl}');
    } catch (e) {
      debugPrint('فشل في التحميل المسبق: $e');
      widget.onError?.call(e);
    }
  }

  /// التحقق من صحة رابط الصورة
  bool _isValidUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    // إذا كانت الصورة فارغة أو غير صحيحة
    if (widget.imageUrl.isEmpty || !_isValidUrl(widget.imageUrl)) {
      return _buildDefaultWidget();
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.grey[100],
        borderRadius: widget.borderRadius,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: widget.borderRadius ?? BorderRadius.zero,
            child: _buildImageWidget(),
          ),
          // مؤشر الوضع غير المتصل
          if (_isOffline && widget.showOfflineIndicator && _isImageCached)
            _buildOfflineIndicator(),
        ],
      ),
    );
  }

  /// بناء widget الصورة
  Widget _buildImageWidget() {
    // إذا كان في الوضع غير المتصل ولا توجد صورة محفوظة
    if (_isOffline && !_isImageCached) {
      return widget.offlineWidget ?? _buildOfflinePlaceholder();
    }

    // استخدام CachedNetworkImage مع تحسينات
    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      memCacheWidth: widget.memCacheWidth,
      memCacheHeight: widget.memCacheHeight,
      cacheKey: widget.cacheKey ?? widget.imageUrl,
      fadeInDuration: widget.fadeInDuration,
      fadeOutDuration: widget.fadeOutDuration,
      cacheManager: _cacheManager,
      placeholder: (context, url) => widget.placeholder ?? _buildDefaultPlaceholder(),
      errorWidget: (context, url, error) {
        debugPrint('خطأ في تحميل الصورة: $url - $error');
        widget.onError?.call(error);
        return widget.errorWidget ?? _buildDefaultErrorWidget();
      },
      imageBuilder: (context, imageProvider) {
        // استدعاء callback عند اكتمال التحميل
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onLoadComplete?.call();
        });
        
        return Image(
          image: imageProvider,
          fit: widget.fit,
          width: widget.width,
          height: widget.height,
        );
      },
    );
  }

  /// بناء placeholder الافتراضي
  Widget _buildDefaultPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'جار التحميل...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء placeholder للوضع غير المتصل
  Widget _buildOfflinePlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off,
              color: Colors.grey[600],
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              'غير متاح في الوضع غير المتصل',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// بناء widget الخطأ الافتراضي
  Widget _buildDefaultErrorWidget() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.broken_image,
              color: Colors.grey[600],
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              'فشل في تحميل الصورة',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء widget افتراضي للصور غير الصحيحة
  Widget _buildDefaultWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: widget.borderRadius,
      ),
      child: Center(
        child: Icon(
          Icons.image_not_supported,
          color: Colors.grey[600],
          size: 40,
        ),
      ),
    );
  }

  /// بناء مؤشر الوضع غير المتصل
  Widget _buildOfflineIndicator() {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off,
              color: Colors.white,
              size: 12,
            ),
            const SizedBox(width: 4),
            Text(
              'غير متصل',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
