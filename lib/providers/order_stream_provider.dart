import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart' as ord;
import 'package:ecommerce/services/supabase_service.dart';

/// Provider للطلبات يستخدم Stream فقط
class OrderStreamProvider with ChangeNotifier {
  final SupabaseClient _supabase = SupabaseService.client;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  
  // Stream Controllers
  StreamController<List<ord.Order>>? _ordersController;
  StreamController<bool>? _loadingController;
  StreamController<String?>? _errorController;
  
  // Subscriptions and control
  StreamSubscription? _authStreamSubscription;
  StreamSubscription? _ordersStreamSubscription;
  bool _isStreamActive = false;
  bool _isOnOrdersPage = false;
  
  // Current state
  List<ord.Order> _currentOrders = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters for current state (for immediate access)
  List<ord.Order> get currentOrders => _currentOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  
  // Stream getters
  Stream<List<ord.Order>> get ordersStream {
    _initializeStreamsIfNeeded();
    return _ordersController!.stream;
  }
  
  Stream<bool> get loadingStream {
    _initializeStreamsIfNeeded();
    return _loadingController!.stream;
  }
  
  Stream<String?> get errorStream {
    _initializeStreamsIfNeeded();
    return _errorController!.stream;
  }
  
  OrderStreamProvider() {
    _initializeStreamsIfNeeded();
    _setupAuthListener();
  }
  
  // Initialize stream controllers if needed
  void _initializeStreamsIfNeeded() {
    if (_ordersController == null || _ordersController!.isClosed) {
      _ordersController = StreamController<List<ord.Order>>.broadcast();
      _loadingController = StreamController<bool>.broadcast();
      _errorController = StreamController<String?>.broadcast();
    }
  }
  
  // Setup authentication listener
  void _setupAuthListener() {
    _authStreamSubscription?.cancel();
    _authStreamSubscription = _auth.authStateChanges().listen((firebase_auth.User? user) {
      if (user != null) {
        _startOrderStream();
      } else {
        // No need to stop stream
        _updateState([], false, null);
      }
    });
  }
  
  // Start orders stream
  void _startOrderStream() {
    if (_isStreamActive) return; // تجنب بدء عدة streams
    
    _isStreamActive = true;
    _ordersStreamSubscription = createOrdersStream().listen((orders) {
      // فقط update إذا كان المستخدم في صفحة الطلبات أو لديه طلبات
      if (_isOnOrdersPage || orders.isNotEmpty) {
        _updateState(orders, false, null);
      }
    });
  }

  // Create orders stream with polling every 30 seconds
  Stream<List<ord.Order>> createOrdersStream() async* {
    while (true) {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        yield <ord.Order>[];
        await Future.delayed(Duration(seconds: 30));
        continue;
      }
      
      try {
        final userEmail = user.email ?? '';
        final userData = await _supabase
            .from('users')
            .select('id')
            .eq('email', userEmail)
            .maybeSingle();

        if (userData == null) {
          yield <ord.Order>[];
          await Future.delayed(Duration(seconds: 30));
          continue;
        }

        final userId = userData['id'];

        final response = await _supabase
            .from('orders')
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: false);

        final orders = (response as List<dynamic>).map((json) {
          return ord.Order.fromMap({
            'id': json['id'],
            ...json,
          });
        }).toList();
        
        debugPrint('✅ Stream polled ${orders.length} orders');
        yield orders;
      } catch (error) {
        debugPrint('❌ Stream polling error: $error');
        yield <ord.Order>[];
      }
      
