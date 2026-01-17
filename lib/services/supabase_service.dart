class SupabaseService {
  Future<void> initialize() async {}

  String? get currentUserId => null;
}

class SupabaseSyncService {
  Future<void> saveProject(dynamic _) async {}
  Future<void> deleteProject(String id) async {}
  Future<void> saveCustomModel(dynamic _) async {}
  Future<void> publishCustomModel(String id) async {}
  Future<void> syncLEDBrands() async {}
  Future<void> syncLEDModels() async {}
  Future<void> syncModelVariants() async {}
  Future<void> saveDMXProfile(dynamic _) async {}
  Future<void> saveDMXPatch(dynamic _) async {}
  Future<void> saveFixtures(List<dynamic> _) async {}
  Future<void> publishCommunityModel(dynamic _) async {}
}
