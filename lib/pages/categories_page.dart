import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce/providers/category_provider.dart';
import 'package:ecommerce/pages/category_products_page.dart';
import 'package:ecommerce/utils/responsive_helper.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: Responsive.isDesktop(context) ? 1200 : double.infinity,
          ),
          padding: Responsive.scaffoldPadding(context),
          child: Consumer<CategoryProvider>(
            builder: (context, categoryProvider, _) {
              if (categoryProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: Responsive.gridCrossAxisCount(context),
                  childAspectRatio: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: categoryProvider.categories.length,
                itemBuilder: (context, index) {
                  final category = categoryProvider.categories[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CategoryProductsPage(category: category),
                        ),
                      );
                    },
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (category.imageUrl != null)
                            Image.network(
                              category.imageUrl!,
                              fit: BoxFit.cover,
                            )
                          else
                            Container(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                              child: Icon(
                                Icons.category_outlined,
                                size: 50,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 10,
                            right: 10,
                            child: Text(
                              category.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
