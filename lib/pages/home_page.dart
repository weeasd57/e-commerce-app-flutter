import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecommerce/widgets/product_card.dart';
import 'package:ecommerce/widgets/category_card.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce/providers/product_provider.dart';
import 'package:ecommerce/providers/category_provider.dart';
import 'package:ecommerce/utils/responsive_helper.dart';
import 'package:ecommerce/pages/category_products_page.dart';
import 'package:ecommerce/utils/custom_page_route.dart';
import 'package:ecommerce/providers/currency_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProductProvider>().fetchProducts();
      context.read<CategoryProvider>().fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();

    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: Responsive.isDesktop(context) ? 1200 : double.infinity,
        ),
        child: Consumer<ProductProvider>(
          builder: (context, productProvider, child) {
            if (productProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () async {
                await productProvider.fetchProducts();
                await context.read<CategoryProvider>().fetchCategories();
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: Responsive.scaffoldPadding(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CarouselSlider(
                            options: CarouselOptions(
                              height: Responsive.isDesktop(context)
                                  ? 400
                                  : Responsive.isTablet(context)
                                      ? 300
                                      : 200,
                              autoPlay: true,
                              enlargeCenterPage: true,
                              aspectRatio: 16 / 9,
                              autoPlayCurve: Curves.fastOutSlowIn,
                              enableInfiniteScroll: true,
                              autoPlayAnimationDuration:
                                  const Duration(milliseconds: 800),
                              viewportFraction: 0.8,
                            ),
                            items: productProvider.saleProducts
                                .take(5)
                                .map((product) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            product.imageUrls.first),
                                        fit: BoxFit.cover,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                            '${product.salePrice} ${currencyProvider.currencyCode}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Categories',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Consumer<CategoryProvider>(
                            builder: (context, categoryProvider, child) {
                              if (categoryProvider.isLoading) {
                                return const Center(
                                    child: CircularProgressIndicator());
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
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
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
              ),
            );
          },
        ),
      ),
    );
  }
}
