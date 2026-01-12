import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/led_models.dart';
import 'local_database_service.dart';
import 'auth_service.dart';

class SupabaseSyncService {
  static final SupabaseSyncService _instance = SupabaseSyncService._internal();

  factory SupabaseSyncService() {
    return _instance;
  }

  SupabaseSyncService._internal();

  late final SupabaseClient _supabaseClient;
  late final Connectivity _connectivity;
  late final LocalDatabaseService _localDb;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  Future<void> initialize(
    SupabaseClient supabaseClient,
    LocalDatabaseService localDb,
  ) async {
    _supabaseClient = supabaseClient;
    _localDb = localDb;
    _connectivity = Connectivity();

    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((result) {
      _isOnline = result != ConnectivityResult.none;
      if (_isOnline) {
        _syncAllData();
      }
    });

    // Initial connectivity check
    final result = await _connectivity.checkConnectivity();
    _isOnline = result != ConnectivityResult.none;

    // Initial sync if online
    if (_isOnline) {
      await _syncAllData();
    }
  }

  // ========== SYNC LED BRANDS & MODELS ==========
  Future<void> syncLEDBrands() async {
    if (!_isOnline) return;

    try {
      final brands = await _supabaseClient
          .from('led_brands')
          .select()
          .then((data) => (data as List).map((b) => LEDBrand.fromJson(b)).toList());

      await _localDb.saveBrands(brands);
    } catch (e) {
      print('Error syncing LED brands: $e');
    }
  }

  Future<void> syncLEDModels() async {
    if (!_isOnline) return;

    try {
      final models = await _supabaseClient
          .from('led_models')
          .select()
          .then((data) => (data as List).map((m) => LEDModel.fromJson(m)).toList());

      await _localDb.saveModels(models);
    } catch (e) {
      print('Error syncing LED models: $e');
    }
  }

  Future<void> syncModelVariants() async {
    if (!_isOnline) return;

    try {
      final variants = await _supabaseClient
          .from('model_variants')
          .select()
          .then((data) => (data as List).map((v) => ModelVariant.fromJson(v)).toList());

      await _localDb.saveVariants(variants);
    } catch (e) {
      print('Error syncing model variants: $e');
    }
  }

  // ========== SYNC PROJECTS ==========
  Future<void> syncProjects() async {
    if (!_isOnline || !authService.isAuthenticated) return;

    try {
      final userId = authService.userId!;
      final projects = await _supabaseClient
          .from('projects')
          .select()
          .eq('user_id', userId)
          .then((data) => (data as List).map((p) => Project.fromJson(p)).toList());

      await _localDb.saveProjects(projects);

      // Upload any local projects that aren't in cloud
      final localProjects = _localDb.getProjectsByUser(userId);
      for (var localProject in localProjects) {
        if (!projects.any((p) => p.id == localProject.id)) {
          await _uploadProject(localProject);
        }
      }
    } catch (e) {
      print('Error syncing projects: $e');
    }
  }

  Future<void> _uploadProject(Project project) async {
    if (!_isOnline) return;

    try {
      await _supabaseClient.from('projects').upsert(project.toJson());
    } catch (e) {
      print('Error uploading project: $e');
    }
  }

  // ========== SYNC CUSTOM MODELS ==========
  Future<void> syncCustomModels() async {
    if (!_isOnline || !authService.isAuthenticated) return;

    try {
      final userId = authService.userId!;
      final customModels = await _supabaseClient
          .from('custom_models')
          .select()
          .eq('user_id', userId)
          .then((data) => (data as List).map((m) => CustomModel.fromJson(m)).toList());

      await _localDb.saveCustomModels(customModels);

      // Upload any local custom models
      final localCustomModels = _localDb.getCustomModelsByUser(userId);
      for (var localModel in localCustomModels) {
        if (!customModels.any((m) => m.id == localModel.id)) {
          await _uploadCustomModel(localModel);
        }
      }
    } catch (e) {
      print('Error syncing custom models: $e');
    }
  }

  Future<void> _uploadCustomModel(CustomModel model) async {
    if (!_isOnline) return;

    try {
      await _supabaseClient.from('custom_models').upsert(model.toJson());
    } catch (e) {
      print('Error uploading custom model: $e');
    }
  }

  // ========== SAVE PROJECT (with sync) ==========
  Future<void> saveProject(Project project) async {
    // Always save locally first
    await _localDb.saveProject(project);

    // Then sync to cloud if online and authenticated
    if (_isOnline && authService.isAuthenticated) {
      await _uploadProject(project);
    }
  }

  // ========== SAVE CUSTOM MODEL (with sync) ==========
  Future<void> saveCustomModel(CustomModel model) async {
    // Always save locally first
    await _localDb.saveCustomModel(model);

    // Then sync to cloud if online and authenticated
    if (_isOnline && authService.isAuthenticated) {
      await _uploadCustomModel(model);
    }
  }

  // ========== PUBLISH COMMUNITY MODEL ==========
  Future<void> publishCommunityModel({
    required CustomModel customModel,
    required String description,
  }) async {
    if (!_isOnline || !authService.isAuthenticated) {
      throw Exception('Must be online and authenticated to publish community models');
    }

    try {
      final communityModel = {
        'user_id': authService.userId,
        'original_custom_model_id': customModel.id,
        'model_name': customModel.modelName,
        'brand_name': customModel.brandIdOrCustom,
        'specs_json': customModel.specsJson,
        'description': description,
        'votes': 0,
        'published_at': DateTime.now().toIso8601String(),
      };

      await _supabaseClient.from('community_models').insert(communityModel);

      // Mark custom model as published
      final updatedModel = customModel.copyWith(isPublished: true);
      await saveCustomModel(updatedModel);
    } catch (e) {
      print('Error publishing community model: $e');
      rethrow;
    }
  }

  // ========== FULL SYNC ==========
  Future<void> _syncAllData() async {
    if (!_isOnline) return;

    try {
      // Sync public data first (brands, models, variants)
      await Future.wait([
        syncLEDBrands(),
        syncLEDModels(),
        syncModelVariants(),
      ]);

      // Then sync user-specific data if authenticated
      if (authService.isAuthenticated) {
        await Future.wait([
          syncProjects(),
          syncCustomModels(),
        ]);
      }
    } catch (e) {
      print('Error during full sync: $e');
    }
  }

  Future<void> manualSync() async {
    await _syncAllData();
  }

  // ========== CONNECTIVITY CHECK ==========
  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _isOnline = result != ConnectivityResult.none;
    return _isOnline;
  }
}

final supabaseSyncService = SupabaseSyncService();
