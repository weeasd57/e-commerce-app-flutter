import 'package:flutter/material.dart';
import 'package:ecommerce/widgets/product_card.dart';
import 'package:ecommerce/widgets/category_card.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce/providers/enhanced_product_provider.dart';
import 'package:ecommerce/providers/category_provider.dart';
import 'package:ecommerce/utils/responsive_helper.dart';
import 'package:ecommerce/pages/category_products_page.dart';
import 'package:ecommerce/utils/custom_page_route.dart';
import 'package:ecommerce/providers/currency_provider.dart';
import 'package:ecommerce/l10n/app_localizations.dart';
import 'package:ecommerce/widgets/offline_cached_image_provider.dart';
import 'package:ecommerce/models/product.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecommerce/pages/product_details_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isFilterExpanded = false;

  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    // Fetch products initially if needed
    await context.read<EnhancedProductProvider>().fetchProducts();
    await context.read<CategoryProvider>().fetchCategories();
  }

  Future<void> _refreshData() async {
    // Refresh data
    await Future.wait([
      context.read<EnhancedProductProvider>().refresh(),
      context.read<CategoryProvider>().refresh(),
    ]);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();
    final localization = AppLocalizations.of(context)!;

    return RefreshIndicator(
      key: _refreshKey,
      onRefresh: _refreshData,
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: Responsive.isDesktop(context) ? 1200 : double.infinity,
          ),
          child: Consumer<EnhancedProductProvider>(
            builder: (context, productProvider, child) {
              if (productProvider.isLoading && productProvider.products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(localization.loadingData),
                    ],
                  ),
                );
              }
              
              if (productProvider.hasError && productProvider.products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${productProvider.errorMessage}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => productProvider.fetchProducts(forceRefresh: true),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final products = productProvider.products;

              return Consumer<CategoryProvider>(
                builder: (context, categoryProvider, child) {
                  final categories = categoryProvider.categories;

                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: Responsive.scaffoldPadding(context),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // شعار الترحيب
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 16),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                      Theme.of(context).primaryColor.withValues(alpha: 0.05),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.shopping_bag,
                                      size: 32,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
'مرحباً بك',
                                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
'اكتشف أحدث المنتجات والعروض المميزة',
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // معرض الصور المنزلق
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: products.isEmpty
                                    ? Container(
                                        height: 200,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.grey[300]!),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.inventory_2_outlined,
                                              size: 48,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              localization.noProductsForCarousel,
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                color: Colors.grey[600],
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      )
                                    : CarouselSlider(
                                        options: CarouselOptions(
                                          height: Responsive.isDesktop(context) ? 300 : 220,
                                          autoPlay: true,
                                          autoPlayInterval: const Duration(seconds: 4),
                                          autoPlayAnimationDuration: const Duration(milliseconds: 800),
                                          viewportFraction: 0.9,
                                          enlargeCenterPage: true,
                                          enableInfiniteScroll: true,
                                        ),
                                        items: products.take(5) // عرض أول 5 منتجات فقط
                                            .map((product) => _buildCarouselItem(product, currencyProvider))
                                            .toList(),
                                      ),
                              ),
                              
                              const SizedBox(height: 32),
                              Text(
                                localization.newArrivals,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                localization.categories,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              categories.isEmpty
                                  ? Container(
                                      height: 120,
                                      alignment: Alignment.center,
                                      child: Text(
                                        localization.noCategoriesAvailable,
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                    )
                                  : SizedBox(
                                      height: Responsive.isDesktop(context)
                                          ? 150
                                          : Responsive.isTablet(context)
                                              ? 130
                                              : 120,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: categories.length,
                                        itemBuilder: (context, index) {
                                          final category = categories[index];
                                          return CategoryCard(
                                            category: category,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                CustomPageRoute(
                                                  child: CategoryProductsPage(
                                                      category: category),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    localization.allProducts,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _isFilterExpanded = !_isFilterExpanded;
                                      });
                                    },
                                    icon: Icon(_isFilterExpanded
                                        ? Icons.filter_list_off
                                        : Icons.filter_list),
                                    label: Text(localization.filters),
                                  ),
                                ],
                              ),
                              if (_isFilterExpanded)
                                _buildFilterSection(
                                    context, localization, productProvider),
                            ],
                          ),
                        ),
                      ),
                      products.isEmpty
                          ? SliverToBoxAdapter(
                              child: Container(
                                height: 200,
                                alignment: Alignment.center,
                                child: Text(
                                  localization.noProductsAvailable,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                            )
                          : SliverPadding(
                              padding: Responsive.scaffoldPadding(context),
                              sliver: SliverGrid(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: Responsive.gridCrossAxisCount(context),
                                  childAspectRatio: 0.7,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final product = products[index];
                                    return ProductCard(
                                      product: product,
                                      isOnSale: product.onSale,
                                    );
                                  },
                                  childCount: products.length,
                                ),
                              ),
                            ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselItem(Product product, CurrencyProvider currencyProvider) {
    return Builder(
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              CustomPageRoute(
                child: ProductDetailsPage(product: product),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // صورة المنتج
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: product.imageUrls.isNotEmpty
                        ? OfflineCachedImage(
                            imageUrl: product.imageUrls.first,
                            fit: BoxFit.cover,
                            borderRadius: BorderRadius.circular(20),
                            errorWidget: Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.shopping_bag,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                  
                  // تدرج شفاف في الأسفل
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          
                          // معلومات السعر
                          if (product.hasDiscount) ...[
                            Row(
                              children: [
                                // السعر الأصلي مشطوب
                                Text(
                                  '${product.price.toStringAsFixed(0)} ${currencyProvider.currencyCode}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // شارة الخصم
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${product.discountPercentage.toStringAsFixed(0)}% خصم',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // السعر النهائي
                            Text(
                              '${product.finalPrice.toStringAsFixed(0)} ${currencyProvider.currencyCode}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ] else
                            Text(
                              '${product.finalPrice.toStringAsFixed(0)} ${currencyProvider.currencyCode}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  // شارات إضافية في الأعلى
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Row(
                      children: [
                        if (product.isNew)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'جديد',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (product.isNew && product.isHot) const SizedBox(width: 8),
                        if (product.isHot)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'ساخن',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterSection(BuildContext context,
      AppLocalizations localization, EnhancedProductProvider productProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localization.filters,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Divider(),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: Text(localization.onSale),
                selected: productProvider.showOnSale,
                onSelected: (selected) {
                  productProvider.setShowOnSale(selected);
                },
              ),
              FilterChip(
                label: Text(localization.hotItems),
                selected: productProvider.showHotItems,
                onSelected: (selected) {
                  productProvider.setShowHotItems(selected);
                },
              ),
              FilterChip(
                label: Text(localization.newArrivals),
                selected: productProvider.showNewArrivals,
                onSelected: (selected) {
                  productProvider.setShowNewArrivals(selected);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            localization.sortBy,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Divider(),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: Text(localization.newest),
                selected: productProvider.sortOption == SortOption.newest,
                onSelected: (selected) {
                  if (selected) {
                    productProvider.setSortOption(SortOption.newest);
                  }
                },
              ),
              ChoiceChip(
                label: Text(localization.priceHighToLow),
                selected:
                    productProvider.sortOption == SortOption.priceHighToLow,
                onSelected: (selected) {
                  if (selected) {
                    productProvider.setSortOption(SortOption.priceHighToLow);
                  }
                },
              ),
              ChoiceChip(
                label: Text(localization.priceLowToHigh),
                selected:
                    productProvider.sortOption == SortOption.priceLowToHigh,
                onSelected: (selected) {
                  if (selected) {
                    productProvider.setSortOption(SortOption.priceLowToHigh);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  productProvider.clearFilters();
                },
                child: Text(localization.clearFilters),
              ),
            ],
          ),
        ],
      ),
    );
  }

}


