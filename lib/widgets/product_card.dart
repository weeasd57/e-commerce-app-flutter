import 'package:flutter/material.dart';
import 'package:ecommerce/models/product.dart';
import 'package:ecommerce/providers/cart_provider.dart';
import 'package:ecommerce/providers/wishlist_provider.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce/providers/currency_provider.dart';
import 'package:ecommerce/pages/product_details_page.dart';
import 'package:ecommerce/utils/custom_page_route.dart';
import 'package:ecommerce/widgets/offline_cached_image_provider.dart';
import 'package:ecommerce/utils/responsive_helper.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool isOnSale;

  const ProductCard({
    super.key,
    required this.product,
    this.isOnSale = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyProvider = context.watch<CurrencyProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                CustomPageRoute(
                  child: ProductDetailsPage(product: product),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image section with modern styling - استخدام نسبة أفضل
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            color: colorScheme.surfaceContainerHighest,
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            child: Hero(
                              tag: 'productImage_${product.id}',
                              child: OfflineCachedImage(
                                imageUrl: product.imageUrls.isNotEmpty
                                    ? product.imageUrls.first
                                    : '',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                memCacheWidth: 300,
                                memCacheHeight: 300,
                                cacheKey:
                                    'product_${product.id}_${product.imageUrls.isNotEmpty ? product.imageUrls.first.hashCode : 0}',
                                fadeInDuration:
                                    const Duration(milliseconds: 300),
                                fadeOutDuration:
                                    const Duration(milliseconds: 200),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                                showOfflineIndicator: true,
                                placeholder: Container(
                                  color: colorScheme.surfaceContainerHighest,
                                  child: Center(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Icon(
                                        Icons.image_outlined,
                                        size: Responsive.isMobile(context) ? 32 : 40,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: Container(
                                  color: colorScheme.surfaceContainerHighest,
                                  child: Center(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Icon(
                                        Icons.broken_image_outlined,
                                        size: Responsive.isMobile(context) ? 32 : 40,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Top badges and wishlist
                        Positioned(
                          top: 12,
                          left: 12,
                          right: 12,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Sale badge
                              if (product.hasDiscount)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${product.discountPercentage.toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              else
                                const SizedBox(),

                              // Wishlist button
                              Consumer<WishlistProvider>(
                                builder: (context, wishlistProvider, _) {
                                  final isInWishlist = wishlistProvider
                                      .wishlistIds
                                      .contains(product.id);
                                  return Container(
                                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      constraints: BoxConstraints(
                                        minWidth: Responsive.isMobile(context) ? 32 : 36,
                                        minHeight: Responsive.isMobile(context) ? 32 : 36,
                                      ),
                                      padding: EdgeInsets.zero,
                                      icon: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Icon(
                                          isInWishlist
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: isInWishlist
                                              ? Colors.red
                                              : Colors.grey[600],
                                          size: Responsive.isMobile(context) ? 18 : 20,
                                        ),
                                      ),
                                      onPressed: () => wishlistProvider
                                          .toggleWishlist(product, context),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Product details section - إصلاح الـ overflow
                  Container(
                    height: constraints.maxHeight * 0.4, // تحديد ارتفاع ثابت لتجنب الـ overflow
                    padding: EdgeInsets.all(
                      Responsive.isMobile(context) ? 6 : 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Product name - تحسين عرض الاسم
                        Expanded(
                          flex: 3,
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.topRight, // محاذاة للنص العربي
                            child: Text(
                              product.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 1.1,
                                fontSize: constraints.maxWidth < 140 
                                    ? 9 
                                    : (constraints.maxWidth < 180 ? 10 : 11),
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right, // محاذاة يمين للنص العربي
                            ),
                          ),
                        ),

                        // Product age/category
                        if (product.age != null)
                          Expanded(
                            flex: 1,
                            child: Container(
                              width: double.infinity,
                              alignment: Alignment.topRight,
                              child: Text(
                                product.age!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                  fontSize: constraints.maxWidth < 140 
                                      ? 7 
                                      : (constraints.maxWidth < 180 ? 8 : 9),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),

                        // Price and cart section - تحسين للمساحة المحدودة
                        Expanded(
                          flex: 2,
                          child: Container(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Add to cart button - في اليسار للتطبيق العربي مع تكبير أكثر
                                Consumer<CartProvider>(
                                  builder: (context, cartProvider, _) {
                                    // تكبير حجم الزر أكثر ليكون واضح جداً
                                    double buttonSize = constraints.maxWidth < 140 
                                        ? 32 
                                        : (constraints.maxWidth < 180 ? 36 : 40);
                                    
                                    return Container(
                                      width: buttonSize,
                                      height: buttonSize,
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: colorScheme.primary.withValues(alpha: 0.4),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(8),
                                          onTap: () async {
                                            await cartProvider.addToCart(
                                                product, 1, context);
                                          },
                                          child: Center(
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Padding(
                                                padding: const EdgeInsets.all(2.0),
                                                child: Icon(
                                                  Icons.add_shopping_cart_outlined,
                                                  color: Colors.white,
                                                  size: buttonSize * 0.55,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(width: 4),

                                // Price section - في اليمين للتطبيق العربي مع تكبير السعر
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end, // محاذاة يمين
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (product.hasDiscount) ...[
                                        // Original price (crossed out) - تكبير الخط
                                        Text(
                                          '${product.price.toStringAsFixed(0)} ${currencyProvider.currencyCode}',
                                          style: TextStyle(
                                            decoration: TextDecoration.lineThrough,
                                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                                            fontSize: constraints.maxWidth < 140 
                                                ? 9 
                                                : (constraints.maxWidth < 180 ? 10 : 11),
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.right,
                                        ),
                                        const SizedBox(height: 2),
                                      ],
                                      // Final price - تكبير السعر النهائي أكثر
                                      Text(
                                        '${product.finalPrice.toStringAsFixed(0)} ${currencyProvider.currencyCode}',
                                        style: TextStyle(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.w800,
                                          fontSize: constraints.maxWidth < 140 
                                              ? 11 
                                              : (constraints.maxWidth < 180 ? 13 : 15),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.right,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
