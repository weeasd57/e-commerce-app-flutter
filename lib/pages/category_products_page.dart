import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce/models/category.dart';
import 'package:ecommerce/providers/product_provider.dart';
import 'package:ecommerce/widgets/product_card.dart';
import 'package:ecommerce/utils/responsive_helper.dart';
import 'package:ecommerce/l10n/app_localizations.dart';

class CategoryProductsPage extends StatelessWidget {
  final Category category;

  const CategoryProductsPage({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: Responsive.isDesktop(context) ? 1200 : double.infinity,
          ),
          padding: Responsive.scaffoldPadding(context),
          child: Consumer<ProductProvider>(
            builder: (context, productProvider, _) {
              final categoryProducts = productProvider.products
                  .where((p) => p.categoryId == category.id)
                  .toList();

              if (categoryProducts.isEmpty) {
                return Center(
                  child: Text(localization.noProductsInCategory),
                );
              }

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: Responsive.gridCrossAxisCount(context),
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: categoryProducts.length,
                itemBuilder: (context, index) {
                  final product = categoryProducts[index];
                  return ProductCard(
                    product: product,
                    isOnSale: product.onSale,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
