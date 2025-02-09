import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/models/product.dart';

class ProductProvider with ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  List<Product> _products = [];
  List<Product> _newProducts = [];
  List<Product> _saleProducts = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  List<Product> get newProducts => _newProducts;
  List<Product> get saleProducts => _saleProducts;
  bool get isLoading => _isLoading;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final productsSnapshot = await _db.collection('products').get();
      _products = productsSnapshot.docs.map((doc) {
        final data = doc.data();
        DateTime createdAt;

        try {
          final createdAtData = data['createdAt'];
          if (createdAtData is Timestamp) {
            createdAt = createdAtData.toDate();
          } else {
            createdAt = DateTime.now();
          }
        } catch (e) {
          createdAt = DateTime.now();
        }

        return Product.fromMap({
          'id': doc.id,
          ...data,
          'createdAt': createdAt.toIso8601String(),
        });
      }).toList();

      // Filter new products
      _newProducts = _products.where((product) => product.isNew).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Filter sale products
      _saleProducts = _products.where((product) => product.onSale).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Product>> fetchProductsByCategory(String categoryId) async {
    try {
      final snapshot = await _db
          .collection('products')
          .where('categoryId', isEqualTo: categoryId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Product.fromMap({
          'id': doc.id,
          ...data,
          'createdAt':
              (data['createdAt'] as Timestamp).toDate().toIso8601String(),
        });
      }).toList();
    } catch (e) {
      debugPrint('Error fetching products by category: $e');
      return [];
    }
  }
}
