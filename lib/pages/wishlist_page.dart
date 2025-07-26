import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce/providers/wishlist_provider.dart';
import 'package:ecommerce/providers/enhanced_product_provider.dart';
import 'package:ecommerce/widgets/product_card.dart';
import 'package:ecommerce/l10n/app_localizations.dart';
import 'package:ecommerce/utils/responsive_helper.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.wishlistTitle),
        centerTitle: true,
      ),
      body: Consumer2<WishlistProvider, EnhancedProductProvider>(
        builder: (context, wishlistProvider, productProvider, _) {
          if (wishlistProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final wishlistProducts = productProvider.products
              .where((product) =>
                  wishlistProvider.wishlistIds.contains(product.id))
              .toList();

          if (wishlistProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noWishlistItems,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              // حساب عدد الأعمدة والنسبة بناءً على حجم الشاشة
              final crossAxisCount = Responsive.gridCrossAxisCount(context);
              final screenWidth = constraints.maxWidth;
              final availableWidth = screenWidth - (16 * 2); // padding
              final spacing = Responsive.isDesktop(context) ? 20.0 : 16.0;
              final itemWidth = (availableWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
              
              // حساب النسبة المثلى لعرض اسم المنتج بوضوح
              double childAspectRatio;
              if (Responsive.isDesktop(context)) {
                childAspectRatio = 0.75; // نسبة أفضل للسطح المكتبي
              } else if (Responsive.isTablet(context)) {
                childAspectRatio = 0.8; // نسبة متوازنة للتابلت
              } else {
                childAspectRatio = 0.85; // نسبة أفضل للموبايل لإظهار النص
              }

              return GridView.builder(
                padding: Responsive.scaffoldPadding(context),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                ),
                itemCount: wishlistProducts.length,
                itemBuilder: (context, index) {
                  final product = wishlistProducts[index];
                  return ProductCard(
                    product: product,
                    isOnSale: product.salePrice != null,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
