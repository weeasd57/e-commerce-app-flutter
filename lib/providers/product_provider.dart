import 'package:flutter/material.dart';
// Import Supabase
import 'package:ecommerce/models/product.dart';
import 'package:ecommerce/services/supabase_service.dart'; // Import SupabaseService

enum SortOption {
  newest,
  priceHighToLow,
  priceLowToHigh,
}

class ProductProvider with ChangeNotifier {
  final _db = SupabaseService.client; // Use Supabase client
  List<Product> _products = [];
  List<Product> _newProducts = [];
  List<Product> _saleProducts = [];
  List<Product> _hotProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  bool _hasError = false;

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
  bool get hasError => _hasError;

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
    _hasError = false;
    notifyListeners();

    try {
      // Fetch products from Supabase
      final List<Map<String, dynamic>> productsData = await _db
          .from('products')
          .select()
          .order('created_at', ascending: false); // Order by created_at

      debugPrint('Fetched ${productsData.length} products from Supabase');
      
      if (productsData.isEmpty) {
        debugPrint('No products found in database, creating sample data...');
        await _createSampleProducts();
        
        // Try fetching again after creating sample data
        final retryData = await _db
            .from('products')
            .select()
            .order('created_at', ascending: false);
        
        if (retryData.isNotEmpty) {
          debugPrint('Sample products created successfully, processing...');
        _processFetchedProducts(retryData);
        } else {
          debugPrint('Failed to create sample products');
          _products = [];
          _newProducts = [];
          _saleProducts = [];
          _hotProducts = [];
          _filteredProducts = [];
        }
        notifyListeners();
        return;
      }
      
      _processFetchedProducts(productsData);

    } catch (e) {
      debugPrint('Error fetching products: $e');
      _products = [];
      _newProducts = [];
      _saleProducts = [];
      _hotProducts = [];
      _filteredProducts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void _processFetchedProducts(List<Map<String, dynamic>> productsData) {
    try {
      _products = productsData.map((data) {
        DateTime createdAt;
        String? age;

        try {
          final createdAtData = data['created_at'];
          if (createdAtData is String) {
            createdAt = DateTime.parse(createdAtData);
          } else {
            createdAt = DateTime.now(); // Fallback
          }
        } catch (e) {
          createdAt = DateTime.now(); // Fallback
        }

        age = data['age'] as String?;

        return Product.fromMap({
          'id': data['id']?.toString() ?? '',
          ...data,
          'createdAt': createdAt.toIso8601String(),
          'age': age,
        });
      }).toList();

      // Filter new products with null check
      _newProducts = _products.where((product) {
        try {
          return product.isNew;
        } catch (e) {
          debugPrint('Error checking isNew for product: $e');
          return false;
        }
      }).toList();
      
      if (_newProducts.isNotEmpty) {
        _newProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }

      // Filter sale products with null check
      _saleProducts = _products.where((product) {
        try {
          return product.onSale;
        } catch (e) {
          debugPrint('Error checking onSale for product: $e');
          return false;
        }
      }).toList();

      // Filter hot products with null check
      _hotProducts = _products.where((product) {
        try {
          return product.isHot;
        } catch (e) {
          debugPrint('Error checking isHot for product: $e');
          return false;
        }
      }).toList();

      // Apply any active filters
      if (_showOnSale ||
          _showHotItems ||
          _showNewArrivals ||
          _sortOption != SortOption.newest) {
        _applyFilters();
      }

      debugPrint('Successfully loaded ${_products.length} products');
      debugPrint('Sale products: ${_saleProducts.length}');
      debugPrint('Hot products: ${_hotProducts.length}');
      debugPrint('New products: ${_newProducts.length}');
    } catch (e) {
      debugPrint('Error processing products: $e');
      _products = [];
      _newProducts = [];
      _saleProducts = [];
      _hotProducts = [];
    }
  }
  
  Future<void> _createSampleProducts() async {
    try {
      final sampleProducts = [
        {
          'name': 'iPhone 14 Pro',
          'description': 'Latest iPhone with advanced camera system',
          'price': 999.99,
          'sale_price': 899.99,
          'image_urls': ['https://picsum.photos/400/300?random=1'],
          'is_hot': true,
          'is_new': true,
          'on_sale': true,
          'category_id': null,
          'age': '2024'
        },
        {
          'name': 'Samsung Galaxy S23',
          'description': 'Powerful Android smartphone',
          'price': 799.99,
          'sale_price': null,
          'image_urls': ['https://picsum.photos/400/300?random=2'],
          'is_hot': false,
          'is_new': true,
          'on_sale': false,
          'category_id': null,
          'age': '2024'
        },
        {
          'name': 'MacBook Pro 14',
          'description': 'High-performance laptop for professionals',
          'price': 1999.99,
          'sale_price': 1799.99,
          'image_urls': ['https://picsum.photos/400/300?random=3'],
          'is_hot': true,
          'is_new': false,
          'on_sale': true,
          'category_id': null,
          'age': '2024'
        },
        {
          'name': 'iPad Air',
          'description': 'Versatile tablet for work and play',
          'price': 599.99,
          'sale_price': null,
          'image_urls': ['https://picsum.photos/400/300?random=4'],
          'is_hot': false,
          'is_new': false,
          'on_sale': false,
          'category_id': null,
          'age': '2024'
        },
        {
          'name': 'Apple Watch Series 9',
          'description': 'Advanced smartwatch with health features',
          'price': 399.99,
          'sale_price': 349.99,
          'image_urls': ['https://picsum.photos/400/300?random=5'],
          'is_hot': true,
          'is_new': true,
          'on_sale': true,
          'category_id': null,
          'age': '2024'
        },
      ];
      
      await _db.from('products').insert(sampleProducts);
      debugPrint('Sample products inserted successfully');
    } catch (e) {
      debugPrint('Error creating sample products: $e');
    }
  }

  Future<List<Product>> fetchProductsByCategory(String categoryId) async {
    try {
      final List<Map<String, dynamic>> productsData = await _db
          .from('products')
          .select()
          .eq('category_id', categoryId) // Use .eq for where clause
          .order('created_at', ascending: false);

      return productsData.map((data) {
        DateTime createdAt;
        String? age;

        try {
          final createdAtData = data['created_at'];
          if (createdAtData is String) {
            createdAt = DateTime.parse(createdAtData);
          } else {
            createdAt = DateTime.now(); // Fallback
          }
        } catch (e) {
          createdAt = DateTime.now(); // Fallback
        }

        age = data['age'] as String?;

        return Product.fromMap({
          'id': data['id'],
          ...data,
          'createdAt': createdAt.toIso8601String(),
          'age': age,
        });
      }).toList();
    } catch (e) {
      debugPrint('Error fetching products by category: $e');
      return [];
    }
  }
}


