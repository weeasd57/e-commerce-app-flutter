import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/models/category.dart';

class CategoryProvider with ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  List<Category> _categories = [];
  bool _isLoading = false;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _db.collection('categories').get();
      _categories = snapshot.docs.map((doc) {
        return Category.fromMap({
          'id': doc.id,
          ...doc.data(),
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
