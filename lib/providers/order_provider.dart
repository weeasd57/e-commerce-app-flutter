import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order.dart' as ord;

class OrderProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      _orders = snapshot.docs.map((doc) {
        // Add document ID to the order data
        final data = doc.data();
        data['id'] = doc.id;
        return ord.Order.fromMap(data);
      }).toList();
    } catch (error) {
      // Handle error appropriately in a real app
      print(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteOrder(String orderId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Find the document with this order ID
      final orderQuery = await _firestore
          .collection('orders')
          .where('id', isEqualTo: orderId)
          .get();

      // If we found the document, delete it
      if (orderQuery.docs.isNotEmpty) {
        await _firestore
            .collection('orders')
            .doc(orderQuery.docs.first.id)
            .delete();
      } else {
        // Try to delete by document ID directly
        await _firestore.collection('orders').doc(orderId).delete();
      }

      // Remove the order from the local list
      _orders.removeWhere((order) => order.id == orderId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      print('Error deleting order: $error');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
