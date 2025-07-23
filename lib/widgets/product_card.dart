import 'package:flutter/material.dart';
import 'package:ecommerce/models/product.dart';
import 'package:ecommerce/providers/cart_provider.dart';
import 'package:ecommerce/providers/wishlist_provider.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce/providers/currency_provider.dart';
import 'package:ecommerce/l10n/app_localizations.dart';
import 'package:ecommerce/pages/product_details_page.dart';
import 'package:ecommerce/utils/custom_page_route.dart';
import 'package:ecommerce/widgets/offline_cached_image_provider.dart';

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
    final localization = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 200;
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              CustomPageRoute(
                child: ProductDetailsPage(product: product),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image section with fixed height
                SizedBox(
                  height: constraints.maxHeight * 0.6, // 60% of card height
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12)),
                        child: SizedBox.expand(
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
                              cacheKey: 'product_${product.id}_${product.imageUrls.isNotEmpty ? product.imageUrls.first.hashCode : 0}',
                              fadeInDuration: const Duration(milliseconds: 200),
                              fadeOutDuration: const Duration(milliseconds: 200),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12)
                              ),
                              showOfflineIndicator: true,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isOnSale)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmall ? 4 : 8,
                                  vertical: isSmall ? 2 : 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.error,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  localization.onSale.toUpperCase(),
                                  style: TextStyle(
                                    color: colorScheme.onError,
                                    fontSize: isSmall ? 10 : 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            Consumer<WishlistProvider>(
                              builder: (context, wishlistProvider, _) {
                                final isInWishlist = wishlistProvider
                                    .wishlistIds
                                    .contains(product.id);
                                return IconButton(
                                  constraints: BoxConstraints.tight(Size(
                                      isSmall ? 32 : 40, isSmall ? 32 : 40)),
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    isInWishlist
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isInWishlist
                                        ? colorScheme.error
                                        : Colors.black54,
                                    size: isSmall ? 20 : 24,
                                  ),
                                  onPressed: () => wishlistProvider
                                      .toggleWishlist(product, context),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Product details section
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(isSmall ? 6.0 : 8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: isSmall ? 12 : 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (product.age != null)
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                  scale: animation, child: child);
                            },
                            child: Text(
                              product.age!,
                              key: ValueKey<String>(product.age!),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.7),
                                fontSize: isSmall ? 9 : 11,
                              ),
                            ),
                          ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (product.hasDiscount) ...[
                                    // السعر الأصلي مشطوب
                                    Text(
                                      '${product.price.toStringAsFixed(0)} ${currencyProvider.currencyCode}',
                                      style: TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: colorScheme.outline,
                                        fontSize: isSmall ? 10 : 12,
                                      ),
                                    ),
                                    // السعر النهائي بعد التخفيض
                                    Text(
                                      '${product.finalPrice.toStringAsFixed(0)} ${currencyProvider.currencyCode}',
                                      style: TextStyle(
                                        color: colorScheme.error,
                                        fontWeight: FontWeight.bold,
                                        fontSize: isSmall ? 14 : 16,
                                      ),
                                    ),
                                    // نسبة التخفيض (اختياري)
                                    if (product.discountPercentage > 0)
                                      Text(
                                        '${product.discountPercentage.toStringAsFixed(0)}% OFF',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: isSmall ? 8 : 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ] else
                                    // السعر العادي بدون تخفيض
                                    Text(
                                      '${product.finalPrice.toStringAsFixed(0)} ${currencyProvider.currencyCode}',
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: isSmall ? 14 : 16,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Consumer<CartProvider>(
                              builder: (context, cartProvider, _) {
                                return IconButton(
                                  constraints: BoxConstraints.tight(Size(
                                      isSmall ? 32 : 40, isSmall ? 32 : 40)),
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    Icons.shopping_cart_outlined,
                                    size: isSmall ? 18 : 22,
                                    color: colorScheme.primary,
                                  ),
                                  onPressed: () async {
                                    await cartProvider.addToCart(
                                        product, 1, context);
                                    // Don't show snackbar here as it's handled in the provider
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
