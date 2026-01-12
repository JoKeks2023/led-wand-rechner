import 'package:flutter/material.dart';
import '../models/led_models.dart';
import '../models/dmx_models.dart';
import '../models/dmx_preferences.dart';
import '../services/local_database_service.dart';
import '../services/supabase_sync_service.dart';
import '../services/auth_service.dart';
import '../services/led_calculation_service.dart';
import '../services/gdtf_service.dart';
import '../services/grandma3_discovery_service.dart';
import '../services/grandma3_connection_manager.dart';
import '../services/dmx_service.dart';

class ProjectsProvider extends ChangeNotifier {
  final LocalDatabaseService _localDb = LocalDatabaseService();
  final SupabaseSyncService _syncService = SupabaseSyncService();

  List<Project> _projects = [];
  Project? _currentProject;
  bool _isLoading = false;
  String? _error;

  List<Project> get projects => _projects;
  Project? get currentProject => _currentProject;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _projects = _localDb.getAllProjects();
      if (_projects.isNotEmpty) {
        _currentProject = _projects.first;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createProject(String name, {String? description}) async {
    try {
      final project = Project(
        userId: authService.userId ?? 'local_user',
        name: name,
        description: description,
        parametersJson: {},
      );

      await _syncService.saveProject(project);
      await _localDb.saveProject(project);

      _projects.add(project);
      _currentProject = project;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      await _syncService.saveProject(project);
      await _localDb.updateProject(project);

      final index = _projects.indexWhere((p) => p.id == project.id);
      if (index >= 0) {
        _projects[index] = project;
      }

      if (_currentProject?.id == project.id) {
        _currentProject = project;
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await _localDb.deleteProject(projectId);
      _projects.removeWhere((p) => p.id == projectId);

      if (_currentProject?.id == projectId) {
        _currentProject = _projects.isNotEmpty ? _projects.first : null;
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void setCurrentProject(Project project) {
    _currentProject = project;
    notifyListeners();
  }

  Future<void> reloadProjects() async {
    _isLoading = true;
    notifyListeners();

    try {
      _projects = _localDb.getAllProjects();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}

class LEDDataProvider extends ChangeNotifier {
  final LocalDatabaseService _localDb = LocalDatabaseService();
  final SupabaseSyncService _syncService = SupabaseSyncService();

  List<LEDBrand> _brands = [];
  List<LEDModel> _models = [];
  List<ModelVariant> _variants = [];
  List<CustomModel> _customModels = [];
  bool _isLoading = false;
  String? _error;

  List<LEDBrand> get brands => _brands;
  List<LEDModel> get models => _models;
  List<LEDModel> get filteredModels => _filteredModels;
  List<ModelVariant> get variants => _variants;
  List<CustomModel> get customModels => _customModels;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? _selectedBrandId;
  List<LEDModel> _filteredModels = [];

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load from local DB first
      _brands = _localDb.getAllBrands();
      _models = _localDb.getAllModels();
      _variants = _localDb.getAllVariants();

      if (authService.isAuthenticated) {
        _customModels = _localDb.getCustomModelsByUser(authService.userId!);
      }

      // Sync from Supabase if online
      await _syncService.syncLEDBrands();
      await _syncService.syncLEDModels();
      await _syncService.syncModelVariants();

      // Reload from local DB after sync
      _brands = _localDb.getAllBrands();
      _models = _localDb.getAllModels();
      _variants = _localDb.getAllVariants();

      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectBrand(String? brandId) {
    _selectedBrandId = brandId;
    _filteredModels = brandId == null
        ? []
        : _models.where((m) => m.brandId == brandId).toList();
    notifyListeners();
  }

  List<ModelVariant> getVariantsForModel(String modelId) {
    return _variants.where((v) => v.modelId == modelId).toList();
  }

  LEDBrand? getBrand(String brandId) {
    try {
      return _brands.firstWhere((b) => b.id == brandId);
    } catch (e) {
      return null;
    }
  }

  LEDModel? getModel(String modelId) {
    try {
      return _models.firstWhere((m) => m.id == modelId);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveCustomModel(CustomModel model) async {
    try {
      await _syncService.saveCustomModel(model);
      await _localDb.saveCustomModel(model);

      final index = _customModels.indexWhere((m) => m.id == model.id);
      if (index >= 0) {
        _customModels[index] = model;
      } else {
        _customModels.add(model);
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteCustomModel(String modelId) async {
    try {
      await _localDb.deleteCustomModel(modelId);
      _customModels.removeWhere((m) => m.id == modelId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> publishCustomModel(
    String modelId,
    String description,
  ) async {
    try {
      final model = _customModels.firstWhere((m) => m.id == modelId);
      await _syncService.publishCommunityModel(
        customModel: model,
        description: description,
      );
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}

class CalculationProvider extends ChangeNotifier {
  LEDCalculationResults? _currentResults;
  LEDCalculationResults? get currentResults => _currentResults;

  void calculate({
    required double widthMm,
    required double heightMm,
    required double pixelPitchMm,
    required double wattagePerLedMa,
    required double? modulePriceEur,
    required double? installationCostEur,
    required double? serviceWarrantyCostEur,
    required double? shippingCostEur,
    required int? numberOfModules,
  }) {
    _currentResults = ledCalculationService.calculateAll(
      widthMm: widthMm,
      heightMm: heightMm,
      pixelPitchMm: pixelPitchMm,
      wattagePerLedMa: wattagePerLedMa,
      modulePriceEur: modulePriceEur,
      installationCostEur: installationCostEur,
      serviceWarrantyCostEur: serviceWarrantyCostEur,
      shippingCostEur: shippingCostEur,
      numberOfModules: numberOfModules,
    );
    notifyListeners();
  }

  void clear() {
    _currentResults = null;
    notifyListeners();
  }
}

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => authService.isAuthenticated;
  String? get userEmail => authService.userEmail;

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await authService.signUp(email: email, password: password);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await authService.signIn(email: email, password: password);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await authService.signOut();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}

class ConnectivityProvider extends ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  void updateStatus(bool online) {
    if (_isOnline != online) {
      _isOnline = online;
      notifyListeners();
    }
  }
}

// ========== DMX PROVIDERS ==========

class DMXProfilesProvider extends ChangeNotifier {
  final LocalDatabaseService _localDb = LocalDatabaseService();
  
  Map<String, DMXProfile> _profiles = {};
  String? _currentProfileId;
  bool _isLoading = false;
  String? _error;

  Map<String, DMXProfile> get profiles => _profiles;
  DMXProfile? get currentProfile => _currentProfileId != null ? _profiles[_currentProfileId] : null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProfiles() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load from local database (future: sync with Supabase)
      _profiles = {};
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void setCurrentProfile(String profileId) {
    if (_profiles.containsKey(profileId)) {
      _currentProfileId = profileId;
      notifyListeners();
    }
  }

  void createProfile(String name, {String? description}) {
    final profile = DMXProfile(
      name: name,
      description: description,
      grandMA3Config: GrandMA3Config(),
    );

    _profiles[profile.id] = profile;
    if (_currentProfileId == null) {
      _currentProfileId = profile.id;
    }
    notifyListeners();
  }
}

class DMXServiceProvider extends ChangeNotifier {
  final DMXService _dmxService = DMXService();
  
  DMXService get service => _dmxService;

  List<DMXPatch> getPatches(String profileId) {
    return _dmxService.patches.values
        .where((p) => p.profileId == profileId)
        .toList();
  }

  DMXPatch? getPatch(String patchId) {
    return _dmxService.patches[patchId];
  }

  Future<void> addFixtureToPatch({
    required String patchId,
    required FixtureType fixtureType,
    String? customName,
  }) async {
    final success = await _dmxService.addFixture(
      patchId: patchId,
      fixtureType: fixtureType,
      customName: customName,
    );
    
    if (success) {
      notifyListeners();
    }
  }

  void removeFixture(String patchId, String fixtureId) {
    _dmxService.removeFixture(patchId: patchId, fixtureId: fixtureId);
    notifyListeners();
  }
}

class GDTFServiceProvider extends ChangeNotifier {
  final GDTFService _gdtfService = GDTFService();
  
  GDTFService get service => _gdtfService;

  List<GDTFFixture> get fixtures => _gdtfService.fixtures;
  bool get isLoading => _gdtfService.isLoading;
  String? get lastError => _gdtfService.lastError;

  Future<void> loadFixtures({bool force = false}) async {
    await _gdtfService.fetchAllFixtures(force: force);
    notifyListeners();
  }

  List<GDTFFixture> search(String query) {
    return _gdtfService.search(query);
  }

  List<String> getManufacturers() {
    return _gdtfService.getManufacturers();
  }

  List<String> getCategories() {
    return _gdtfService.getCategories();
  }
}

class GrandMA3DiscoveryProvider extends ChangeNotifier {
  final GrandMA3DiscoveryService _discoveryService = GrandMA3DiscoveryService();
  
  GrandMA3DiscoveryService get service => _discoveryService;

  List<DiscoveredConsole> get discoveredConsoles => _discoveryService.discoveredConsoles;
  bool get isDiscovering => _discoveryService.isDiscovering;
  String? get lastError => _discoveryService.lastError;

  Future<void> startDiscovery({int timeoutSeconds = 5}) async {
    await _discoveryService.discover(timeoutSeconds: timeoutSeconds);
    notifyListeners();
  }

  void clearDiscovered() {
    _discoveryService.clearDiscovered();
    notifyListeners();
  }
}

class GrandMA3ConnectionProvider extends ChangeNotifier {
  GrandMA3ConnectionManager? _connectionManager;
  
  GrandMA3ConnectionManager? get connectionManager => _connectionManager;
  bool get isConnected => _connectionManager?.isConnected ?? false;
  String? get lastError => _connectionManager?.lastError;

  void initializeConnection(GrandMA3Config config) {
    _connectionManager?.dispose();
    _connectionManager = GrandMA3ConnectionManager(config);
    _connectionManager?.addListener(notifyListeners);
  }

  Future<void> connect() async {
    if (_connectionManager != null) {
      await _connectionManager!.connect();
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    if (_connectionManager != null) {
      await _connectionManager!.disconnect();
      notifyListeners();
    }
  }

  Future<void> sendCommand(String command, {List<dynamic>? args}) async {
    if (_connectionManager != null) {
      await _connectionManager!.sendCommand(command, args: args);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _connectionManager?.dispose();
    super.dispose();
  }
}

class DMXPreferencesProvider extends ChangeNotifier {
  Map<String, DMXPreferences> _preferences = {};
  String? _currentProfileId;

  Map<String, DMXPreferences> get preferences => _preferences;

  DMXPreferences? getPreferences(String profileId) {
    return _preferences[profileId];
  }

  void setPreferences(DMXPreferences prefs) {
    _preferences[prefs.profileId] = prefs;
    _currentProfileId = prefs.profileId;
    notifyListeners();
  }

  void updateConnectionSettings(String profileId, ConnectionSettings settings) {
    final prefs = _preferences[profileId];
    if (prefs != null) {
      _preferences[profileId] = prefs.copyWith(
        connectionSettings: settings,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void updatePatchingDefaults(String profileId, PatchingDefaults defaults) {
    final prefs = _preferences[profileId];
    if (prefs != null) {
      _preferences[profileId] = prefs.copyWith(
        patchingDefaults: defaults,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void updateStageDefaults(String profileId, StageDefaults defaults) {
    final prefs = _preferences[profileId];
    if (prefs != null) {
      _preferences[profileId] = prefs.copyWith(
        stageDefaults: defaults,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }
}
