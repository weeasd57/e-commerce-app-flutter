import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'package:ecommerce/models/category.dart';
import 'package:ecommerce/services/supabase_service.dart'; // Import SupabaseService

class CategoryProvider with ChangeNotifier {
  final _db = SupabaseService.client; // Use Supabase client
  List<Category> _categories = [];
  bool _isLoading = false;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch categories from Supabase
      final List<Map<String, dynamic>> categoriesData = await _db
          .from('categories')
          .select();

      _categories = categoriesData.map((data) {
        return Category.fromMap({
          'id': data['id'], // Supabase typically uses 'id' as primary key
          ...data,
        });
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}


