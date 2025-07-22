import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce/l10n/app_localizations.dart';
import 'package:ecommerce/models/product.dart';
import 'package:ecommerce/providers/cart_provider.dart';
import 'package:ecommerce/providers/currency_provider.dart';
import 'package:ecommerce/providers/wishlist_provider.dart';
import 'package:ecommerce/utils/responsive_helper.dart';
import 'package:ecommerce/providers/color_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce/widgets/offline_cached_image.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _quantity = 1;
  int _selectedImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final colorProvider = Provider.of<ColorProvider>(context);
    final wishlistProvider = Provider.of<WishlistProvider>(context);

    final selectedColor = colorProvider.selectedColorOption;
    final primaryColor =
        selectedColor?.solidColor ?? Theme.of(context).primaryColor;
    final gradientColors = selectedColor?.gradientColors;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        backgroundColor: gradientColors != null
            ? Colors.transparent
            : primaryColor, // Apply solid color or transparent for gradient
        flexibleSpace: gradientColors != null
            ? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              )
            : null,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8.0),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: Icon(
                wishlistProvider.wishlistIds.contains(widget.product.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: wishlistProvider.wishlistIds.contains(widget.product.id)
                    ? Colors.red
                    : Colors.white,
                size: 24,
              ),
              onPressed: () {
                wishlistProvider.toggleWishlist(widget.product, context);
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: Responsive.scaffoldPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Images Section
            _buildProductImagesSection(),
            const SizedBox(height: 20),

            // Product Name
            Text(
              widget.product.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),

            // Product Price
            _buildPriceSection(context, primaryColor, currencyProvider, localization),
            const SizedBox(height: 15),

            // Product Description
            Text(
              widget.product.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),

            // Age (if available)
            if (widget.product.age != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localization.age, // Localized string for Age
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.product.age!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                ],
              ),

            // Quantity Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localization.quantity,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        setState(() {
                          if (_quantity > 1) _quantity--;
                        });
                      },
                    ),
                    Text(
                      '$_quantity',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        setState(() {
                          _quantity++;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Add to Cart Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
              onPressed: () async {
                  // إزالة الـ SnackBar المكررة - CartProvider يعرض الرسالة بالفعل
                  await cartProvider.addToCart(widget.product, _quantity, context);
                },
                icon: const Icon(Icons.shopping_cart),
                label: Text(localization.addToCart),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor:
                      primaryColor, // Use the selected primary color
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Add to Wishlist Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  wishlistProvider.toggleWishlist(widget.product, context);
                },
                icon: Icon(
                  wishlistProvider.wishlistIds.contains(widget.product.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                ),
                label: Text(
                  wishlistProvider.wishlistIds.contains(widget.product.id)
                      ? 'إزالة من المفضلة'
                      : 'إضافة إلى المفضلة',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بناء قسم الصور
  Widget _buildProductImagesSection() {
    final hasMultipleImages = widget.product.imageUrls.length > 1;
    
    return Column(
      children: [
        // الصورة الرئيسية
        _buildMainImage(),
        
        // مؤشر الصور والصور المصغرة
        if (hasMultipleImages) ...[
          const SizedBox(height: 10),
          _buildImageIndicators(),
          const SizedBox(height: 15),
          _buildImageThumbnails(),
        ],
      ],
    );
  }

  // بناء الصورة الرئيسية
  Widget _buildMainImage() {
    return Hero(
      tag: 'productImage_${widget.product.id}',
      child: Container(
        height: Responsive.isDesktop(context) ? 400 : 280,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: widget.product.imageUrls.isNotEmpty
              ? widget.product.imageUrls.length == 1
                  ? _buildSingleImage(widget.product.imageUrls.first)
                  : _buildImagePageView()
              : _buildPlaceholderImage(),
        ),
      ),
    );
  }

  // بناء صورة واحدة
  Widget _buildSingleImage(String imageUrl) {
    return OfflineCachedImage(
      imageUrl: imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      memCacheWidth: 600,
      memCacheHeight: 600,
      cacheKey: 'product_detail_${widget.product.id}_${imageUrl.hashCode}',
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
      borderRadius: BorderRadius.circular(12.0),
      showOfflineIndicator: true,
      errorWidget: _buildPlaceholderImage(),
    );
  }

  // بناء عرض الصور المتعددة
  Widget _buildImagePageView() {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.product.imageUrls.length,
      onPageChanged: (index) {
        setState(() {
          _selectedImageIndex = index;
        });
      },
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _showImageViewer(index),
          child: OfflineCachedImage(
            imageUrl: widget.product.imageUrls[index],
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            memCacheWidth: 600,
            memCacheHeight: 600,
            cacheKey: 'product_pageview_${widget.product.id}_${widget.product.imageUrls[index].hashCode}',
            fadeInDuration: const Duration(milliseconds: 300),
            fadeOutDuration: const Duration(milliseconds: 300),
            borderRadius: BorderRadius.circular(12.0),
            showOfflineIndicator: true,
            errorWidget: _buildPlaceholderImage(),
          ),
        );
      },
    );
  }

  // بناء الصورة الافتراضية
  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      color: Colors.grey[300],
      child: Icon(
        Icons.image_not_supported,
        color: Colors.grey[600],
        size: 50,
      ),
    );
  }

  // بناء مؤشرات الصور
  Widget _buildImageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.product.imageUrls.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _selectedImageIndex == index ? 12 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _selectedImageIndex == index
                ? Theme.of(context).primaryColor
                : Colors.grey[400],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  // بناء الصور المصغرة
  Widget _buildImageThumbnails() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.product.imageUrls.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedImageIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedImageIndex = index;
              });
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300]!,
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: OfflineCachedImage(
                  imageUrl: widget.product.imageUrls[index],
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  memCacheWidth: 150,
                  memCacheHeight: 150,
                  cacheKey: 'product_thumb_${widget.product.id}_${widget.product.imageUrls[index].hashCode}',
                  fadeInDuration: const Duration(milliseconds: 200),
                  fadeOutDuration: const Duration(milliseconds: 200),
                  borderRadius: BorderRadius.circular(6),
                  showOfflineIndicator: false,
                  placeholder: Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.image,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                  ),
                  errorWidget: Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // عرض الصور في ملء الشاشة
  void _showImageViewer(int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _ImageViewerPage(
          imageUrls: widget.product.imageUrls,
          initialIndex: initialIndex,
          productName: widget.product.name,
        ),
      ),
    );
  }

  // بناء قسم السعر مع عرض الخصم
  Widget _buildPriceSection(BuildContext context, Color primaryColor, 
      dynamic currencyProvider, dynamic localization) {
    final hasDiscount = widget.product.hasDiscount;
    final finalPrice = widget.product.finalPrice;
    final originalPrice = widget.product.price;
    final discountPercentage = widget.product.actualDiscountPercentage;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // السعر الحالي (النهائي)
        Row(
          children: [
            Text(
              '${finalPrice.toStringAsFixed(0)} ',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              currencyProvider.currencyCode,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.product.onSale)
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  localization.sale,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        
        // السعر الأصلي ونسبة الخصم (إذا كان هناك خصم)
        if (hasDiscount)...[
          const SizedBox(height: 5),
          Row(
            children: [
              // السعر الأصلي مشطوب
              Text(
                '${originalPrice.toStringAsFixed(0)} ${currencyProvider.currencyCode}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 10),
              // نسبة الخصم
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  localization.discountPercentage(discountPercentage.toStringAsFixed(0)),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          // مقدار التوفير
          Text(
            localization.savings(
              (originalPrice - finalPrice).toStringAsFixed(0),
              currencyProvider.currencyCode,
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.green[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

// صفحة عرض الصور في ملء الشاشة
class _ImageViewerPage extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String productName;

  const _ImageViewerPage({
    required this.imageUrls,
    required this.initialIndex,
    required this.productName,
  });

  @override
  State<_ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<_ImageViewerPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          '${_currentIndex + 1} / ${widget.imageUrls.length}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 3.0,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: widget.imageUrls[index],
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(
                    Icons.error,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: widget.imageUrls.length > 1
          ? Container(
              color: Colors.black,
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.imageUrls.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? Colors.white
                          : Colors.grey[600],
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
