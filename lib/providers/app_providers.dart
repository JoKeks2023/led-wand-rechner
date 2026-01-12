import 'package:flutter/material.dart';
import '../models/led_models.dart';
import '../services/local_database_service.dart';
import '../services/supabase_sync_service.dart';
import '../services/auth_service.dart';
import '../services/led_calculation_service.dart';

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
