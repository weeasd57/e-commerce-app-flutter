import 'package:ecommerce/pages/auth/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/models/cart_item.dart';
import 'package:ecommerce/models/product.dart';
import 'package:ecommerce/providers/auth_provider.dart';
import 'package:ecommerce/providers/navigation_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:ecommerce/utils/custom_page_route.dart';

class CartProvider with ChangeNotifier {
  final _db = FirebaseFirestore.instance;
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

  Future<bool> addToCart(Product product, BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final navigationProvider = context.read<NavigationProvider>();

    if (!authProvider.isLoggedIn) {
      _pendingProduct = product;
      _returnToIndex = navigationProvider.currentIndex;

      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('تسجيل الدخول مطلوب'),
          content: const Text('يجب تسجيل الدخول لإضافة المنتجات إلى السلة'),
          actions: [
            TextButton(
              onPressed: () {
                _pendingProduct = null;
                _returnToIndex = null;
                Navigator.pop(context, false);
              },
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('تسجيل الدخول'),
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

    return await _addProductToCart(product, context);
  }

  Future<bool> _addProductToCart(Product product, BuildContext context) async {
    try {
      final existingItem = _items.firstWhere(
        (item) => item.productId == product.id,
        orElse: () => CartItem(
          id: DateTime.now().toString(),
          productId: product.id,
          name: product.name,
          price: product.onSale ? product.salePrice! : product.price,
          imageUrl: product.imageUrls.first,
        ),
      );

      if (_items.contains(existingItem)) {
        existingItem.quantity++;
      } else {
        _items.add(existingItem);
      }
      notifyListeners();

      await _saveCart();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت الإضافة إلى السلة'),
            duration: Duration(seconds: 1),
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
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    final item = _items.firstWhere((item) => item.id == cartItemId);
    item.quantity = quantity;
    notifyListeners();
  }

  Future<void> clearCart() async {
    _items.clear();
    notifyListeners();
  }

  Future<void> loadCart(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final doc = await _db.collection('carts').doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final items = (data['items'] as List)
            .map((item) => CartItem.fromMap(item as Map<String, dynamic>))
            .toList();
        _items
          ..clear()
          ..addAll(items);
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
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
    if (!authProvider.isLoggedIn) {
      Navigator.of(context).push(
        CustomPageRoute(child: const AuthPage()),
      );
      return;
    }

    try {
      final order = {
        'userId': authProvider.user!.uid,
        'items': _items.map((item) => item.toMap()).toList(),
        'total': total,
        'status': 'pending',
        'name': name,
        'phone': phone,
        'address': address,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _db.collection('orders').add(order);
      await clearCart();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تأكيد الطلب بنجاح')),
      );
    } catch (e) {
      debugPrint('Error placing order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ. الرجاء المحاولة مرة أخرى')),
      );
      rethrow;
    }
  }

  void onLoginComplete(BuildContext context) {
    if (_pendingProduct != null) {
      _addProductToCart(_pendingProduct!, context);
      _pendingProduct = null;
    }
  }

  int? get returnToIndex => _returnToIndex;
}
