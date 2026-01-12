import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  late final SupabaseClient _supabaseClient;
  
  User? _currentUser;
  User? get currentUser => _currentUser;
  
  bool get isAuthenticated => _currentUser != null;
  String? get userId => _currentUser?.id;
  String? get userEmail => _currentUser?.email;

  Future<void> initialize(SupabaseClient supabaseClient) async {
    _supabaseClient = supabaseClient;
    _currentUser = _supabaseClient.auth.currentUser;
    
    // Listen to auth state changes
    _supabaseClient.auth.onAuthStateChange.listen((data) {
      _currentUser = data.session?.user;
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
      _currentUser = response.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _currentUser = response.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
      _currentUser = null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      rethrow;
    }
  }
}

final authService = AuthService();
