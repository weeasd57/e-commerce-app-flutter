import 'dart:async';
import 'package:ecommerce/models/product.dart';
import 'package:ecommerce/models/category.dart';
import 'package:ecommerce/providers/flutter_stream_product_provider.dart';
import 'package:ecommerce/providers/flutter_stream_category_provider.dart';

/// Stream provider للمنتجات الرئيسية
class ProductsStreamProvider {
  static final FlutterStreamProductProvider _productProvider = FlutterStreamProductProvider();
  
  static Stream<List<Product>> get productsStream => _productProvider.productsStream;
  static Stream<List<Product>> get newProductsStream => _productProvider.newProductsStream;
  static Stream<List<Product>> get saleProductsStream => _productProvider.saleProductsStream;
  static Stream<List<Product>> get hotProductsStream => _productProvider.hotProductsStream;
  static Stream<bool> get loadingStream => _productProvider.loadingStream;
  
  static FlutterStreamProductProvider get provider => _productProvider;
  
  // Initialize the provider
  static Future<void> initialize() async {
    await _productProvider.fetchProducts();
  }
  
  // Refresh data
  static Future<void> refresh() async {
    await _productProvider.refresh();
  }
  
  // Filter methods
  static void setShowOnSale(bool value) => _productProvider.setShowOnSale(value);
  static void setShowHotItems(bool value) => _productProvider.setShowHotItems(value);
  static void setShowNewArrivals(bool value) => _productProvider.setShowNewArrivals(value);
  static void setSortOption(SortOption option) => _productProvider.setSortOption(option);
  static void clearFilters() => _productProvider.clearFilters();
  
  // Get current state
  static List<Product> get currentProducts => _productProvider.products;
  static bool get isLoading => _productProvider.isLoading;
  static bool get hasError => _productProvider.hasError;
  static bool get isOffline => _productProvider.isOffline;
}

/// Stream provider للفئات
class CategoriesStreamProvider {
  static final FlutterStreamCategoryProvider _categoryProvider = FlutterStreamCategoryProvider();
  
  static Stream<List<Category>> get categoriesStream => _categoryProvider.categoriesStream;
  static Stream<bool> get loadingStream => _categoryProvider.loadingStream;
  
  static FlutterStreamCategoryProvider get provider => _categoryProvider;
  
  // Initialize the provider
  static Future<void> initialize() async {
    await _categoryProvider.fetchCategories();
  }
  
  // Refresh data
  static Future<void> refresh() async {
    await _categoryProvider.refresh();
  }
  
  // Get current state
  static List<Category> get currentCategories => _categoryProvider.categories;
  static bool get isLoading => _categoryProvider.isLoading;
  static bool get hasError => _categoryProvider.hasError;
  static bool get isOffline => _categoryProvider.isOffline;
  
  // Helper methods
  static Category? getCategoryById(String id) => _categoryProvider.getCategoryById(id);
  static List<Category> searchCategories(String query) => _categoryProvider.searchCategories(query);
}

/// Stream provider للمنتجات حسب الفئة
class CategoryProductsStreamProvider {
  static final Map<String, StreamController<List<Product>>> _categoryStreams = {};
  static final FlutterStreamProductProvider _productProvider = ProductsStreamProvider.provider;
  
  static Stream<List<Product>> getCategoryProductsStream(String categoryId) {
    // Create stream controller for this category if it doesn't exist
    if (!_categoryStreams.containsKey(categoryId)) {
      _categoryStreams[categoryId] = StreamController<List<Product>>.broadcast();
      _initializeCategoryStream(categoryId);
    }
    
    return _categoryStreams[categoryId]!.stream;
  }
  