      // Wait 30 seconds before next poll
      await Future.delayed(Duration(seconds: 30));
    }
  }

  // Stream handles data fetching automatically
  
  // Update state and notify streams and listeners
  void _updateState(List<ord.Order> orders, bool loading, String? error) {
    // Update internal state
    _currentOrders = orders;
    _isLoading = loading;
    _errorMessage = error;
    
    // Notify Provider listeners
    notifyListeners();
    
    // Update streams
    if (_ordersController != null && !_ordersController!.isClosed) {
      _ordersController!.add(orders);
    }
    if (_loadingController != null && !_loadingController!.isClosed) {
      _loadingController!.add(loading);
    }
    if (_errorController != null && !_errorController!.isClosed) {
      _errorController!.add(error);
    }
  }
  
  // Delete an order
  Future<bool> deleteOrder(String orderId) async {
    try {
      _updateState(_currentOrders, true, null);
      
      await _supabase
          .from('orders')
          .delete()
          .eq('id', orderId);
      
      // Stream will automatically update
      
      debugPrint('✅ Order deleted successfully: $orderId');
      return true;
    } catch (error) {
      debugPrint('❌ Error deleting order: $error');
      _updateState(_currentOrders, false, 'فشل في حذف الطلب: $error');
      return false;
    }
  }
  
  // Manual refresh for immediate update
  Future<void> refreshOrders() async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      _updateState([], false, 'يجب تسجيل الدخول أولاً');
      return;
    }
    
    _updateState(_currentOrders, true, null); // Set loading
    
    try {
      final userEmail = user.email ?? '';
      final userData = await _supabase
          .from('users')
          .select('id')
          .eq('email', userEmail)
          .maybeSingle();

      if (userData == null) {
        _updateState([], false, 'المستخدم غير موجود');
        return;
      }

      final userId = userData['id'];

      final response = await _supabase
          .from('orders')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final orders = (response as List<dynamic>).map((json) {
        return ord.Order.fromMap({
          'id': json['id'],
          ...json,
        });
      }).toList();
      
      _updateState(orders, false, null);
      debugPrint('✅ Manual refresh completed with ${orders.length} orders');
    } catch (error) {
      debugPrint('❌ Error refreshing orders: $error');
      _updateState(_currentOrders, false, 'خطأ في تحديث البيانات: $error');
    }
  }
  
  // Clear error
  void clearError() {
    if (_errorMessage != null) {
      _updateState(_currentOrders, _isLoading, null);
    }
  }
  
  // Get order by ID
  ord.Order? getOrderById(String orderId) {
    try {
      return _currentOrders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }
  
  // Get orders by status
  List<ord.Order> getOrdersByStatus(String status) {
    return _currentOrders.where((order) => 
        order.status.toLowerCase() == status.toLowerCase()).toList();
  }
  
  // Search orders
  List<ord.Order> searchOrders(String query) {
    if (query.trim().isEmpty) return _currentOrders;
    
    final lowerQuery = query.toLowerCase();
    return _currentOrders.where((order) => 
        order.id.toLowerCase().contains(lowerQuery) ||
        order.name.toLowerCase().contains(lowerQuery) ||
        order.phone.contains(query) ||
        order.address.toLowerCase().contains(lowerQuery)
    ).toList();
  }
  
  // **وظائف التحكم في Stream polling**
  
  /// يتم استدعاؤها عند دخول المستخدم لصفحة الطلبات
  void enterOrdersPage() {
    debugPrint('🔵 User entered orders page - Starting stream');
    _isOnOrdersPage = true;
    if (!_isStreamActive) {
      _startOrderStream();
    }
  }
  
  /// يتم استدعاؤها عند مغادرة المستخدم لصفحة الطلبات
  void exitOrdersPage() {
    debugPrint('🔴 User exited orders page - Pausing stream');
    _isOnOrdersPage = false;
    // إيقاف مؤقت للـ stream إذا لم تكن هناك طلبات
    if (_currentOrders.isEmpty) {
      _pauseStream();
    }
  }
  
  /// إيقاف مؤقت للـ stream
  void _pauseStream() {
    debugPrint('⏸️ Pausing stream polling to save resources');
    _ordersStreamSubscription?.cancel();
    _isStreamActive = false;
  }
  
  /// إعادة تفعيل Stream
  void resumeStream() {
    debugPrint('▶️ Resuming stream polling');
    if (!_isStreamActive) {
      _startOrderStream();
    }
  }
  
  /// إيقاف نهائي للـ stream
  void stopStream() {
    debugPrint('⛔ Stopping stream completely');
    _ordersStreamSubscription?.cancel();
    _isStreamActive = false;
    _isOnOrdersPage = false;
  }
  
  @override
  void dispose() {
    _authStreamSubscription?.cancel();
    _ordersStreamSubscription?.cancel(); // إيقاف stream polling
    _ordersController?.close();
    _loadingController?.close();
    _errorController?.close();
    super.dispose();
  }
}
