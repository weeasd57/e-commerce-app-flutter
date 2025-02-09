import 'package:flutter/material.dart';
import 'package:ecommerce/models/product.dart';
import 'package:ecommerce/providers/cart_provider.dart';
import 'package:ecommerce/providers/wishlist_provider.dart';
import 'package:provider/provider.dart';

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 200;
        return Card(
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
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      child: SizedBox.expand(
                        child: Hero(
                          tag: 'product-${product.id}',
                          child: Image.network(
                            product.imageUrls.first,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
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
                                'SALE',
                                style: TextStyle(
                                  color: colorScheme.onError,
                                  fontSize: isSmall ? 10 : 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          Consumer<WishlistProvider>(
                            builder: (context, wishlistProvider, _) {
                              final isInWishlist = wishlistProvider.wishlistIds
                                  .contains(product.id);
                              return IconButton(
                                constraints: BoxConstraints.tight(
                                    Size(isSmall ? 32 : 40, isSmall ? 32 : 40)),
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  isInWishlist
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isInWishlist
                                      ? colorScheme.error
                                      : colorScheme.outline,
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
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isOnSale) ...[
                                  Text(
                                    '\$${product.price}',
                                    style: TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: colorScheme.outline,
                                      fontSize: isSmall ? 10 : 12,
                                    ),
                                  ),
                                  Text(
                                    '\$${product.salePrice}',
                                    style: TextStyle(
                                      color: colorScheme.error,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isSmall ? 14 : 16,
                                    ),
                                  ),
                                ] else
                                  Text(
                                    '\$${product.price}',
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
                                constraints: BoxConstraints.tight(
                                    Size(isSmall ? 32 : 40, isSmall ? 32 : 40)),
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.shopping_cart_outlined,
                                  size: isSmall ? 18 : 22,
                                  color: colorScheme.primary,
                                ),
                                onPressed: () async {
                                  await cartProvider.addToCart(
                                      product, context);
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
        );
      },
    );
  }
}
