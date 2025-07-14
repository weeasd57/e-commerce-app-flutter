import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import '../models/order.dart' as ord;
import 'package:ecommerce/services/supabase_service.dart'; // Import SupabaseService

class OrderProvider with ChangeNotifier {
  final SupabaseClient _supabase = SupabaseService.client; // Use Supabase client
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<ord.Order> _orders = [];
  bool _isLoading = false;

  List<ord.Order> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> fetchOrders() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final List<Map<String, dynamic>> ordersData = await _supabase
          .from('orders')
          .select()
          .eq('userId', user.uid)
          .order('createdAt', ascending: false);

      _orders = ordersData.map((data) {
        return ord.Order.fromMap({
          'id': data['id'], // Supabase typically uses 'id' as primary key
          ...data,
        });
      }).toList();
    } catch (error) {
      debugPrint('Error fetching orders: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteOrder(String orderId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase
          .from('orders')
          .delete()
          .eq('id', orderId);

      // Remove the order from the local list
      _orders.removeWhere((order) => order.id == orderId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      debugPrint('Error deleting order: $error');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}


