import 'package:flutter/material.dart';
import 'package:ecommerce/widgets/product_card.dart';
import 'package:ecommerce/widgets/category_card.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce/providers/product_provider.dart';
import 'package:ecommerce/providers/category_provider.dart';
import 'package:ecommerce/utils/responsive_helper.dart';
import 'package:ecommerce/pages/category_products_page.dart';
import 'package:ecommerce/utils/custom_page_route.dart';
import 'package:ecommerce/providers/currency_provider.dart';
import 'package:ecommerce/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
    // استخدام addPostFrameCallback لتجنب تحديث الحالة أثناء البناء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      // بدء الـ real-time updates
      _startRealTimeUpdates();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    // تحميل البيانات فقط إذا كانت فارغة أو قديمة
    await Future.wait([
      context.read<ProductProvider>().fetchProducts(),
      context.read<CategoryProvider>().fetchCategories(),
    ]);
  }

  Future<void> _refreshData() async {
    // تحميل البيانات بالقوة عند السحب للتحديث
    await Future.wait([
      context.read<ProductProvider>().fetchProducts(forceRefresh: true),
      context.read<CategoryProvider>().fetchCategories(forceRefresh: true),
    ]);
  }

  void _startRealTimeUpdates() {
    final productProvider = context.read<ProductProvider>();
    productProvider.startRealTimeUpdates();
  }

  @override
  void dispose() {
    // إيقاف الـ real-time updates عند إغلاق الصفحة
    context.read<ProductProvider>().stopRealTimeUpdates();
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
          child: Consumer2<ProductProvider, CategoryProvider>(
            builder: (context, productProvider, categoryProvider, child) {
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
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: Responsive.scaffoldPadding(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: productProvider.products.isEmpty
                                ? Container(
                                    height: 200,
                                    alignment: Alignment.center,
                                    child: Text(
                                      localization.noProductsForCarousel,
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                  )
                                : CarouselSlider(
                                    options: CarouselOptions(
                                      height: Responsive.isDesktop(context) ? 300 : 200,
                                      autoPlay: true,
                                      autoPlayInterval: const Duration(seconds: 5),
                                      viewportFraction: 1.0,
                                    ),
                                    items: productProvider.products
                                        .map((product) => _buildCarouselItem(product, currencyProvider))
                                        .toList(),
                                  ),
                          ),
                          Text(
                            localization.newArrivals,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            localization.categories,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Consumer<CategoryProvider>(
                            builder: (context, categoryProvider, child) {
                              if (categoryProvider.isLoading) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              
                              if (categoryProvider.categories.isEmpty) {
                                return Container(
                                  height: 120,
                                  alignment: Alignment.center,
                                  child: Text(
                                    localization.noCategoriesAvailable,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                );
                              }
                              
                              return SizedBox(
                                height: Responsive.isDesktop(context)
                                    ? 150
                                    : Responsive.isTablet(context)
                                        ? 130
                                        : 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: categoryProvider.categories.length,
                                  itemBuilder: (context, index) {
                                    final category =
                                        categoryProvider.categories[index];
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
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                localization.allProducts,
                                style: Theme.of(context).textTheme.titleLarge,
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
                  productProvider.products.isEmpty
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
                                final product = productProvider.products[index];
                                return ProductCard(
                                  product: product,
                                  isOnSale: product.onSale,
                                );
                              },
                              childCount: productProvider.products.length,
                            ),
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

  Widget _buildCarouselItem(Product product, CurrencyProvider currencyProvider) {
    return Builder(
      builder: (BuildContext context) {
        final imageProvider = (product.imageUrls.isNotEmpty)
            ? CachedNetworkImageProvider(product.imageUrls.first)
            : const AssetImage('assets/images/logo.png') as ImageProvider;
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
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
                onError: (error, stackTrace) {
                  debugPrint('Error loading image: $error');
                },
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.onSale && product.salePrice != null
                        ? '${product.salePrice} ${currencyProvider.currencyCode}'
                        : '${product.price} ${currencyProvider.currencyCode}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
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
      AppLocalizations localization, ProductProvider productProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
