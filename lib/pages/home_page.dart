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
              if (productProvider.isLoading &&
                  productProvider.products.isEmpty) {
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

              if (productProvider.hasError &&
                  productProvider.products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          '${localization.error}: ${productProvider.errorMessage}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            productProvider.fetchProducts(forceRefresh: true),
                        child: Text(localization.retry),
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
                                margin: EdgeInsets.only(
                                    bottom: Responsive.getPadding(context, 24),
                                    top: Responsive.getPadding(context, 16)),
                                padding: EdgeInsets.all(
                                    Responsive.getPadding(context, 24)),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(
                                          Responsive.getPadding(context, 12)),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        Icons.shopping_bag_outlined,
                                        size:
                                            Responsive.getFontSize(context, 28),
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    SizedBox(
                                        width:
                                            Responsive.getPadding(context, 16)),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            localization.hello,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize:
                                                      Responsive.getFontSize(
                                                          context, 24),
                                                ),
                                          ),
                                          SizedBox(
                                              height: Responsive.getPadding(
                                                  context, 6)),
                                          Text(
                                            localization.discoverLatestProducts,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withValues(alpha: 0.7),
                                                  fontSize:
                                                      Responsive.getFontSize(
                                                          context, 16),
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: products.isEmpty
                                    ? Container(
                                        height: 200,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                              color: Colors.grey[300]!),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.inventory_2_outlined,
                                              size: 48,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              localization
                                                  .noProductsForCarousel,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    color: Colors.grey[600],
                                                  ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      )
                                    : CarouselSlider(
                                        options: CarouselOptions(
                                          height: Responsive.isDesktop(context)
                                              ? 350
                                              : Responsive.isTablet(context)
                                                  ? 280
                                                  : 220,
                                          autoPlay: true,
                                          autoPlayInterval:
                                              const Duration(seconds: 4),
                                          autoPlayAnimationDuration:
                                              const Duration(milliseconds: 800),
                                          viewportFraction:
                                              Responsive.isDesktop(context)
                                                  ? 0.85
                                                  : Responsive.isTablet(context)
                                                      ? 0.9
                                                      : 0.9,
                                          enlargeCenterPage: true,
                                          enableInfiniteScroll: true,
                                        ),
                                        items: products
                                            .take(5) // عرض أول 5 منتجات فقط
                                            .map((product) =>
                                                _buildCarouselItem(
                                                    product, currencyProvider))
                                            .toList(),
                                      ),
                              ),

                              SizedBox(
                                  height: Responsive.getPadding(context, 32)),
                              Text(
                                localization.newArrivals,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          Responsive.getFontSize(context, 22),
                                    ),
                              ),
                              SizedBox(
                                  height: Responsive.getPadding(context, 24)),
                              Text(
                                localization.categories,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          Responsive.getFontSize(context, 22),
                                    ),
                              ),
                              SizedBox(
                                  height: Responsive.getPadding(context, 16)),
                              categories.isEmpty
                                  ? Container(
                                      height: 120,
                                      alignment: Alignment.center,
                                      child: Text(
                                        localization.noCategoriesAvailable,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
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
                              SizedBox(
                                  height: Responsive.getPadding(context, 24)),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    localization.allProducts,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: Responsive.getFontSize(
                                              context, 22),
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
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                            )
                          : SliverPadding(
                              padding: Responsive.scaffoldPadding(context),
                              sliver: SliverGrid(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      Responsive.gridCrossAxisCount(context),
                                  // تحسين نسبة العرض إلى الارتفاع لتقليل المساحات الفارغة
                                  childAspectRatio: Responsive.isMobile(context) 
                                      ? 0.75 
                                      : Responsive.isTablet(context) 
                                          ? 0.8 
                                          : 0.85,
                                  crossAxisSpacing: Responsive.isMobile(context) ? 8 : 12,
                                  mainAxisSpacing: Responsive.isMobile(context) ? 8 : 12,
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

  Widget _buildCarouselItem(
      Product product, CurrencyProvider currencyProvider) {
    final localization = AppLocalizations.of(context)!;
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
            margin: EdgeInsets.symmetric(
              horizontal: Responsive.getPadding(context, 8.0),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                Responsive.getPadding(context, 20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: Responsive.getPadding(context, 15),
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                Responsive.getPadding(context, 20),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // صورة المنتج مع تحسينات
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: product.imageUrls.isNotEmpty
                        ? OfflineCachedImage(
                            imageUrl: product.imageUrls.first,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            memCacheWidth:
                                Responsive.isDesktop(context) ? 600 : 400,
                            memCacheHeight:
                                Responsive.isDesktop(context) ? 450 : 300,
                            cacheKey:
                                'carousel_${product.id}_${product.imageUrls.first.hashCode}',
                            borderRadius: BorderRadius.circular(
                              Responsive.getPadding(context, 20),
                            ),
                            placeholder: Container(
                              color: Colors.grey[100],
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_outlined,
                                      size: Responsive.getFontSize(context, 48),
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(
                                        height:
                                            Responsive.getPadding(context, 8)),
                                    Text(
                                      localization.loadingImage,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: Responsive.getFontSize(context, 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            errorWidget: Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image_outlined,
                                      size: Responsive.getFontSize(context, 48),
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(
                                        height:
                                            Responsive.getPadding(context, 8)),
                                    Text(
                                      localization.imageNotAvailable,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: Responsive.getFontSize(context, 14),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shopping_bag_outlined,
                                    size: Responsive.getFontSize(context, 60),
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(
                                      height:
                                          Responsive.getPadding(context, 12)),
                                  Text(
                                    localization.noImageAvailable,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: Responsive.getFontSize(context, 16),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
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
                        if (product.isNew && product.isHot)
                          const SizedBox(width: 8),
                        if (product.isHot)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                localization.filters,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Filter chips section
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip(
                context,
                label: localization.onSale,
                icon: Icons.local_offer,
                selected: productProvider.showOnSale,
                onSelected: (selected) {
                  productProvider.setShowOnSale(selected);
                },
              ),
              _buildFilterChip(
                context,
                label: localization.hotItems,
                icon: Icons.local_fire_department,
                selected: productProvider.showHotItems,
                onSelected: (selected) {
                  productProvider.setShowHotItems(selected);
                },
              ),
              _buildFilterChip(
                context,
                label: localization.newArrivals,
                icon: Icons.new_releases,
                selected: productProvider.showNewArrivals,
                onSelected: (selected) {
                  productProvider.setShowNewArrivals(selected);
                },
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),

          Row(
            children: [
              Icon(
                Icons.sort,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                localization.sortBy,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sort chips section
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSortChip(
                context,
                label: localization.newest,
                selected: productProvider.sortOption == SortOption.newest,
                onSelected: (selected) {
                  if (selected) {
                    productProvider.setSortOption(SortOption.newest);
                  }
                },
              ),
              _buildSortChip(
                context,
                label: localization.priceHighToLow,
                selected:
                    productProvider.sortOption == SortOption.priceHighToLow,
                onSelected: (selected) {
                  if (selected) {
                    productProvider.setSortOption(SortOption.priceHighToLow);
                  }
                },
              ),
              _buildSortChip(
                context,
                label: localization.priceLowToHigh,
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

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  productProvider.clearFilters();
                },
                icon: const Icon(Icons.clear_all, size: 18),
                label: Text(localization.clearFilters),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: selected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: onSelected,
      selectedColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildSortChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      labelStyle: TextStyle(
        color: selected
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
