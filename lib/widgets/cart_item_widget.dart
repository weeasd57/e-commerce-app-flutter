import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce/providers/cart_provider.dart';
import 'package:ecommerce/l10n/app_localizations.dart';
import 'package:ecommerce/providers/currency_provider.dart';
import 'package:ecommerce/widgets/offline_cached_image_provider.dart';

class CartItemWidget extends StatelessWidget {
  final int index;
  const CartItemWidget({required this.index, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final item = cartProvider.items[index];
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final localization = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        cartProvider.removeFromCart(item.id);
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: 6,
        ),
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // اسم المنتج
            Text(
              item.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 16 : 18,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 12),
            
            // الصف الرئيسي: الصورة والتحكم والسعر
            Row(
              children: [
                // صورة المنتج
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: isMobile ? 60 : 70,
                    height: isMobile ? 60 : 70,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: OfflineCachedImage(
                      imageUrl: item.imageUrl.isNotEmpty ? item.imageUrl : '',
                      width: isMobile ? 60 : 70,
                      height: isMobile ? 60 : 70,
                      fit: BoxFit.cover,
                      memCacheWidth: 140,
                      memCacheHeight: 140,
                      cacheKey: 'cart_${item.id}_${item.imageUrl.hashCode}',
                      borderRadius: BorderRadius.circular(8),
                      showOfflineIndicator: false,
                      placeholder: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      errorWidget: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.grey[500],
                          size: 24,
                        ),
                      ),
                      offlineWidget: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.grey[500],
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // معلومات المنتج والتحكم
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // الكمية والسعر
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${localization.quantity}: ${item.quantity}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                  fontSize: isMobile ? 12 : 14,
                                ),
                          ),
                          Text(
                            '${item.price} ${currencyProvider.currencyCode}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                  fontSize: isMobile ? 14 : 16,
                                ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // أزرار التحكم
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // التحكم في الكمية
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // زر النقص
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: item.quantity > 1
                                        ? () => cartProvider.updateQuantity(
                                              item.id,
                                              item.quantity - 1,
                                            )
                                        : null,
                                    child: Container(
                                      width: isMobile ? 32 : 36,
                                      height: isMobile ? 32 : 36,
                                      child: Icon(
                                        Icons.remove,
                                        size: isMobile ? 16 : 18,
                                        color: item.quantity > 1
                                            ? Theme.of(context).primaryColor
                                            : Colors.grey[400],
                                      ),
                                    ),
                                  ),
                                ),
                                
                                // عرض الكمية
                                Container(
                                  constraints: BoxConstraints(
                                    minWidth: isMobile ? 32 : 36,
                                  ),
                                  child: Text(
                                    '${item.quantity}',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                  ),
                                ),
                                
                                // زر الزيادة
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () => cartProvider.updateQuantity(
                                      item.id,
                                      item.quantity + 1,
                                    ),
                                    child: Container(
                                      width: isMobile ? 32 : 36,
                                      height: isMobile ? 32 : 36,
                                      child: Icon(
                                        Icons.add,
                                        size: isMobile ? 16 : 18,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // زر الحذف
                          Material(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                cartProvider.removeFromCart(item.id);
                              },
                              child: Container(
                                width: isMobile ? 36 : 40,
                                height: isMobile ? 36 : 40,
                                child: Icon(
                                  Icons.delete_outline,
                                  size: isMobile ? 18 : 20,
                                  color: Colors.red[600],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
