import 'package:hive_flutter/hive_flutter.dart';
import '../models/led_models.dart';
import 'hive_adapters.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance =
      LocalDatabaseService._internal();

  factory LocalDatabaseService() {
    return _instance;
  }

  LocalDatabaseService._internal();

  late Box<LEDBrand> _brandBox;
  late Box<LEDModel> _modelBox;
  late Box<ModelVariant> _variantBox;
  late Box<Project> _projectBox;
  late Box<CustomModel> _customModelBox;
  late Box<Map> _syncMetadataBox;

  Future<void> initialize() async {
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(LEDBrandAdapter());
    Hive.registerAdapter(LEDModelAdapter());
    Hive.registerAdapter(ModelVariantAdapter());
    Hive.registerAdapter(ProjectAdapter());
    Hive.registerAdapter(CustomModelAdapter());

    // Open Boxes
    _brandBox = await Hive.openBox<LEDBrand>(ledBrandsBoxName);
    _modelBox = await Hive.openBox<LEDModel>(ledModelsBoxName);
    _variantBox = await Hive.openBox<ModelVariant>(modelVariantsBoxName);
    _projectBox = await Hive.openBox<Project>(projectsBoxName);
    _customModelBox = await Hive.openBox<CustomModel>(customModelsBoxName);
    _syncMetadataBox = await Hive.openBox<Map>(syncMetadataBoxName);
  }

  // ========== LED BRANDS ==========
  Future<void> saveBrand(LEDBrand brand) async {
    await _brandBox.put(brand.id, brand);
  }

  Future<void> saveBrands(List<LEDBrand> brands) async {
    final Map<String, LEDBrand> brandMap = {
      for (var brand in brands) brand.id: brand
    };
    await _brandBox.putAll(brandMap);
  }

  LEDBrand? getBrand(String id) => _brandBox.get(id);

  List<LEDBrand> getAllBrands() => _brandBox.values.toList();

  Future<void> deleteBrand(String id) async => _brandBox.delete(id);

  // ========== LED MODELS ==========
  Future<void> saveModel(LEDModel model) async {
    await _modelBox.put(model.id, model);
  }

  Future<void> saveModels(List<LEDModel> models) async {
    final Map<String, LEDModel> modelMap = {
      for (var model in models) model.id: model
    };
    await _modelBox.putAll(modelMap);
  }

  LEDModel? getModel(String id) => _modelBox.get(id);

  List<LEDModel> getModelsByBrand(String brandId) {
    return _modelBox.values.where((model) => model.brandId == brandId).toList();
  }

  List<LEDModel> getAllModels() => _modelBox.values.toList();

  Future<void> deleteModel(String id) async => _modelBox.delete(id);

  // ========== MODEL VARIANTS ==========
  Future<void> saveVariant(ModelVariant variant) async {
    await _variantBox.put(variant.id, variant);
  }

  Future<void> saveVariants(List<ModelVariant> variants) async {
    final Map<String, ModelVariant> variantMap = {
      for (var variant in variants) variant.id: variant
    };
    await _variantBox.putAll(variantMap);
  }

  ModelVariant? getVariant(String id) => _variantBox.get(id);

  List<ModelVariant> getVariantsByModel(String modelId) {
    return _variantBox.values
        .where((variant) => variant.modelId == modelId)
        .toList();
  }

  List<ModelVariant> getAllVariants() => _variantBox.values.toList();

  // ========== PROJECTS ==========
  Future<void> saveProject(Project project) async {
    await _projectBox.put(project.id, project);
  }

  Future<void> saveProjects(List<Project> projects) async {
    final Map<String, Project> projectMap = {
      for (var project in projects) project.id: project
    };
    await _projectBox.putAll(projectMap);
  }

  Project? getProject(String id) => _projectBox.get(id);

  List<Project> getProjectsByUser(String userId) {
    return _projectBox.values
        .where((project) => project.userId == userId)
        .toList();
  }

  List<Project> getAllProjects() => _projectBox.values.toList();

  Future<void> deleteProject(String id) async => _projectBox.delete(id);

  Future<void> updateProject(Project project) async {
    await _projectBox.put(project.id, project);
  }

  // ========== CUSTOM MODELS ==========
  Future<void> saveCustomModel(CustomModel model) async {
    await _customModelBox.put(model.id, model);
  }

  Future<void> saveCustomModels(List<CustomModel> models) async {
    final Map<String, CustomModel> modelMap = {
      for (var model in models) model.id: model
    };
    await _customModelBox.putAll(modelMap);
  }

  CustomModel? getCustomModel(String id) => _customModelBox.get(id);

  List<CustomModel> getCustomModelsByUser(String userId) {
    return _customModelBox.values
        .where((model) => model.userId == userId)
        .toList();
  }

  List<CustomModel> getPublishedCustomModels() {
    return _customModelBox.values
        .where((model) => model.isPublished == true)
        .toList();
  }

  List<CustomModel> getAllCustomModels() => _customModelBox.values.toList();

  Future<void> deleteCustomModel(String id) async => _customModelBox.delete(id);

  Future<void> updateCustomModel(CustomModel model) async {
    await _customModelBox.put(model.id, model);
  }

  // ========== SYNC METADATA ==========
  Future<void> saveSyncMetadata(
      String entityId, String entityType, Map<String, dynamic> metadata) async {
    final key = '${entityType}_$entityId';
    await _syncMetadataBox.put(key, metadata);
  }

  Map? getSyncMetadata(String entityId, String entityType) {
    final key = '${entityType}_$entityId';
    return _syncMetadataBox.get(key);
  }

  Future<void> clearSyncMetadata(String entityId, String entityType) async {
    final key = '${entityType}_$entityId';
    await _syncMetadataBox.delete(key);
  }

  // ========== BULK OPERATIONS ==========
  Future<void> clearAllData() async {
    await _brandBox.clear();
    await _modelBox.clear();
    await _variantBox.clear();
    await _projectBox.clear();
    await _customModelBox.clear();
    await _syncMetadataBox.clear();
  }

  Future<void> clearAllUserData(String userId) async {
    // Delete user projects
    final userProjects = getProjectsByUser(userId);
    for (var project in userProjects) {
      await deleteProject(project.id);
    }

    // Delete user custom models
    final userCustomModels = getCustomModelsByUser(userId);
    for (var model in userCustomModels) {
      await deleteCustomModel(model.id);
    }
  }

  // ========== CACHE CHECK ==========
  bool hasCachedData() {
    return _brandBox.isNotEmpty && _modelBox.isNotEmpty;
  }

  int getCachedBrandCount() => _brandBox.length;
  int getCachedModelCount() => _modelBox.length;
  int getCachedProjectCount() => _projectBox.length;
}
