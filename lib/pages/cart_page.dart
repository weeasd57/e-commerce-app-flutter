import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce/providers/cart_provider.dart';
import 'package:ecommerce/utils/responsive_helper.dart';
import 'package:ecommerce/pages/checkout_page.dart';
import 'package:ecommerce/utils/custom_page_route.dart';
import 'package:ecommerce/l10n/app_localizations.dart';
import 'package:ecommerce/providers/currency_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: Responsive.isDesktop(context) ? 1200 : double.infinity,
          ),
          padding: Responsive.scaffoldPadding(context),
          child: Consumer2<CartProvider, CurrencyProvider>(
            builder: (context, cartProvider, currencyProvider, child) {
              if (cartProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (cartProvider.items.isEmpty) {
                return Center(
                  child: Text(localization.yourCartIsEmpty),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartProvider.items.length,
                      itemBuilder: (context, index) {
                        final item = cartProvider.items[index];
                        return Dismissible(
                          key: Key(item.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) {
                            cartProvider.removeFromCart(item.id);
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: item.imageUrl.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: item.imageUrl,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          memCacheWidth: 100, // تحسين الذاكرة
                                          memCacheHeight: 100,
                                          cacheKey: 'cart_${item.id}_${item.imageUrl.hashCode}',
                                          placeholder: (context, url) => Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius: BorderRadius.circular(8.0),
                                            ),
                                            child: Center(
                                              child: SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                      Theme.of(context).primaryColor),
                                                ),
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) {
                                            debugPrint('Error loading cart image: $url - Error: $error');
                                            return Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              child: Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey[600],
                                                size: 20,
                                              ),
                                            );
                                          },
                                        )
                                      : Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          child: Icon(
                                            Icons.shopping_bag,
                                            color: Colors.grey[600],
                                            size: 20,
                                          ),
                                        ),
                                ),
                              ),
                              title: Text(item.name),
                              subtitle: Text(
                                  '${item.price} ${currencyProvider.currencyCode}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: item.quantity > 1
                                        ? () => cartProvider.updateQuantity(
                                            item.id, item.quantity - 1)
                                        : null,
                                  ),
                                  Text('${item.quantity}'),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () =>
                                        cartProvider.updateQuantity(
                                            item.id, item.quantity + 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              localization.total,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${cartProvider.total.toStringAsFixed(2)} ${currencyProvider.currencyCode}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.maxFinite,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                CustomPageRoute(child: const CheckoutPage()),
                              );
                            },
                            child: Text(localization.confirmOrder),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
