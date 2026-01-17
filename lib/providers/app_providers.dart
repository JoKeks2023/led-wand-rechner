import 'package:flutter_riverpod/flutter_riverpod.dart';
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

// ============================================================================
// DEPRECATED - OLD CHANGENOTIFIER PROVIDERS - REPLACED WITH RIVERPOD
// ============================================================================
// The following code is kept for reference but replaced with Riverpod
// implementation below. This ensures modern state management.

// ============================================================================
// SERVICE PROVIDERS
// ============================================================================

final localDatabaseServiceProvider = Provider((ref) {
  return LocalDatabaseService();
});

final authServiceProvider = Provider((ref) {
  return AuthService();
});

final ledCalculationServiceProvider = Provider((ref) {
  return LEDCalculationService();
});

final dmxServiceProvider = StateProvider((ref) {
  return DMXService();
});

// ============================================================================
// PROJECT MANAGEMENT
// ============================================================================

/// All projects from local database
final projectsProvider = FutureProvider<List<Project>>((ref) async {
  final db = ref.watch(localDatabaseServiceProvider);
  return db.getAllProjects();
});

/// Add new project
final addProjectProvider =
    FutureProvider.family<void, Project>((ref, project) async {
  final db = ref.watch(localDatabaseServiceProvider);
  await db.saveProject(project);
  ref.refresh(projectsProvider);
});

/// Update project
final updateProjectProvider =
    FutureProvider.family<void, Project>((ref, project) async {
  final db = ref.watch(localDatabaseServiceProvider);
  await db.saveProject(project);
  ref.refresh(projectsProvider);
});

/// Delete project
final deleteProjectProvider =
    FutureProvider.family<void, String>((ref, projectId) async {
  final db = ref.watch(localDatabaseServiceProvider);
  await db.deleteProject(projectId);
  ref.refresh(projectsProvider);
});

/// Get single project
final getProjectProvider =
    FutureProvider.family<Project?, String>((ref, projectId) async {
  final db = ref.watch(localDatabaseServiceProvider);
  return db.getProject(projectId);
});

/// Currently selected project
final selectedProjectProvider = StateProvider<String?>((ref) => null);

// ============================================================================
// LED BRANDS & MODELS
// ============================================================================

/// All LED brands
final ledBrandsProvider = FutureProvider<List<LEDBrand>>((ref) async {
  final db = ref.watch(localDatabaseServiceProvider);
  return db.getAllBrands();
});

/// Models for specific brand
final ledModelsForBrandProvider =
    FutureProvider.family<List<LEDModel>, String>((ref, brandId) async {
  final db = ref.watch(localDatabaseServiceProvider);
  return db.getModelsForBrand(brandId);
});

/// Get specific LED model
final ledModelProvider =
    FutureProvider.family<LEDModel?, String>((ref, modelId) async {
  final db = ref.watch(localDatabaseServiceProvider);
  return db.getModel(modelId);
});

/// Add custom LED model
final addCustomModelProvider =
    FutureProvider.family<void, LEDModel>((ref, model) async {
  final db = ref.watch(localDatabaseServiceProvider);
  await db.saveCustomModel(model);
  ref.refresh(ledBrandsProvider);
});

/// Currently selected brand
final selectedBrandProvider = StateProvider<LEDBrand?>((ref) => null);

/// Currently selected model
final selectedModelProvider = StateProvider<LEDModel?>((ref) => null);

// ============================================================================
// LED CALCULATION
// ============================================================================

/// Width in millimeters
final ledWidthMmProvider = StateProvider<double>((ref) => 1000.0);

/// Height in millimeters
final ledHeightMmProvider = StateProvider<double>((ref) => 1000.0);

/// Estimated unit cost in EUR
final unitCostEurProvider = StateProvider<double>((ref) => 100.0);

/// LED Calculation Results
final calculationResultsProvider = Provider<LEDCalculationResults>((ref) {
  final widthMm = ref.watch(ledWidthMmProvider);
  final heightMm = ref.watch(ledHeightMmProvider);
  final model = ref.watch(selectedModelProvider);
  final unitCost = ref.watch(unitCostEurProvider);

  if (model == null) {
    return LEDCalculationResults(
      totalPixels: 0,
      widthPixels: 0,
      heightPixels: 0,
      estimatedCostEur: 0,
      estimatedPowerWatts: 0,
      pixelPitchMm: 0,
      coverage: 0,
    );
  }

  final service = ref.watch(ledCalculationServiceProvider);
  return service.calculate(
    widthMm: widthMm,
    heightMm: heightMm,
    pixelPitchMm: model.pixelPitchMm,
    wattagePerPixelMa: model.wattagePerLedMa,
    unitCostEur: unitCost,
  );
});

