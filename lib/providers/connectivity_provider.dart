import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

/// Provider لإدارة حالة الاتصال بالإنترنت
class ConnectivityProvider extends ChangeNotifier {
  bool _isOnline = true;
  bool _showOfflineIndicator = false;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  /// حالة الاتصال الحالية
  bool get isOnline => _isOnline;
  
  /// هل يجب عرض مؤشر عدم الاتصال
  bool get showOfflineIndicator => _showOfflineIndicator;

  ConnectivityProvider() {
    _initConnectivity();
    _startListening();
  }

  /// فحص حالة الاتصال الأولية
  Future<void> _initConnectivity() async {
    try {
      final List<ConnectivityResult> result = await Connectivity().checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      debugPrint('خطأ في فحص حالة الاتصال: $e');
      _isOnline = false;
      _showOfflineIndicator = true;
      notifyListeners();
    }
  }

  /// بدء الاستماع لتغييرات حالة الاتصال
  void _startListening() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> result) {
        _updateConnectionStatus(result);
      },
      onError: (error) {
        debugPrint('خطأ في مراقبة الاتصال: $error');
        _isOnline = false;
        _showOfflineIndicator = true;
        notifyListeners();
      },
    );
  }

  /// تحديث حالة الاتصال
  void _updateConnectionStatus(List<ConnectivityResult> result) {
    final bool wasOnline = _isOnline;
    
    // فحص وجود أي اتصال
    _isOnline = result.any((connectivity) => 
      connectivity == ConnectivityResult.wifi ||
      connectivity == ConnectivityResult.mobile ||
      connectivity == ConnectivityResult.ethernet
    );

    // تحديد متى يجب عرض المؤشر
    if (!_isOnline && wasOnline) {
      // انقطع الاتصال - عرض المؤشر
      _showOfflineIndicator = true;
      debugPrint('🔴 انقطع الاتصال بالإنترنت');
    } else if (_isOnline && !wasOnline) {
      // عاد الاتصال - إخفاء المؤشر بعد فترة قصيرة
      debugPrint('🟢 تم استعادة الاتصال بالإنترنت');
      
      // إخفاء المؤشر بعد 2 ثانية لإعطاء المستخدم وقت لملاحظة عودة الاتصال
      Future.delayed(const Duration(seconds: 2), () {
        if (_isOnline) {
          _showOfflineIndicator = false;
          notifyListeners();
        }
      });
    }

    notifyListeners();
  }

  /// إجبار إظهار/إخفاء مؤشر عدم الاتصال
  void setShowOfflineIndicator(bool show) {
    _showOfflineIndicator = show;
    notifyListeners();
  }

  /// فحص حالة الاتصال يدوياً
  Future<void> checkConnectivity() async {
    await _initConnectivity();
  }

  /// رسالة الحالة الحالية
  String get statusMessage {
    if (_isOnline) {
      return 'متصل بالإنترنت';
    } else {
      return 'غير متصل بالإنترنت';
    }
  }

  /// نوع الاتصال الحالي
  Future<String> getConnectionType() async {
    try {
      final List<ConnectivityResult> result = await Connectivity().checkConnectivity();
      
      if (result.contains(ConnectivityResult.wifi)) {
        return 'WiFi';
      } else if (result.contains(ConnectivityResult.mobile)) {
        return 'شبكة محمولة';
      } else if (result.contains(ConnectivityResult.ethernet)) {
        return 'كابل شبكة';
      } else {
        return 'غير متصل';
      }
    } catch (e) {
      return 'غير معروف';
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
