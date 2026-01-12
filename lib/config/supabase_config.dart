import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Initialize Supabase with environment variables
Future<void> initializeSupabase() async {
  // Load .env file
  await dotenv.load(fileName: 'lib/.env');

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    authFlowType: AuthFlowType.pkce,
  );
}

/// Get Supabase client instance
SupabaseClient getSupabaseClient() {
  return Supabase.instance.client;
}

/// Get current user ID
String? getCurrentUserId() {
  return Supabase.instance.client.auth.currentUser?.id;
}

/// Get current user email
String? getCurrentUserEmail() {
  return Supabase.instance.client.auth.currentUser?.email;
}

/// Check if user is authenticated
bool isAuthenticated() {
  return Supabase.instance.client.auth.currentUser != null;
}
