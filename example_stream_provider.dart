// مثال على كيفية تحويل ProductProvider لاستخدام StreamProvider

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce/models/product.dart';
import 'package:ecommerce/services/supabase_service.dart';

class ProductStreamProvider {
  static Stream<List<Product>> get productsStream {
    return SupabaseService.client
        .from('products')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((data) => data.map((json) => Product.fromMap(json)).toList());
  }
  
  static Stream<List<Product>> getCategoryProductsStream(String categoryId) {
    return SupabaseService.client
        .from('products')
        .stream(primaryKey: ['id'])
        .eq('category_id', categoryId)
        .order('created_at')
        .map((data) => data.map((json) => Product.fromMap(json)).toList());
  }
}

// في main.dart:
/*
MultiProvider(
  providers: [
    // استخدام StreamProvider بدلاً من ChangeNotifierProvider
    StreamProvider<List<Product>>(
      create: (_) => ProductStreamProvider.productsStream,
      initialData: const [],
    ),
    
    // أو للمنتجات حسب الفئة
    StreamProvider<List<Product>>.value(
      value: ProductStreamProvider.getCategoryProductsStream('category_id'),
      initialData: const [],
    ),
    
    // باقي الـ providers...
  ],
  child: MyApp(),
)
*/

// في الصفحات:
/*
class ProductsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final products = context.watch<List<Product>>();
    
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ListTile(
          title: Text(product.name),
          subtitle: Text('\$${product.price}'),
        );
      },
    );
  }
}
*/
