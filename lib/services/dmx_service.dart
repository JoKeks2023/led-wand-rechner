import 'package:flutter/foundation.dart';
import '../models/dmx_models.dart';

/// Main DMX service for patch management
class DMXService with ChangeNotifier {
  Map<String, DMXPatch> _patches = {};
  Map<String, DMXUniverse> _universes = {};
  String? _currentPatchId;

  Map<String, DMXPatch> get patches => _patches;
  Map<String, DMXUniverse> get universes => _universes;
  DMXPatch? get currentPatch => 
      _currentPatchId != null ? _patches[_currentPatchId] : null;

  /// Create new patch
  DMXPatch createPatch({
    required String profileId,
    required String name,
    required int universeCount,
    Map<String, String>? metadata,
  }) {
    final patch = DMXPatch(
      id: _generateId(),
      profileId: profileId,
      name: name,
      universeCount: universeCount,
      metadata: metadata ?? {},
    );

    _patches[patch.id] = patch;
    _setCurrentPatch(patch.id);
    
    // Initialize universes
    for (int i = 1; i <= universeCount; i++) {
      _universes['${patch.id}_U$i'] = DMXUniverse(
        id: '${patch.id}_U$i',
        universeNumber: i,
        patchId: patch.id,
      );
    }

    notifyListeners();
    return patch;
  }

  /// Add fixture to patch
  Future<bool> addFixture({
    required String patchId,
    required FixtureType fixtureType,
    String? customName,
    int? channelCount,
    int? startUniverse,
    int? startChannel,
  }) async {
    final patch = _patches[patchId];
    if (patch == null) return false;

    final channels = channelCount ?? fixtureType.defaultChannels;
    int? assignedUniverse = startUniverse;
    int? assignedChannel = startChannel;

    // Auto-find free channels if not specified
    if (assignedUniverse == null || assignedChannel == null) {
      final freeSlot = _findFreeChannels(patchId, channels);
      if (freeSlot == null) {
        return false; // No space available
      }
      assignedUniverse = freeSlot['universe'] as int;
      assignedChannel = freeSlot['channel'] as int;
    }

    final fixture = Fixture(
      id: _generateId(),
      typeId: fixtureType.id,
      name: customName ?? '${fixtureType.name}-${patch.fixtures.length + 1}',
      universe: assignedUniverse,
      channel: assignedChannel,
      channelCount: channels,
      properties: {},
    );

    // Add to patch
    patch.fixtures.add(fixture);

    // Update universe occupancy
    _updateUniverseOccupancy(patchId, assignedUniverse, fixture);

    notifyListeners();
    return true;
  }

  /// Remove fixture from patch
  void removeFixture({
    required String patchId,
    required String fixtureId,
  }) {
    final patch = _patches[patchId];
    if (patch == null) return;

    final fixture = patch.fixtures.firstWhere(
      (f) => f.id == fixtureId,
      orElse: () => throw Exception('Fixture not found'),
    );

    // Update universe occupancy
    final universeKey = '${patchId}_U${fixture.universe}';
    final universe = _universes[universeKey];
    if (universe != null) {
      for (int i = fixture.channel; i < fixture.channel + fixture.channelCount; i++) {
        universe.occupied[i] = false;
      }
    }

    patch.fixtures.removeWhere((f) => f.id == fixtureId);
    notifyListeners();
  }

  /// Update fixture properties
  void updateFixture({
    required String patchId,
    required String fixtureId,
    String? name,
    Map<String, dynamic>? properties,
    double? stageX,
    double? stageY,
  }) {
    final patch = _patches[patchId];
    if (patch == null) return;

    final index = patch.fixtures.indexWhere((f) => f.id == fixtureId);
    if (index == -1) return;

    final fixture = patch.fixtures[index];
    final updated = fixture.copyWith(
      name: name,
      properties: properties ?? fixture.properties,
      stageX: stageX,
      stageY: stageY,
    );

    patch.fixtures[index] = updated;
    notifyListeners();
  }

  /// Get all fixtures for a patch
  List<Fixture> getFixtures(String patchId) {
    return _patches[patchId]?.fixtures ?? [];
  }

  /// Get universe status
  Map<String, dynamic> getUniverseStatus(String patchId, int universeNumber) {
    final universeKey = '${patchId}_U$universeNumber';
    final universe = _universes[universeKey];

    if (universe == null) return {};

    final occupied = universe.occupied.values.where((v) => v).length;
    final free = 512 - occupied;

    return {
      'universeNumber': universeNumber,
      'occupiedChannels': occupied,
      'freeChannels': free,
      'occupancyPercent': (occupied / 512 * 100).toStringAsFixed(1),
    };
  }

