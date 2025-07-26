import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce/l10n/app_localizations.dart';
import 'package:ecommerce/providers/enhanced_product_provider.dart';
import 'package:ecommerce/widgets/product_card.dart';
import 'package:ecommerce/utils/responsive_helper.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final productProvider = Provider.of<EnhancedProductProvider>(context);

    // Combine hot products and new products for popular searches
    final List<String> popularSearches = [
      ...productProvider.hotProducts
          .take(5)
          .map((p) => p.name)
          .toList(), // Take top 5 hot product names
      ...productProvider.newProducts
          .take(5)
          .map((p) => p.name)
          .toList(), // Take top 5 new product names
    ];

    final filteredProducts = _searchQuery.isEmpty
        ? []
        : productProvider.products
            .where((product) =>
                product.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: localization.search,
            border: InputBorder.none,
            hintStyle:
                TextStyle(color: Theme.of(context).hintColor.withValues(alpha: 0.7)),
          ),
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          cursorColor: Theme.of(context).primaryColor,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: Responsive.scaffoldPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_searchQuery.isEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localization.popularSearches,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: popularSearches.map((tag) {
                          return InkWell(
                            onTap: () {
                              _searchController.text = tag;
                              _onSearchChanged();
                            },
                            child: Chip(
                              label: Text(tag),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filter and Sort Section
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // Filters
                          FilterChip(
                            label: Text(localization.onSale),
                            selected: productProvider.showOnSale,
                            onSelected: (selected) {
                              productProvider.setShowOnSale(selected);
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: Text(localization.hotItems),
                            selected: productProvider.showHotItems,
                            onSelected: (selected) {
                              productProvider.setShowHotItems(selected);
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: Text(localization.newArrivals),
                            selected: productProvider.showNewArrivals,
                            onSelected: (selected) {
                              productProvider.setShowNewArrivals(selected);
                            },
                          ),
                          const SizedBox(width: 8),
                          // Sort by
                          DropdownButton<SortOption>(
                            value: productProvider.sortOption,
                            onChanged: (SortOption? newValue) {
                              if (newValue != null) {
                                productProvider.setSortOption(newValue);
                              }
                            },
                            items: <DropdownMenuItem<SortOption>>[
                              DropdownMenuItem(
                                value: SortOption.newest,
                                child: Text(localization.newest),
                              ),
                              DropdownMenuItem(
                                value: SortOption.priceLowToHigh,
                                child: Text(localization.priceLowToHigh),
                              ),
                              DropdownMenuItem(
                                value: SortOption.priceHighToLow,
                                child: Text(localization.priceHighToLow),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          // Clear Filters button
                          TextButton(
                            onPressed: () {
                              productProvider.clearFilters();
                            },
                            child: Text(localization.clearFilters),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Content area
                    Expanded(
                      child: filteredProducts.isEmpty
                          ? Center(
                              child: Text(
                                  localization.noResultsFound(_searchQuery)),
                            )
                          : GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    Responsive.gridCrossAxisCount(context),
                                childAspectRatio: 0.8,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = filteredProducts[index];
                                return ProductCard(
                                  product: product,
                                  isOnSale: product.onSale,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