/// Export calculation as JSON
final exportCalculationProvider = Provider<Map<String, dynamic>>((ref) {
  final results = ref.watch(calculationResultsProvider);
  final brand = ref.watch(selectedBrandProvider);
  final model = ref.watch(selectedModelProvider);
  final widthMm = ref.watch(ledWidthMmProvider);
  final heightMm = ref.watch(ledHeightMmProvider);

  return {
    'timestamp': DateTime.now().toIso8601String(),
    'brand': brand?.name ?? 'Unknown',
    'model': model?.modelName ?? 'Unknown',
    'dimensions': {'width_mm': widthMm, 'height_mm': heightMm},
    'results': {
      'total_pixels': results.totalPixels,
      'width_pixels': results.widthPixels,
      'height_pixels': results.heightPixels,
      'estimated_cost_eur': results.estimatedCostEur,
      'estimated_power_watts': results.estimatedPowerWatts,
      'pixel_pitch_mm': results.pixelPitchMm,
    },
  };
});

// ============================================================================
// AUTHENTICATION
// ============================================================================

enum AuthStatus { initial, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? email;
  final String? errorMessage;

  AuthState({
    required this.status,
    this.userId,
    this.email,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? email,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Current authentication state
final authStateProvider = StateProvider<AuthState>((ref) {
  return AuthState(status: AuthStatus.initial);
});

/// Sign in with email/password
final signInProvider =
    FutureProvider.family<void, (String, String)>((ref, credentials) async {
  final (email, password) = credentials;
  ref.state = AuthState(status: AuthStatus.initial);

  try {
    final auth = ref.watch(authServiceProvider);
    await auth.signIn(email: email, password: password);
    ref.state = AuthState(
      status: AuthStatus.authenticated,
      email: email,
    );
  } catch (e) {
    ref.state = AuthState(
      status: AuthStatus.error,
      errorMessage: e.toString(),
    );
  }
});

/// Sign up new user
final signUpProvider =
    FutureProvider.family<void, (String, String)>((ref, credentials) async {
  final (email, password) = credentials;
  ref.state = AuthState(status: AuthStatus.initial);

  try {
    final auth = ref.watch(authServiceProvider);
    await auth.signUp(email: email, password: password);
    ref.state = AuthState(
      status: AuthStatus.authenticated,
      email: email,
    );
  } catch (e) {
    ref.state = AuthState(
      status: AuthStatus.error,
      errorMessage: e.toString(),
    );
  }
});

/// Sign out
final signOutProvider = FutureProvider<void>((ref) async {
  try {
    final auth = ref.watch(authServiceProvider);
    await auth.signOut();
    ref.state = AuthState(status: AuthStatus.unauthenticated);
  } catch (e) {
    ref.state = AuthState(
      status: AuthStatus.error,
      errorMessage: e.toString(),
    );
  }
});

// ============================================================================
// DMX PROFILES
// ============================================================================

/// All DMX profiles
final dmxProfilesProvider =
    FutureProvider<Map<String, DMXProfile>>((ref) async {
  final db = ref.watch(localDatabaseServiceProvider);
  return db.getAllDMXProfiles();
});

/// Add or update DMX profile
final addDMXProfileProvider =
    FutureProvider.family<void, DMXProfile>((ref, profile) async {
  final db = ref.watch(localDatabaseServiceProvider);
  await db.saveDMXProfile(profile);
  ref.refresh(dmxProfilesProvider);
});

/// Delete DMX profile
final deleteDMXProfileProvider =
    FutureProvider.family<void, String>((ref, profileId) async {
  final db = ref.watch(localDatabaseServiceProvider);
  await db.deleteDMXProfile(profileId);
  ref.refresh(dmxProfilesProvider);
});

/// Get specific DMX profile
final getDMXProfileProvider =
    FutureProvider.family<DMXProfile?, String>((ref, profileId) async {
  final db = ref.watch(localDatabaseServiceProvider);
  return db.getDMXProfile(profileId);
});

/// Currently selected DMX profile
final selectedDMXProfileProvider = StateProvider<String?>((ref) => null);

// ============================================================================
// DMX UNIVERSES & FIXTURES
// ============================================================================

/// Current DMX universes state
final dmxUniversesProvider = StateProvider<Map<int, DMXUniverse>>((ref) {
  return {};
});

/// Add fixture to DMX universe
final addFixtureToDMXProvider =
    FutureProvider.family<void, (int, Fixture)>((ref, data) async {
  final (universeId, fixture) = data;
  final service = ref.watch(dmxServiceProvider);
  service.addFixture(universeId, fixture);
  ref.refresh(dmxUniversesProvider);
});

/// Remove fixture from DMX universe
final removeFixtureFromDMXProvider =
    FutureProvider.family<void, (int, String)>((ref, data) async {
  final (universeId, fixtureId) = data;
  final service = ref.watch(dmxServiceProvider);
  service.removeFixture(universeId, fixtureId);
  ref.refresh(dmxUniversesProvider);
});

/// Get DMX load for universe (0-100%)
final dmxLoadProvider = Provider.family<double, int>((ref, universeId) {
  final universes = ref.watch(dmxUniversesProvider);
  final universe = universes[universeId];
  if (universe == null) return 0.0;
  return (universe.usedChannels / 512) * 100;
});

// ============================================================================
// GRANDMA3 CONNECTION
// ============================================================================

enum ConnectionStatus { disconnected, connecting, connected, error }

class GrandMA3ConnectionState {
  final ConnectionStatus status;
  final String? errorMessage;
  final String? connectedConsoleIP;

  GrandMA3ConnectionState({
    required this.status,
    this.errorMessage,
    this.connectedConsoleIP,
  });

  GrandMA3ConnectionState copyWith({
    ConnectionStatus? status,
    String? errorMessage,
    String? connectedConsoleIP,
  }) {
    return GrandMA3ConnectionState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      connectedConsoleIP: connectedConsoleIP ?? this.connectedConsoleIP,
    );
  }
}

/// GrandMA3 connection state
final grandMA3ConnectionProvider =
    StateProvider<GrandMA3ConnectionState>((ref) {
  return GrandMA3ConnectionState(status: ConnectionStatus.disconnected);
});

/// Connect to GrandMA3 console
final connectToGrandMA3Provider =
    FutureProvider.family<void, (String, int)>((ref, config) async {
  final (ip, port) = config;
  final notifier = ref.watch(grandMA3ConnectionProvider.notifier);

  notifier.state = GrandMA3ConnectionState(status: ConnectionStatus.connecting);

  try {
    // TODO: Implement actual connection logic
    await Future.delayed(const Duration(seconds: 2));

    notifier.state = GrandMA3ConnectionState(
      status: ConnectionStatus.connected,
      connectedConsoleIP: ip,
    );
  } catch (e) {
    notifier.state = GrandMA3ConnectionState(
      status: ConnectionStatus.error,
      errorMessage: e.toString(),
    );
  }
});

/// Disconnect from GrandMA3
final disconnectFromGrandMA3Provider = FutureProvider<void>((ref) async {
  final notifier = ref.watch(grandMA3ConnectionProvider.notifier);
  notifier.state =
      GrandMA3ConnectionState(status: ConnectionStatus.disconnected);
});

// ============================================================================
// DMX PREFERENCES
// ============================================================================

/// DMX user preferences
final dmxPreferencesProvider = StateProvider<DMXPreferences>((ref) {
  return DMXPreferences(
    connection: ConnectionSettings(
      consoleIp: '192.168.1.100',
      port: 10024,
      connectionTimeoutSeconds: 5,
    ),
    patching: PatchingSettings(
      defaultUniverse: 1,
      autoAddressFixtures: true,
    ),
    stage: StageSettings(
      stageWidthMeters: 10.0,
      stageHeightMeters: 5.0,
      gridSpacingCm: 50,
    ),
    export: ExportSettings(
      format: 'OSC',
      autoExport: false,
    ),
    performance: PerformanceSettings(
      targetFps: 50,
      maxMemoryMb: 512,
    ),
  );
});

// ============================================================================
// UI PREFERENCES
// ============================================================================

/// Theme mode (light/dark/system)
final themeModeProvider = StateProvider<String>((ref) => 'system');

/// Current language
final currentLanguageProvider = StateProvider<String>((ref) => 'de');

/// Toggle between languages
final toggleLanguageProvider = FutureProvider<void>((ref) async {
  final current = ref.watch(currentLanguageProvider).state;
  ref.watch(currentLanguageProvider).state = current == 'de' ? 'en' : 'de';
});

// ============================================================================
// DEPRECATED OLD CHANGENOTIFIER CODE (REPLACED ABOVE)
// ============================================================================

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
  DMXProfile? get currentProfile =>
      _currentProfileId != null ? _profiles[_currentProfileId] : null;
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

  List<DiscoveredConsole> get discoveredConsoles =>
      _discoveryService.discoveredConsoles;
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
