import 'package:flutter/material.dart';
// Import Supabase
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

      
      if (categoriesData.isEmpty) {
        debugPrint('No categories found in database, creating sample data...');
        await _createSampleCategories();
        
        // Try fetching again after creating sample data
        final retryData = await _db
            .from('categories')
            .select();
        
        if (retryData.isNotEmpty) {
          debugPrint('Sample categories created successfully, processing...');
          _processFetchedCategories(retryData);
        } else {
          debugPrint('Failed to create sample categories');
          _categories = [];
        }
      } else {
        _processFetchedCategories(categoriesData);
      }

    } catch (e) {
      debugPrint('Error fetching categories: $e');
      _categories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void _processFetchedCategories(List<Map<String, dynamic>> categoriesData) {
    try {
      _categories = categoriesData.map((data) {
        return Category.fromMap({
          'id': data['id']?.toString() ?? '',
          'name': data['name']?.toString() ?? 'Unknown',
          'icon': data['icon']?.toString(),
          'imageUrl': data['image_url']?.toString(),
          ...data,
        });
      }).toList();
      
      
    } catch (e) {
      debugPrint('Error processing categories: $e');
      _categories = [];
    }
    notifyListeners();
  }
  
  Future<void> _createSampleCategories() async {
    try {
      final sampleCategories = [
        {
          'name': 'public',
          'description': 'Public category',
          'icon': 'public',
          'color': '#2196F3',
        },
        {
          'name': 'المدارس',
          'description': 'Schools category',
          'icon': 'school',
          'color': '#4CAF50',
        },
        {
          'name': 'المنزل والحديقة',
          'description': 'Home and garden category',
          'icon': 'home',
          'color': '#FF9800',
        },
      ];
      
      await _db.from('categories').insert(sampleCategories);
      debugPrint('Sample categories inserted successfully');
    } catch (e) {
      debugPrint('Error creating sample categories: $e');
    }
  }
}


