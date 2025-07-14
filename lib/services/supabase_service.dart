import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://jqmdtixfdrdjbtwfogth.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpxbWR0aXhmZHJkamJ0d2ZvZ3RoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIxNDc2MTYsImV4cCI6MjA2NzcyMzYxNn0.kPCYWps3ga0lijFVJC7LmbkQoanXb9WARXDcHx2sU4g',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}


