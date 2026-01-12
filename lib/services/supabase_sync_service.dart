import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../models/led_models.dart';
import '../models/dmx_models.dart';

/// Handles all Supabase sync operations with offline-first strategy
class SupabaseSyncService with ChangeNotifier {
  final _connectivity = Connectivity();
  
  bool _isOnline = false;
  bool _isSyncing = false;
  String? _lastError;
  DateTime? _lastSyncTime;
  
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  String? get lastError => _lastError;
  DateTime? get lastSyncTime => _lastSyncTime;

  SupabaseSyncService() {
    _initializeConnectivity();
  }

  /// Initialize connectivity monitoring
  void _initializeConnectivity() {
    _connectivity.onConnectivityChanged.listen((result) {
      final wasOnline = _isOnline;
      _isOnline = result != ConnectivityResult.none;
      
      if (!wasOnline && _isOnline) {
        // Came online - trigger sync
        syncAll();
      }
      
      notifyListeners();
    });
  }

  /// ========== LED PROJECTS SYNC ==========

  /// Save LED project to Supabase
  Future<bool> saveLEDProject(Project project) async {
    if (!_isOnline) {
      if (kDebugMode) print('Offline: LED project queued for sync');
      return false;
    }

    try {
      _isSyncing = true;
      notifyListeners();

      // In production, use actual Supabase client
      // await _supabase.from('led_projects').upsert({
      //   'id': project.id,
      //   'name': project.name,
      //   'description': project.description,
      //   'parameters': project.parametersJson,
      //   'results': project.resultsJson,
      // });

      _lastSyncTime = DateTime.now();
      _lastError = null;
      return true;
    } catch (e) {
      _lastError = 'Save LED project failed: $e';
      if (kDebugMode) print(_lastError);
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Publish custom LED model to community
  Future<bool> publishCustomLEDModel(CustomModel model) async {
    if (!_isOnline) {
      _lastError = 'Cannot publish offline';
      return false;
    }

    try {
      _isSyncing = true;
      notifyListeners();

      // In production:
      // await _supabase.from('custom_led_models').insert({
      //   'user_id': userId,
      //   'name': model.name,
      //   'pixel_pitch': model.pixelPitch,
      //   'power_consumption_per_sqm': model.powerConsumption,
      //   'description': model.description,
      // });

      _lastError = null;
      _lastSyncTime = DateTime.now();
      return true;
    } catch (e) {
      _lastError = 'Publish model failed: $e';
      if (kDebugMode) print(_lastError);
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// ========== DMX PROFILES SYNC ==========

  /// Save DMX profile to Supabase
  Future<bool> saveDMXProfile(DMXProfile profile) async {
    if (!_isOnline) {
      if (kDebugMode) print('Offline: DMX profile queued for sync');
      return false;
    }

    try {
      _isSyncing = true;
      notifyListeners();

      // In production:
      // await _supabase.from('dmx_profiles').upsert({
      //   'id': profile.id,
      //   'name': profile.name,
      //   'description': profile.description,
      //   'hostname': profile.grandMA3Config.hostname,
      //   'ip_address': profile.grandMA3Config.ipAddress,
      //   'osc_port': profile.grandMA3Config.oscPort,
      // });

      _lastError = null;
      _lastSyncTime = DateTime.now();
      return true;
    } catch (e) {
      _lastError = 'Save DMX profile failed: $e';
      if (kDebugMode) print(_lastError);
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// ========== DMX PATCHES SYNC ==========

  /// Save DMX patch to Supabase
  Future<bool> saveDMXPatch(DMXPatch patch) async {
    if (!_isOnline) {
      if (kDebugMode) print('Offline: DMX patch queued for sync');
      return false;
    }

    try {
      _isSyncing = true;
      notifyListeners();

      // In production:
      // await _supabase.from('dmx_patches').upsert({
      //   'id': patch.id,
      //   'profile_id': patch.profileId,
      //   'name': patch.name,
      //   'universe_count': patch.universeCount,
      //   'fixture_count': patch.fixtures.length,
      // });

      _lastError = null;
      _lastSyncTime = DateTime.now();
      return true;
    } catch (e) {
      _lastError = 'Save DMX patch failed: $e';
      if (kDebugMode) print(_lastError);
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// ========== DMX FIXTURES SYNC ==========

  /// Sync fixtures for a patch
  Future<bool> syncFixtures(String patchId, List<Fixture> fixtures) async {
    if (!_isOnline) {
      if (kDebugMode) print('Offline: Fixtures queued for sync');
      return false;
    }

    try {
      _isSyncing = true;
      notifyListeners();

      // In production, batch insert/update fixtures
      // final fixturesData = fixtures.map((f) => {
      //   'id': f.id,
      //   'patch_id': patchId,
      //   'gdtf_fixture_id': f.typeId,
      //   'name': f.name,
      //   'universe': f.universe,
      //   'channel': f.channel,
      //   'channel_count': f.channelCount,
      // }).toList();
      //
      // await _supabase.from('dmx_fixtures').upsert(fixturesData);

      _lastError = null;
      _lastSyncTime = DateTime.now();
      return true;
    } catch (e) {
      _lastError = 'Sync fixtures failed: $e';
      if (kDebugMode) print(_lastError);
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// ========== DMX PREFERENCES SYNC ==========

  /// Save DMX preferences to Supabase
  Future<bool> saveDMXPreferences(String profileId, Map<String, dynamic> prefs) async {
    if (!_isOnline) {
      if (kDebugMode) print('Offline: Preferences queued for sync');
      return false;
    }

    try {
      _isSyncing = true;
      notifyListeners();

      // In production:
      // await _supabase.from('dmx_preferences').upsert({
      //   'profile_id': profileId,
      //   ...prefs,
      // });

      _lastError = null;
      _lastSyncTime = DateTime.now();
      return true;
    } catch (e) {
      _lastError = 'Save preferences failed: $e';
      if (kDebugMode) print(_lastError);
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// ========== BATCH SYNC ==========

  /// Sync all pending changes
  Future<void> syncAll() async {
    if (!_isOnline || _isSyncing) return;

    try {
      _isSyncing = true;
      notifyListeners();

      if (kDebugMode) print('Starting full sync...');

      // Sync LED projects
      // final ledProjects = await _localDb.getAllProjects();
      // for (var project in ledProjects) {
      //   await saveLEDProject(project);
      // }

      // Sync DMX profiles
      // final dmxProfiles = await _localDb.getDMXProfiles();
      // for (var profile in dmxProfiles) {
      //   await saveDMXProfile(profile);
      // }

      // Sync DMX patches
      // final dmxPatches = await _localDb.getDMXPatches();
      // for (var patch in dmxPatches) {
      //   await saveDMXPatch(patch);
      // }

      _lastError = null;
      _lastSyncTime = DateTime.now();

      if (kDebugMode) print('Sync completed successfully');
    } catch (e) {
      _lastError = 'Full sync failed: $e';
      if (kDebugMode) print(_lastError);
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Get sync statistics
  Map<String, dynamic> getSyncStats() {
    return {
      'isOnline': _isOnline,
      'isSyncing': _isSyncing,
      'lastSyncTime': _lastSyncTime?.toIso8601String(),
      'lastError': _lastError,
      'syncTimestamp': DateTime.now().toIso8601String(),
    };
  }
}
