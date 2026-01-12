import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'dmx_models.g.dart';

// ========== DMX PROFILE (Console Config + Global Settings) ==========
@JsonSerializable()
class DMXProfile {
  final String id;
  final String userId;
  final String profileName;
  final String consoleBrand; // "MA Lighting", "ETC", "Chauvet"
  final String consoleModel; // "GrandMA 3", "GrandMA 2"
  final int universeCount;
  final int channelsPerUniverse;
  final bool isDefault;
  final Map<String, dynamic> settings; // Serialized DMXPreferences
  final DateTime createdAt;
  final DateTime updatedAt;

  DMXProfile({
    String? id,
    required this.userId,
    required this.profileName,
    required this.consoleBrand,
    required this.consoleModel,
    this.universeCount = 4,
    this.channelsPerUniverse = 512,
    this.isDefault = false,
    this.settings = const {},
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory DMXProfile.fromJson(Map<String, dynamic> json) => _$DMXProfileFromJson(json);
  Map<String, dynamic> toJson() => _$DMXProfileToJson(this);

  DMXProfile copyWith({
    String? id,
    String? userId,
    String? profileName,
    String? consoleBrand,
    String? consoleModel,
    int? universeCount,
    int? channelsPerUniverse,
    bool? isDefault,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DMXProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      profileName: profileName ?? this.profileName,
      consoleBrand: consoleBrand ?? this.consoleBrand,
      consoleModel: consoleModel ?? this.consoleModel,
      universeCount: universeCount ?? this.universeCount,
      channelsPerUniverse: channelsPerUniverse ?? this.channelsPerUniverse,
      isDefault: isDefault ?? this.isDefault,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// ========== DMX PATCH / PROJEKT (Fixture-Liste + Stage-Layout) ==========
@JsonSerializable()
class DMXPatch {
  final String id;
  final String userId;
  final String profileId; // Reference to DMXProfile
  final String patchName; // z.B. "Konzert Setup", "Produktion Setup"
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  DMXPatch({
    String? id,
    required this.userId,
    required this.profileId,
    required this.patchName,
    this.description,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory DMXPatch.fromJson(Map<String, dynamic> json) => _$DMXPatchFromJson(json);
  Map<String, dynamic> toJson() => _$DMXPatchToJson(this);

  DMXPatch copyWith({
    String? id,
    String? userId,
    String? profileId,
    String? patchName,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DMXPatch(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      profileId: profileId ?? this.profileId,
      patchName: patchName ?? this.patchName,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// ========== FIXTURE TYPE (von GDTF API) ==========
@JsonSerializable()
class FixtureType {
  final String id;
  final String gdtfId; // Unique GDTF ID
  final String manufacturer;
  final String model;
  final int channels;
  final String category; // "Moving Light", "Wash", "Spot", "LED", etc.
  final String? imageUrl;
  final Map<String, dynamic> gdtfData; // Full GDTF properties
  final DateTime cachedAt;

  FixtureType({
    String? id,
    required this.gdtfId,
    required this.manufacturer,
    required this.model,
    required this.channels,
    required this.category,
    this.imageUrl,
    required this.gdtfData,
    DateTime? cachedAt,
  })  : id = id ?? const Uuid().v4(),
        cachedAt = cachedAt ?? DateTime.now();

  factory FixtureType.fromJson(Map<String, dynamic> json) => _$FixtureTypeFromJson(json);
  Map<String, dynamic> toJson() => _$FixtureTypeToJson(this);

  @override
  String toString() => '$manufacturer $model ($channels ch)';
}

// ========== FIXTURE (einzelne Lampe im Patch) ==========
@JsonSerializable()
class Fixture {
  final String id;
  final String patchId; // Reference to DMXPatch
  final String fixtureTypeId; // Reference to FixtureType
  final String fixtureName; // z.B. "Moving Light 01"
  final int fixtureNumber; // z.B. 1 (für schnelle Referenz)
  final String universe; // "U1", "U2", etc.
  final int startChannel; // 1-512
  final int endChannel; // calculated from channels
  final double? xPosition; // Stage position in meters
  final double? yPosition;
  final double? zPosition; // Height (optional)
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Fixture({
    String? id,
    required this.patchId,
    required this.fixtureTypeId,
    required this.fixtureName,
    required this.fixtureNumber,
    required this.universe,
    required this.startChannel,
    required this.endChannel,
    this.xPosition,
    this.yPosition,
    this.zPosition,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Fixture.fromJson(Map<String, dynamic> json) => _$FixtureFromJson(json);
  Map<String, dynamic> toJson() => _$FixtureToJson(this);

  int get channelCount => endChannel - startChannel + 1;
  String get channelRange => '$startChannel-$endChannel';
  String get fullAddress => '$universe/$channelRange';

  Fixture copyWith({
    String? id,
    String? patchId,
    String? fixtureTypeId,
    String? fixtureName,
    int? fixtureNumber,
    String? universe,
    int? startChannel,
    int? endChannel,
    double? xPosition,
    double? yPosition,
    double? zPosition,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Fixture(
      id: id ?? this.id,
      patchId: patchId ?? this.patchId,
      fixtureTypeId: fixtureTypeId ?? this.fixtureTypeId,
      fixtureName: fixtureName ?? this.fixtureName,
      fixtureNumber: fixtureNumber ?? this.fixtureNumber,
      universe: universe ?? this.universe,
      startChannel: startChannel ?? this.startChannel,
      endChannel: endChannel ?? this.endChannel,
      xPosition: xPosition ?? this.xPosition,
      yPosition: yPosition ?? this.yPosition,
      zPosition: zPosition ?? this.zPosition,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// ========== DMX UNIVERSE (Channel-Grid) ==========
@JsonSerializable()
class DMXUniverse {
  final String id;
  final String patchId;
  final String universeName; // "Universe 1", "U1"
  final int universeNumber; // 1-4
  final List<int> channelOccupancy; // 512 slots: 0=free, else=fixture-hash

  DMXUniverse({
    String? id,
    required this.patchId,
    required this.universeName,
    required this.universeNumber,
    List<int>? channelOccupancy,
  })  : id = id ?? const Uuid().v4(),
        channelOccupancy = channelOccupancy ?? List.filled(512, 0);

  factory DMXUniverse.fromJson(Map<String, dynamic> json) => _$DMXUniverseFromJson(json);
  Map<String, dynamic> toJson() => _$DMXUniverseToJson(this);

  bool isChannelFree(int channel) =>
      channel > 0 && channel <= 512 && channelOccupancy[channel - 1] == 0;

  List<int> findFreeChannels(int needed) {
    List<int> free = [];
    for (int i = 0; i < 512; i++) {
      if (channelOccupancy[i] == 0) {
        free.add(i + 1);
        if (free.length == needed) break;
      }
    }
    return free.length == needed ? free : [];
  }

  int getOccupancyPercentage() =>
      ((channelOccupancy.where((c) => c != 0).length) * 100 / 512).round();
}

// ========== STAGE SETTINGS ==========
@JsonSerializable()
class StageSettings {
  final String id;
  final String patchId;
  final double stageWidthM;
  final double stageHeightM;
  final double stageDepthM;
  final bool showGrid;
  final bool showFixtureLabels;
  final bool showChannelNumbers;
  final double gridSize; // Raster-Größe in Metern
  final double fixtureIconSize; // Pixel
  final double zoomLevel;
  final int pixelsPerMeter; // für Rendering

  StageSettings({
    String? id,
    required this.patchId,
    this.stageWidthM = 10,
    this.stageHeightM = 8,
    this.stageDepthM = 5,
    this.showGrid = true,
    this.showFixtureLabels = true,
    this.showChannelNumbers = false,
    this.gridSize = 1.0,
    this.fixtureIconSize = 24,
    this.zoomLevel = 1.0,
    this.pixelsPerMeter = 50,
  }) : id = id ?? const Uuid().v4();

  factory StageSettings.fromJson(Map<String, dynamic> json) => _$StageSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$StageSettingsToJson(this);

  StageSettings copyWith({
    String? id,
    String? patchId,
    double? stageWidthM,
    double? stageHeightM,
    double? stageDepthM,
    bool? showGrid,
    bool? showFixtureLabels,
    bool? showChannelNumbers,
    double? gridSize,
    double? fixtureIconSize,
    double? zoomLevel,
    int? pixelsPerMeter,
  }) {
    return StageSettings(
      id: id ?? this.id,
      patchId: patchId ?? this.patchId,
      stageWidthM: stageWidthM ?? this.stageWidthM,
      stageHeightM: stageHeightM ?? this.stageHeightM,
      stageDepthM: stageDepthM ?? this.stageDepthM,
      showGrid: showGrid ?? this.showGrid,
      showFixtureLabels: showFixtureLabels ?? this.showFixtureLabels,
      showChannelNumbers: showChannelNumbers ?? this.showChannelNumbers,
      gridSize: gridSize ?? this.gridSize,
      fixtureIconSize: fixtureIconSize ?? this.fixtureIconSize,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      pixelsPerMeter: pixelsPerMeter ?? this.pixelsPerMeter,
    );
  }
}

// ========== GRANDMA 3 CONNECTION CONFIG ==========
@JsonSerializable()
class GrandMA3Config {
  final String id;
  final String profileId;
  final String ipAddress;
  final int oscPort;
  final String? username;
  final String? password;
  final bool autoDiscoveryEnabled;
  final int discoveryTimeoutSeconds;
  final bool isConnected;
  final DateTime? lastConnected;

  GrandMA3Config({
    String? id,
    required this.profileId,
    required this.ipAddress,
    this.oscPort = 7000,
    this.username,
    this.password,
    this.autoDiscoveryEnabled = true,
    this.discoveryTimeoutSeconds = 5,
    this.isConnected = false,
    this.lastConnected,
  }) : id = id ?? const Uuid().v4();

  factory GrandMA3Config.fromJson(Map<String, dynamic> json) => _$GrandMA3ConfigFromJson(json);
  Map<String, dynamic> toJson() => _$GrandMA3ConfigToJson(this);

  GrandMA3Config copyWith({
    String? id,
    String? profileId,
    String? ipAddress,
    int? oscPort,
    String? username,
    String? password,
    bool? autoDiscoveryEnabled,
    int? discoveryTimeoutSeconds,
    bool? isConnected,
    DateTime? lastConnected,
  }) {
    return GrandMA3Config(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      ipAddress: ipAddress ?? this.ipAddress,
      oscPort: oscPort ?? this.oscPort,
      username: username ?? this.username,
      password: password ?? this.password,
      autoDiscoveryEnabled: autoDiscoveryEnabled ?? this.autoDiscoveryEnabled,
      discoveryTimeoutSeconds: discoveryTimeoutSeconds ?? this.discoveryTimeoutSeconds,
      isConnected: isConnected ?? this.isConnected,
      lastConnected: lastConnected ?? this.lastConnected,
    );
  }
}

// ========== CONNECTION HISTORY ==========
@JsonSerializable()
class ConnectionHistory {
  final String id;
  final String userId;
  final String ipAddress;
  final int port;
  final DateTime connectedAt;
  final DateTime? disconnectedAt;
  final String? errorMessage;

  ConnectionHistory({
    String? id,
    required this.userId,
    required this.ipAddress,
    this.port = 7000,
    DateTime? connectedAt,
    this.disconnectedAt,
    this.errorMessage,
  })  : id = id ?? const Uuid().v4(),
        connectedAt = connectedAt ?? DateTime.now();

  factory ConnectionHistory.fromJson(Map<String, dynamic> json) =>
      _$ConnectionHistoryFromJson(json);
  Map<String, dynamic> toJson() => _$ConnectionHistoryToJson(this);
}
