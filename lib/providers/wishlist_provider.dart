import 'package:flutter/material.dart';
import 'package:ecommerce/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce/l10n/app_localizations.dart';

class WishlistProvider with ChangeNotifier {
  final List<String> _wishlistIds = [];
  bool _isLoading = false;
  static const String _wishlistKey = 'wishlist_items';

  bool get isLoading => _isLoading;
  List<String> get wishlistIds => _wishlistIds;

  WishlistProvider() {
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlist = prefs.getStringList(_wishlistKey);
      if (wishlist != null) {
        _wishlistIds.clear();
        _wishlistIds.addAll(wishlist);
      }
    } catch (e) {
      debugPrint('Error loading wishlist: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleWishlist(Product product, BuildContext context) async {
    final isInWishlist = _wishlistIds.contains(product.id);

    try {
      if (isInWishlist) {
        _wishlistIds.remove(product.id);
      } else {
        _wishlistIds.add(product.id);
      }
      notifyListeners();

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_wishlistKey, _wishlistIds);

      // Show feedback
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isInWishlist
                  ? AppLocalizations.of(context)!.removedFromWishlist
                  : AppLocalizations.of(context)!.addedToWishlist,
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating wishlist: $e');
      // Revert local change if save fails
      if (isInWishlist) {
        _wishlistIds.add(product.id);
      } else {
        _wishlistIds.remove(product.id);
      }
      notifyListeners();
    }
  }

  Future<void> clearWishlist() async {
    try {
      _wishlistIds.clear();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_wishlistKey);
    } catch (e) {
      debugPrint('Error clearing wishlist: $e');
    }
  }

  void addToWishlist(String productId) {
    _wishlistIds.add(productId);
    notifyListeners();
  }

  void removeFromWishlist(String productId) {
    _wishlistIds.remove(productId);
    notifyListeners();
  }
}