  static void _initializeCategoryStream(String categoryId) async {
    final controller = _categoryStreams[categoryId]!;
    
    // Listen to main products stream and filter by category
    _productProvider.productsStream.listen((allProducts) {
      final categoryProducts = allProducts.where((product) => product.categoryId == categoryId).toList();
      
      if (!controller.isClosed) {
        controller.add(categoryProducts);
      }
    });
    
    // Initial load
    try {
      final categoryProducts = await _productProvider.fetchProductsByCategory(categoryId);
      if (!controller.isClosed) {
        controller.add(categoryProducts);
      }
    } catch (e) {
      if (!controller.isClosed) {
        controller.addError(e);
      }
    }
  }
  
  static void disposeCategoryStream(String categoryId) {
    final controller = _categoryStreams[categoryId];
    if (controller != null) {
      controller.close();
      _categoryStreams.remove(categoryId);
    }
  }
  
  static void disposeAllCategoryStreams() {
    for (final controller in _categoryStreams.values) {
      controller.close();
    }
    _categoryStreams.clear();
  }
}

/// Combined stream provider للـ HomePage
class HomePageStreamProvider {
  // Combined streams for homepage
  static Stream<HomePageData> get homePageDataStream {
    return StreamZip([
      ProductsStreamProvider.productsStream,
      ProductsStreamProvider.newProductsStream,
      ProductsStreamProvider.saleProductsStream,
      ProductsStreamProvider.hotProductsStream,
      CategoriesStreamProvider.categoriesStream,
    ]).map((List<dynamic> data) {
      return HomePageData(
        products: data[0] as List<Product>,
        newProducts: data[1] as List<Product>,
        saleProducts: data[2] as List<Product>,
        hotProducts: data[3] as List<Product>,
        categories: data[4] as List<Category>,
      );
    });
  }
  
  static Stream<bool> get loadingStream {
    return StreamZip([
      ProductsStreamProvider.loadingStream,
      CategoriesStreamProvider.loadingStream,
    ]).map((List<bool> loadingStates) {
      return loadingStates.any((isLoading) => isLoading);
    });
  }
  
  static Future<void> initialize() async {
    await Future.wait([
      ProductsStreamProvider.initialize(),
      CategoriesStreamProvider.initialize(),
    ]);
  }
  
  static Future<void> refresh() async {
    await Future.wait([
      ProductsStreamProvider.refresh(),
      CategoriesStreamProvider.refresh(),
    ]);
  }
}

// Data class for combined homepage data
class HomePageData {
  final List<Product> products;
  final List<Product> newProducts;
  final List<Product> saleProducts;
  final List<Product> hotProducts;
  final List<Category> categories;
  
  const HomePageData({
    required this.products,
    required this.newProducts,
    required this.saleProducts,
    required this.hotProducts,
    required this.categories,
  });
  
  bool get isEmpty => products.isEmpty && categories.isEmpty;
}

// Custom StreamZip implementation (if not available in your project)
class StreamZip<T> extends Stream<List<T>> {
  final List<Stream<T>> _streams;
  
  StreamZip(this._streams);
  
  @override
  StreamSubscription<List<T>> listen(
    void Function(List<T>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    late StreamSubscription<List<T>> subscription;
    late StreamController<List<T>> controller;
    
    controller = StreamController<List<T>>(
      onListen: () {
        final subscriptions = <StreamSubscription>[];
        final values = <T?>[]..length = _streams.length;
        final hasValue = <bool>[]..length = _streams.length;
        
        void tryEmit() {
          if (hasValue.every((has) => has)) {
            controller.add(values.cast<T>());
          }
        }
        
        for (int i = 0; i < _streams.length; i++) {
          final index = i;
          subscriptions.add(
            _streams[i].listen(
              (value) {
                values[index] = value;
                hasValue[index] = true;
                tryEmit();
              },
              onError: controller.addError,
              onDone: () {
                if (subscriptions.every((sub) => sub.isPaused)) {
                  controller.close();
                }
              },
            ),
          );
        }
      },
      onCancel: () {
        // Cancel all subscriptions when controller is cancelled
      },
    );
    
    subscription = controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
    
    return subscription;
  }
}
