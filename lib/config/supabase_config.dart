import 'package:supabase_flutter/supabase_flutter.dart';

/// Minimal Supabase bootstrap (no env loading in this demo build)
Future<void> initializeSupabase() async {
  // Skip initialization in the lightweight demo build.
  // Provide a dummy client so dependent code can compile.
  if (!Supabase.instance.isInitialized) {
    await Supabase.initialize(url: 'https://demo.supabase.co', anonKey: 'demo');
  }
}

SupabaseClient getSupabaseClient() => Supabase.instance.client;
String? getCurrentUserId() => null;
String? getCurrentUserEmail() => null;
bool isAuthenticated() => false;
