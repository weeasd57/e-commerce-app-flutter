import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/image_cache_manager.dart';

/// Widget للصور المحفوظة مؤقتاً مع دعم الوضع غير المتصل
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
  });

  @override
  State<OfflineCachedImage> createState() => _OfflineCachedImageState();
}

class _OfflineCachedImageState extends State<OfflineCachedImage> {
  final CustomImageCacheManager _cacheManager = CustomImageCacheManager();

  @override
  Widget build(BuildContext context) {
    // إذا كانت الصورة فارغة أو غير صحيحة
    if (widget.imageUrl.isEmpty || 
        (!widget.imageUrl.startsWith('http') && !widget.imageUrl.startsWith('https'))) {
      return _buildDefaultWidget();
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.grey[100],
        borderRadius: widget.borderRadius,
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.zero,
        child: _buildImageWidget(),
      ),
    );
  }

  /// بناء widget الصورة
  Widget _buildImageWidget() {
    // استخدام CachedNetworkImage مع مدير التخزين المؤقت المخصص
    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      memCacheWidth: widget.memCacheWidth,
      memCacheHeight: widget.memCacheHeight,
      cacheKey: widget.cacheKey,
      fadeInDuration: widget.fadeInDuration,
      fadeOutDuration: widget.fadeOutDuration,
      cacheManager: _cacheManager,
      placeholder: (context, url) => widget.placeholder ?? _buildDefaultPlaceholder(),
      errorWidget: (context, url, error) {
        debugPrint('خطأ في تحميل الصورة: $url - $error');
        return widget.errorWidget ?? _buildDefaultErrorWidget();
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

  /// بناء widget خطأ للوضع غير المتصل
  Widget _buildOfflineErrorWidget() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_not_supported,
              color: Colors.grey[600],
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              'الصورة غير متاحة',
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
          color: Colors.black.withValues(alpha: 0.7),
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
