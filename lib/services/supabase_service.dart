import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/led_models.dart';
import '../models/dmx_models.dart';

/// Database service for all Supabase interactions
class SupabaseService with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? _error;
  String? get error => _error;

  // ========== LED BRANDS & MODELS ==========

  /// Get all LED brands
  Future<List<LEDBrand>> getLEDBrands() async {
    try {
      final response = await _supabase.from('led_brands').select();
      
      return (response as List)
          .map((json) => LEDBrand(
                id: json['id'] ?? '',
                name: json['name'] ?? '',
                manufacturer: json['manufacturer'] ?? '',
                logoUrl: json['logo_url'],
              ))
          .toList();
    } catch (e) {
      _error = 'Error loading LED brands: $e';
      if (kDebugMode) print(_error);
      return [];
    }
  }

  /// Get all LED models for a brand
  Future<List<LEDModel>> getLEDModels(String brandId) async {
    try {
      final response = await _supabase
          .from('led_models')
          .select()
          .eq('brand_id', brandId);

      return (response as List)
          .map((json) => LEDModel(
                id: json['id'] ?? '',
                brandId: json['brand_id'] ?? '',
                name: json['name'] ?? '',
                modelNumber: json['model_number'],
                pixelPitch: (json['pixel_pitch'] as num).toDouble(),
                maxBrightness: json['max_brightness'],
                powerConsumptionPerSqm: 
                    (json['power_consumption_per_sqm'] as num?)?.toDouble(),
                resolution169: json['resolution_16_9'],
                typicalUseCase: json['typical_use_case'],
              ))
          .toList();
    } catch (e) {
      _error = 'Error loading LED models: $e';
      if (kDebugMode) print(_error);
      return [];
    }
  }

  /// Search LED models
  Future<List<LEDModel>> searchLEDModels(String query) async {
    try {
      final response = await _supabase
          .from('led_models')
          .select('*, led_brands!inner(id, name)')
          .ilike('name', '%$query%')
          .limit(20);

      return (response as List)
          .map((json) => LEDModel(
                id: json['id'] ?? '',
                brandId: json['brand_id'] ?? '',
                name: json['name'] ?? '',
                pixelPitch: (json['pixel_pitch'] as num).toDouble(),
              ))
          .toList();
    } catch (e) {
      _error = 'Error searching LED models: $e';
      if (kDebugMode) print(_error);
      return [];
    }
  }

  // ========== LED PROJECTS ==========

  /// Get user's LED projects
  Future<List<Project>> getUserLEDProjects(String userId) async {
    try {
      final response = await _supabase
          .from('led_projects')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Project(
                id: json['id'] ?? '',
                userId: json['user_id'] ?? '',
                name: json['name'] ?? '',
                description: json['description'],
                parametersJson: json['parameters'] ?? {},
              ))
          .toList();
    } catch (e) {
      _error = 'Error loading LED projects: $e';
      if (kDebugMode) print(_error);
      return [];
    }
  }

  /// Save LED project
  Future<bool> saveLEDProject(Project project) async {
    try {
      await _supabase.from('led_projects').upsert({
        'id': project.id,
        'user_id': project.userId,
        'name': project.name,
        'description': project.description,
        'parameters': project.parametersJson,
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      _error = 'Error saving LED project: $e';
      if (kDebugMode) print(_error);
      return false;
    }
  }

  /// Delete LED project
  Future<bool> deleteLEDProject(String projectId) async {
    try {
      await _supabase.from('led_projects').delete().eq('id', projectId);
      return true;
    } catch (e) {
      _error = 'Error deleting LED project: $e';
      if (kDebugMode) print(_error);
      return false;
    }
  }

  // ========== DMX PROFILES ==========

  /// Get user's DMX profiles
  Future<List<DMXProfile>> getUserDMXProfiles(String userId) async {
    try {
      final response = await _supabase
          .from('dmx_profiles')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => DMXProfile(
                id: json['id'] ?? '',
                userId: json['user_id'] ?? '',
                name: json['name'] ?? '',
                description: json['description'],
                grandMA3Config: GrandMA3Config(
                  hostname: json['hostname'],
                  ipAddress: json['ip_address'] ?? '',
                  oscPort: json['osc_port'] ?? 7000,
                  version: json['grandma_version'],
                ),
              ))
          .toList();
    } catch (e) {
      _error = 'Error loading DMX profiles: $e';
      if (kDebugMode) print(_error);
      return [];
    }
  }

  /// Save DMX profile
  Future<bool> saveDMXProfile(DMXProfile profile, String userId) async {
    try {
      await _supabase.from('dmx_profiles').upsert({
        'id': profile.id,
        'user_id': userId,
        'name': profile.name,
        'description': profile.description,
        'hostname': profile.grandMA3Config.hostname,
        'ip_address': profile.grandMA3Config.ipAddress,
        'osc_port': profile.grandMA3Config.oscPort,
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      _error = 'Error saving DMX profile: $e';
      if (kDebugMode) print(_error);
      return false;
    }
  }

  // ========== DMX PATCHES ==========

  /// Get patches for a profile
  Future<List<DMXPatch>> getDMXPatches(String profileId) async {
    try {
      final response = await _supabase
          .from('dmx_patches')
          .select()
          .eq('profile_id', profileId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => DMXPatch(
                id: json['id'] ?? '',
                profileId: json['profile_id'] ?? '',
                name: json['name'] ?? '',
                universeCount: json['universe_count'] ?? 4,
              ))
          .toList();
    } catch (e) {
      _error = 'Error loading DMX patches: $e';
      if (kDebugMode) print(_error);
      return [];
    }
  }

  /// Save DMX patch
  Future<bool> saveDMXPatch(DMXPatch patch) async {
    try {
      await _supabase.from('dmx_patches').upsert({
        'id': patch.id,
        'profile_id': patch.profileId,
        'name': patch.name,
        'description': patch.description,
        'universe_count': patch.universeCount,
        'fixture_count': patch.fixtures.length,
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      _error = 'Error saving DMX patch: $e';
      if (kDebugMode) print(_error);
      return false;
    }
  }

  // ========== DMX FIXTURES ==========

  /// Get fixtures for a patch
  Future<List<Fixture>> getDMXFixtures(String patchId) async {
    try {
      final response = await _supabase
          .from('dmx_fixtures')
          .select()
          .eq('patch_id', patchId);

      return (response as List)
          .map((json) => Fixture(
                id: json['id'] ?? '',
                typeId: json['gdtf_fixture_id'] ?? '',
                name: json['name'] ?? '',
                universe: json['universe'] ?? 1,
                channel: json['channel'] ?? 1,
                channelCount: json['channel_count'] ?? 1,
              ))
          .toList();
    } catch (e) {
      _error = 'Error loading fixtures: $e';
      if (kDebugMode) print(_error);
      return [];
    }
  }

  /// Bulk insert/update fixtures
  Future<bool> syncFixtures(String patchId, List<Fixture> fixtures) async {
    try {
      final fixturesData = fixtures
          .map((f) => {
                'id': f.id,
                'patch_id': patchId,
                'gdtf_fixture_id': f.typeId,
                'name': f.name,
                'universe': f.universe,
                'channel': f.channel,
                'channel_count': f.channelCount,
                'stage_x': f.stageX,
                'stage_y': f.stageY,
                'properties': f.properties,
              })
          .toList();

      await _supabase.from('dmx_fixtures').upsert(fixturesData);
      return true;
    } catch (e) {
      _error = 'Error syncing fixtures: $e';
      if (kDebugMode) print(_error);
      return false;
    }
  }

  // ========== CUSTOM LED MODELS (Community) ==========

  /// Get community LED models
  Future<List<CustomModel>> getCommunityLEDModels({int limit = 50}) async {
    try {
      final response = await _supabase
          .from('custom_led_models')
          .select()
          .order('downloads', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => CustomModel(
                id: json['id'] ?? '',
                userId: json['user_id'] ?? '',
                name: json['name'] ?? '',
                pixelPitch: (json['pixel_pitch'] as num).toDouble(),
                powerConsumption: (json['power_consumption_per_sqm'] as num?)?.toDouble(),
                description: json['description'],
                downloads: json['downloads'] ?? 0,
              ))
          .toList();
    } catch (e) {
      _error = 'Error loading community models: $e';
      if (kDebugMode) print(_error);
      return [];
    }
  }

  /// Publish custom LED model
  Future<bool> publishCustomLEDModel(
    String userId,
    String name,
    double pixelPitch,
    double? powerConsumption,
    String? description,
  ) async {
    try {
      await _supabase.from('custom_led_models').insert({
        'user_id': userId,
        'name': name,
        'pixel_pitch': pixelPitch,
        'power_consumption_per_sqm': powerConsumption,
        'description': description,
        'downloads': 0,
      });
      return true;
    } catch (e) {
      _error = 'Error publishing model: $e';
      if (kDebugMode) print(_error);
      return false;
    }
  }

  // ========== GDTF FIXTURES ==========

  /// Get GDTF fixtures by category
  Future<List<Map<String, dynamic>>> getGDTFFixtures({
    String? category,
    String? manufacturer,
    int limit = 100,
  }) async {
    try {
      var query = _supabase.from('gdtf_fixtures').select();

      if (category != null) {
        query = query.eq('category', category);
      }

      if (manufacturer != null) {
        query = query.eq('manufacturer', manufacturer);
      }

      final response = await query.limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _error = 'Error loading GDTF fixtures: $e';
      if (kDebugMode) print(_error);
      return [];
    }
  }

  // ========== STAGE SETTINGS ==========

  /// Save stage settings
  Future<bool> saveStageSettings(String profileId, Map<String, dynamic> settings) async {
    try {
      await _supabase.from('stage_settings').upsert({
        'profile_id': profileId,
        ...settings,
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      _error = 'Error saving stage settings: $e';
      if (kDebugMode) print(_error);
      return false;
    }
  }

  /// Clear all errors
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
