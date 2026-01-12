import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

/// User profile data with metadata
class UserProfile {
  final String id;
  final String? email;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    this.email,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.bio,
    this.preferences = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      email: json['email'],
      username: json['username'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
      preferences: json['preferences'] ?? {},
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  UserProfile copyWith({
    String? username,
    String? fullName,
    String? avatarUrl,
    String? bio,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      id: id,
      email: email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

/// Complete Authentication Service with Supabase Auth
class AuthService with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? _currentUser;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  // Getters
  User? get currentUser => _currentUser;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  String? get userId => _currentUser?.id;
  String? get userEmail => _currentUser?.email;
  bool get isInitialized => _isInitialized;

  /// Initialize auth service
  Future<void> initialize() async {
    try {
      _currentUser = _supabase.auth.currentUser;
      
      if (_currentUser != null) {
        await _loadUserProfile();
      }
      
      // Listen to auth state changes
      _supabase.auth.onAuthStateChange.listen((data) {
        _handleAuthStateChange(data);
      });
      
      _isInitialized = true;
    } catch (e) {
      _error = 'Initialization error: $e';
      if (kDebugMode) print(_error);
    }
    
    notifyListeners();
  }

  /// Handle auth state changes (login/logout)
  void _handleAuthStateChange(AuthState state) {
    _currentUser = state.session?.user;
    
    if (_currentUser != null) {
      _loadUserProfile();
    } else {
      _userProfile = null;
    }
    
    notifyListeners();
  }

  /// Load user profile from database
  Future<void> _loadUserProfile() async {
    if (_currentUser == null) return;

    try {
      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('id', _currentUser!.id)
          .single();

      _userProfile = UserProfile.fromJson(response);
    } catch (e) {
      if (kDebugMode) print('Error loading profile: $e');
      // Profile will be created by trigger on first login
      _userProfile = UserProfile(
        id: _currentUser!.id,
        email: _currentUser!.email,
        preferences: {
          'language': 'de',
          'theme': 'system',
          'notifications_enabled': true,
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Sign up with email & password
  Future<bool> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName ?? email.split('@')[0],
        },
      );

      if (response.user != null) {
        _currentUser = response.user;
        await _loadUserProfile();
        _error = null;
        return true;
      } else {
        _error = 'Sign up failed: No user returned';
        return false;
      }
    } catch (e) {
      _error = 'Sign up failed: $e';
      if (kDebugMode) print(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign in with email & password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUser = response.user;
        await _loadUserProfile();
        _error = null;
        return true;
      } else {
        _error = 'Sign in failed';
        return false;
      }
    } catch (e) {
      _error = 'Sign in failed: $e';
      if (kDebugMode) print(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabase.auth.signOut();
      _currentUser = null;
      _userProfile = null;
      _error = null;
    } catch (e) {
      _error = 'Sign out failed: $e';
      if (kDebugMode) print(_error);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? username,
    String? fullName,
    String? bio,
    String? avatarUrl,
  }) async {
    if (_userProfile == null || _currentUser == null) return false;

    try {
      final updated = _userProfile!.copyWith(
        username: username,
        fullName: fullName,
        bio: bio,
        avatarUrl: avatarUrl,
      );

      await _supabase
          .from('user_profiles')
          .update({
            'username': username,
            'full_name': fullName,
            'bio': bio,
            'avatar_url': avatarUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', _currentUser!.id);

      _userProfile = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Update profile failed: $e';
      if (kDebugMode) print(_error);
      return false;
    }
  }

  /// Update user preferences
  Future<bool> updatePreferences(Map<String, dynamic> preferences) async {
    if (_userProfile == null || _currentUser == null) return false;

    try {
      final merged = {
        ..._userProfile!.preferences,
        ...preferences,
      };

      await _supabase
          .from('user_profiles')
          .update({
            'preferences': merged,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', _currentUser!.id);

      _userProfile = _userProfile!.copyWith(preferences: merged);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Update preferences failed: $e';
      if (kDebugMode) print(_error);
      return false;
    }
  }

  /// Reset password via email
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      _error = 'Password reset failed: $e';
      if (kDebugMode) print(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update password
  Future<bool> updatePassword(String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabase.auth.updateUser(UserAttributes(
        password: newPassword,
      ));
      return true;
    } catch (e) {
      _error = 'Update password failed: $e';
      if (kDebugMode) print(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get user statistics
  Future<Map<String, dynamic>?> getUserStats() async {
    if (_currentUser == null) return null;

    try {
      final response = await _supabase.rpc('count_user_led_projects', params: {
        'user_id': _currentUser!.id,
      });

      final dmxProfiles = await _supabase.rpc('count_user_dmx_profiles', 
          params: {'user_id': _currentUser!.id});

      final fixtures = await _supabase.rpc('count_user_fixtures', 
          params: {'user_id': _currentUser!.id});

      return {
        'ledProjectsCount': response ?? 0,
        'dmxProfilesCount': dmxProfiles ?? 0,
        'fixturesCount': fixtures ?? 0,
      };
    } catch (e) {
      if (kDebugMode) print('Error getting user stats: $e');
      return null;
    }
  }

  /// Delete account (hard delete)
  Future<bool> deleteAccount() async {
    if (_currentUser == null) return false;

    try {
      // Delete user data first (cascade will handle)
      await _supabase
          .from('user_profiles')
          .delete()
          .eq('id', _currentUser!.id);

      // Then delete auth user
      await _supabase.auth.admin.deleteUser(_currentUser!.id);

      _currentUser = null;
      _userProfile = null;
      return true;
    } catch (e) {
      _error = 'Delete account failed: $e';
      if (kDebugMode) print(_error);
      return false;
    }
  }
}
