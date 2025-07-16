import 'package:ecommerce/pages/auth/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/models/cart_item.dart';
import 'package:ecommerce/models/product.dart';
import 'package:ecommerce/providers/auth_provider.dart';
import 'package:ecommerce/providers/navigation_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:ecommerce/utils/custom_page_route.dart';
import 'package:ecommerce/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'package:ecommerce/services/supabase_service.dart'; // Import SupabaseService

class CartProvider with ChangeNotifier {
  final SupabaseClient _db = SupabaseService.client; // Use Supabase client
  final List<CartItem> _items = [];
  bool _isLoading = false;
  static const String _cartKey = 'cart_items';
  Product? _pendingProduct;
  int? _returnToIndex;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;

  double get total => _items.fold(0, (sum, item) => sum + item.total);

  CartProvider() {
    _loadCart();
  }

  Future<void> _loadCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getStringList(_cartKey);
      if (cartData != null) {
        _items.clear();
        for (var itemJson in cartData) {
          _items.add(CartItem.fromMap(Map<String, dynamic>.from(
              Map.from(const JsonDecoder().convert(itemJson)))));
        }
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addToCart(
      Product product, int quantity, BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final navigationProvider = context.read<NavigationProvider>();

    if (!authProvider.isLoggedIn) {
      _pendingProduct = product;
      _returnToIndex = navigationProvider.currentIndex;

      final localization = AppLocalizations.of(context)!;

      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(localization.loginRequired),
          content: Text(localization.loginToAddCart),
          actions: [
            TextButton(
              onPressed: () {
                _pendingProduct = null;
                _returnToIndex = null;
                Navigator.pop(context, false);
              },
              child: Text(localization.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text(localization.signIn),
            ),
          ],
        ),
      );

      if (result == true && context.mounted) {
        navigationProvider.setPage(3);
        return false;
      }
      _pendingProduct = null;
      _returnToIndex = null;
      return false;
    }

    return await _addProductToCart(product, quantity, context);
  }

  Future<bool> _addProductToCart(
      Product product, int quantity, BuildContext context) async {
    try {
      final existingItemIndex =
          _items.indexWhere((item) => item.productId == product.id);

      if (existingItemIndex != -1) {
        _items[existingItemIndex].quantity += quantity;
      } else {
        _items.add(
          CartItem(
            id: DateTime.now().toString(),
            productId: product.id,
            name: product.name,
            price: product.onSale ? product.salePrice! : product.price,
            imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
            quantity: quantity,
          ),
        );
      }
      notifyListeners();

      await _saveCart();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context)!.itemAddedToCart(product.name)),
            duration: const Duration(seconds: 1),
          ),
        );
      }
      return true;
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      return false;
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    _items.removeWhere((item) => item.id == cartItemId);
    notifyListeners();
    await _saveCart();
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    final itemIndex = _items.indexWhere((item) => item.id == cartItemId);
    if (itemIndex != -1) {
      _items[itemIndex].quantity = quantity;
      notifyListeners();
      await _saveCart();
    }
  }

  Future<void> clearCart() async {
    _items.clear();
    notifyListeners();
    await _saveCart();
  }

  Future<void> loadCartFromSupabase(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final List<Map<String, dynamic>> cartData = await _db
          .from('carts')
          .select()
          .eq('userId', userId);

      if (cartData.isNotEmpty) {
        final itemsData = cartData.first['items'];
        if (itemsData != null && itemsData is List) {
          final items = itemsData
              .map((item) => CartItem.fromMap(item as Map<String, dynamic>))
              .toList();
          _items
            ..clear()
            ..addAll(items);
        }
      }
    } catch (e) {
      debugPrint('Error loading cart from Supabase: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = _items
          .map((item) => const JsonEncoder().convert(item.toMap()))
          .toList();
      await prefs.setStringList(_cartKey, cartData);
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  Future<void> checkout(
    BuildContext context, {
    required String name,
    required String phone,
    required String address,
  }) async {
    final authProvider = context.read<AuthProvider>();
    final localization = AppLocalizations.of(context)!;

    if (!authProvider.isLoggedIn) {
      Navigator.of(context).push(
        CustomPageRoute(child: const AuthPage()),
      );
      return;
    }

    try {
      // First, ensure user exists in users table
      final userEmail = authProvider.user?.email ?? '';
      final userName = authProvider.user?.displayName ?? name;
      
      // Check if user exists, if not create one
      final existingUser = await _db
          .from('users')
          .select('id')
          .eq('email', userEmail)
          .maybeSingle();
      
      String userId;
      if (existingUser != null) {
        userId = existingUser['id'];
      } else {
        // Create new user
        final newUser = await _db
            .from('users')
            .insert({
              'email': userEmail,
              'name': userName,
              'role': 'user',
              'is_active': true,
            })
            .select('id')
            .single();
        userId = newUser['id'];
      }
      
      final order = {
        'user_id': userId,
        'customer_name': name,
        'phone': phone,
        'address': address,
        'total': total,
        'status': 'pending',
        'payment_method': 'cash_on_delivery',
      };
      
      // Insert the order first
      final orderResponse = await _db.from('orders').insert(order).select().single();
      final orderId = orderResponse['id'];
      
      // Insert order items
      final orderItems = _items.map((item) => {
        'order_id': orderId,
        'name': item.name,
        'quantity': item.quantity,
        'price': item.price,
        'image_url': item.imageUrl,
      }).toList();
      
      await _db.from('order_items').insert(orderItems);
      
      await clearCart();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localization.orderConfirmedSuccess),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Error placing order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localization.orderConfirmationFailed),
          backgroundColor: Colors.red,
        ),
      );
      rethrow;
    }
  }

  void onLoginComplete(BuildContext context) {
    if (_pendingProduct != null) {
      _addProductToCart(_pendingProduct!, 1, context);
      _pendingProduct = null;
    }
  }

  int? get returnToIndex => _returnToIndex;
}


