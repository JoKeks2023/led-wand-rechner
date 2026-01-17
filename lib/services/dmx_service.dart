import 'package:led_wand_app/models/dmx_models.dart';

/// Minimal DMX service stub so the demo build compiles.
class DMXService {
  Future<DMXPatch> createPatch({
    required String userId,
    required String profileId,
    required String patchName,
    String? description,
  }) async {
    return DMXPatch(
        userId: userId,
        profileId: profileId,
        patchName: patchName,
        description: description);
  }

  Future<List<DMXPatch>> getPatches() async => [];
  Future<List<Fixture>> getFixtures(String patchId) async => [];
  Future<List<DMXUniverse>> getUniverses(String patchId) async => [];
  Future<void> addFixture(Fixture fixture) async {}
}
