import 'package:flutter/material.dart';
import 'dart:async';
import 'package:ecommerce/models/product.dart';
import 'package:ecommerce/services/supabase_service.dart';

class ProductDetailsProvider with ChangeNotifier {
  final _db = SupabaseService.client;
  Product? _product;
  bool _isLoading = false;
  bool _hasError = false;
  StreamSubscription? _productStreamSubscription;

  Product? get product => _product;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  /// بدء الاستماع لتحديثات المنتج في الوقت الفعلي
  void startRealTimeUpdates(String productId) {
    // إلغاء الاشتراك السابق
    stopRealTimeUpdates();

    _isLoading = true;
    notifyListeners();

    try {
      // بدء الاستماع للتغييرات في المنتج المحدد
      _productStreamSubscription = _db
          .from('products')
          .stream(primaryKey: ['id'])
          .eq('id', productId)
          .listen(
            (List<Map<String, dynamic>> data) {
              try {
                if (data.isNotEmpty) {
                  final json = data.first;
                  DateTime createdAt;
                  String? age;

                  try {
                    final createdAtData = json['created_at'];
                    if (createdAtData is String) {
                      createdAt = DateTime.parse(createdAtData);
                    } else {
                      createdAt = DateTime.now();
                    }
                  } catch (e) {
                    createdAt = DateTime.now();
                  }

                  age = json['age'] as String?;

                  _product = Product.fromMap({
                    'id': json['id']?.toString() ?? '',
                    ...json,
                    'createdAt': createdAt.toIso8601String(),
                    'age': age,
                  });
                  _hasError = false;
                } else {
                  _product = null;
                  _hasError = true;
                }
                _isLoading = false;
                notifyListeners();
              } catch (e) {
                debugPrint('خطأ في تحديث بيانات المنتج: $e');
                _hasError = true;
                _isLoading = false;
                notifyListeners();
              }
            },
            onError: (error) {
              debugPrint('خطأ في stream المنتج: $error');
              _hasError = true;
              _isLoading = false;
              notifyListeners();
            },
          );
    } catch (e) {
      debugPrint('خطأ في بدء stream المنتج: $e');
      _hasError = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// إيقاف الاستماع للتحديثات
  void stopRealTimeUpdates() {
    _productStreamSubscription?.cancel();
    _productStreamSubscription = null;
  }

  /// تحديث المنتج محلياً (مفيد عند التنقل من صفحات أخرى)
  void setProduct(Product product) {
    _product = product;
    notifyListeners();
  }

  /// تحديث حالة المنتج (مثل إضافة للمفضلة أو السلة)
  void updateProductState() {
    // يمكن استخدامها لإجبار التحديث
    notifyListeners();
  }

  @override
  void dispose() {
    stopRealTimeUpdates();
    super.dispose();
  }
}
