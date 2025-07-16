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

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _quantity = 1;

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
            // Product Image
            Hero(
              tag:
                  'productImage_${widget.product.id}', // Unique tag for Hero animation
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: widget.product.imageUrls.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: widget.product.imageUrls.first,
                          height: Responsive.isDesktop(context) ? 400 : 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: Responsive.isDesktop(context) ? 400 : 250,
                            width: double.infinity,
                            color: Colors.grey[300],
                            child: Icon(Icons.image_not_supported,
                                color: Colors.grey[600]),
                          ),
                        )
                      : Container(
                          height: Responsive.isDesktop(context) ? 400 : 250,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: Icon(Icons.image_not_supported,
                              color: Colors.grey[600]),
                        ),
                ),
              ),
            ),
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
            Row(
              children: [
                Text(
                  '${widget.product.price} ',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: primaryColor, // Use the selected primary color
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  currencyProvider.currencyCode,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: primaryColor, // Use the selected primary color
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
                onPressed: () {
                  cartProvider.addToCart(widget.product, _quantity, context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          localization.itemAddedToCart(widget.product.name)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
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
}
