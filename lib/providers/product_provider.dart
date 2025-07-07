import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/models/product.dart';

enum SortOption {
  newest,
  priceHighToLow,
  priceLowToHigh,
}

class ProductProvider with ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  List<Product> _products = [];
  List<Product> _newProducts = [];
  List<Product> _saleProducts = [];
  List<Product> _hotProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;

  // Filter states
  bool _showOnSale = false;
  bool _showHotItems = false;
  bool _showNewArrivals = false;
  SortOption _sortOption = SortOption.newest;

  List<Product> get products =>
      _filteredProducts.isEmpty ? _products : _filteredProducts;
  List<Product> get newProducts => _newProducts;
  List<Product> get saleProducts => _saleProducts;
  List<Product> get hotProducts => _hotProducts;
  bool get isLoading => _isLoading;

  bool get showOnSale => _showOnSale;
  bool get showHotItems => _showHotItems;
  bool get showNewArrivals => _showNewArrivals;
  SortOption get sortOption => _sortOption;

  void setShowOnSale(bool value) {
    _showOnSale = value;
    _applyFilters();
  }

  void setShowHotItems(bool value) {
    _showHotItems = value;
    _applyFilters();
  }

  void setShowNewArrivals(bool value) {
    _showNewArrivals = value;
    _applyFilters();
  }

  void setSortOption(SortOption option) {
    _sortOption = option;
    _applyFilters();
  }

  void clearFilters() {
    _showOnSale = false;
    _showHotItems = false;
    _showNewArrivals = false;
    _sortOption = SortOption.newest;
    _filteredProducts = [];
    notifyListeners();
  }

  void _applyFilters() {
    _filteredProducts = List.from(_products);

    // Apply category filters
    if (_showOnSale) {
      _filteredProducts =
          _filteredProducts.where((product) => product.onSale).toList();
    }

    if (_showHotItems) {
      _filteredProducts =
          _filteredProducts.where((product) => product.isHot).toList();
    }

    if (_showNewArrivals) {
      _filteredProducts =
          _filteredProducts.where((product) => product.isNew).toList();
    }

    // Apply sorting
    switch (_sortOption) {
      case SortOption.newest:
        _filteredProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.priceHighToLow:
        _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.priceLowToHigh:
        _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
    }

    notifyListeners();
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final productsSnapshot = await _db.collection('products').get();
      _products = productsSnapshot.docs.map((doc) {
        final data = doc.data();
        DateTime createdAt;
        String? age;

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

        // Extract age if available
        age = data['age'] as String?;

        return Product.fromMap({
          'id': doc.id,
          ...data,
          'createdAt': createdAt.toIso8601String(),
          'age': age,
        });
      }).toList();

      // Filter new products
      _newProducts = _products.where((product) => product.isNew).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Filter sale products
      _saleProducts = _products.where((product) => product.onSale).toList();

      // Filter hot products
      _hotProducts = _products.where((product) => product.isHot).toList();

      // Apply any active filters
      if (_showOnSale ||
          _showHotItems ||
          _showNewArrivals ||
          _sortOption != SortOption.newest) {
        _applyFilters();
      }

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
        String? age;

        // Extract age if available
        age = data['age'] as String?;

        return Product.fromMap({
          'id': doc.id,
          ...data,
          'createdAt':
              (data['createdAt'] as Timestamp).toDate().toIso8601String(),
          'age': age,
        });
      }).toList();
    } catch (e) {
      debugPrint('Error fetching products by category: $e');
      return [];
    }
  }
}
