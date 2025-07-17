import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://jqmdtixfdrdjbtwfogth.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpxbWR0aXhmZHJkamJ0d2ZvZ3RoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIxNDc2MTYsImV4cCI6MjA2NzcyMzYxNn0.kPCYWps3ga0lijFVJC7LmbkQoanXb9WARXDcHx2sU4g',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static Future<Map<String, dynamic>> getAppSettings() async {
    try {
      final List<Map<String, dynamic>> response = await client
          .from('app_settings')
          .select('currency_code, delivery_cost');
      
      if (response.isEmpty) {
        // إذا لم يتم العثور على إعدادات، إرجاع القيم الافتراضية
        return {
          'currency_code': 'USD',
          'delivery_cost': 0.00,
        };
      }
      
      return response.first;
    } catch (e) {
      debugPrint('خطأ في جلب إعدادات التطبيق: $e');
      // إرجاع القيم الافتراضية في حالة حدوث خطأ
      return {
        'currency_code': 'USD',
        'delivery_cost': 0.00,
      };
    }
  }
}