  /// Get free channels
  List<int> getFreeChannels(String patchId, int universeNumber, int count) {
    final universeKey = '${patchId}_U$universeNumber';
    final universe = _universes[universeKey];

    if (universe == null) return [];

    final free = <int>[];
    for (int i = 1; i <= 512; i++) {
      if (universe.occupied[i] != true) {
        free.add(i);
        if (free.length >= count) break;
      }
    }

    return free;
  }

  /// Export patch to different formats
  Future<String> exportPatch({
    required String patchId,
    required String format, // 'json', 'csv', 'ma3'
  }) async {
    final patch = _patches[patchId];
    if (patch == null) throw Exception('Patch not found');

    switch (format.toLowerCase()) {
      case 'json':
        return _exportToJson(patch);
      case 'csv':
        return _exportToCsv(patch);
      case 'ma3':
        return await _exportToMA3(patch);
      default:
        throw Exception('Unknown export format: $format');
    }
  }

  /// Set current patch
  void _setCurrentPatch(String patchId) {
    if (_patches.containsKey(patchId)) {
      _currentPatchId = patchId;
      notifyListeners();
    }
  }

  /// Find free channels for new fixture
  Map<String, int>? _findFreeChannels(String patchId, int neededChannels) {
    // Try to find consecutive free channels
    for (int u = 1; u <= (_patches[patchId]?.universeCount ?? 4); u++) {
      final universeKey = '${patchId}_U$u';
      final universe = _universes[universeKey];

      if (universe == null) continue;

      for (int startCh = 1; startCh <= 512 - neededChannels + 1; startCh++) {
        bool isFree = true;
        for (int i = startCh; i < startCh + neededChannels; i++) {
          if (universe.occupied[i] ?? false) {
            isFree = false;
            break;
          }
        }

        if (isFree) {
          return {
            'universe': u,
            'channel': startCh,
          };
        }
      }
    }

    return null;
  }

  /// Update universe occupancy
  void _updateUniverseOccupancy(
      String patchId, int universeNumber, Fixture fixture) {
    final universeKey = '${patchId}_U$universeNumber';
    final universe = _universes[universeKey];

    if (universe != null) {
      for (int i = fixture.channel;
          i < fixture.channel + fixture.channelCount;
          i++) {
        universe.occupied[i] = true;
      }
    }
  }

  /// Export to JSON
  String _exportToJson(DMXPatch patch) {
    final data = {
      'patchName': patch.name,
      'universeCount': patch.universeCount,
      'fixtureCount': patch.fixtures.length,
      'fixtures': patch.fixtures
          .map((f) => {
                'id': f.id,
                'name': f.name,
                'universe': f.universe,
                'channel': f.channel,
                'channelCount': f.channelCount,
                'stageX': f.stageX,
                'stageY': f.stageY,
              })
          .toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };

    // Return JSON string (use json package in production)
    return data.toString();
  }

  /// Export to CSV
  String _exportToCsv(DMXPatch patch) {
    final lines = [
      'Fixture ID,Name,Universe,Channel,Channel Count,Stage X,Stage Y',
    ];

    for (var fixture in patch.fixtures) {
      lines.add(
        '${fixture.id},${fixture.name},${fixture.universe},'
        '${fixture.channel},${fixture.channelCount},'
        '${fixture.stageX},${fixture.stageY}',
      );
    }

    return lines.join('\n');
  }

  /// Export to MA3 format
  Future<String> _exportToMA3(DMXPatch patch) async {
    // Simplified MA3 export
    // In production, would generate binary MA3 format
    final data = StringBuffer();

    data.writeln('// GrandMA3 Fixture List Export');
    data.writeln('// Patch: ${patch.name}');
    data.writeln('// Generated: ${DateTime.now().toIso8601String()}');
    data.writeln('');

    for (var fixture in patch.fixtures) {
      data.writeln('Fixture ${fixture.name}');
      data.writeln('  Universe: ${fixture.universe}');
      data.writeln('  Channel: ${fixture.channel}');
      data.writeln('  Count: ${fixture.channelCount}');
    }

    return data.toString();
  }

  /// Helper to generate unique IDs
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Clear all data
  void clear() {
    _patches.clear();
    _universes.clear();
    _currentPatchId = null;
    notifyListeners();
  }
}
