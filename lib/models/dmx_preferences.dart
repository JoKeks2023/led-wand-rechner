import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'dmx_preferences.g.dart';

// ========== CONNECTION SETTINGS ==========
@JsonSerializable()
class ConnectionSettings {
  final bool autoDiscoveryEnabled;
  final int discoveryTimeoutSeconds; // 3-10
  final bool manualIpOverride;
  final String? manualIpAddress;
  final int manualPort;
  final String? username;
  final String? password;
  final int reconnectMaxAttempts;
  final int reconnectBaseDelay; // ms
  final bool enableHeartbeat;
  final int heartbeatInterval; // seconds

  const ConnectionSettings({
    this.autoDiscoveryEnabled = true,
    this.discoveryTimeoutSeconds = 5,
    this.manualIpOverride = false,
    this.manualIpAddress,
    this.manualPort = 7000,
    this.username,
    this.password,
    this.reconnectMaxAttempts = 10,
    this.reconnectBaseDelay = 1000,
    this.enableHeartbeat = true,
    this.heartbeatInterval = 30,
  });

  factory ConnectionSettings.fromJson(Map<String, dynamic> json) =>
      _$ConnectionSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$ConnectionSettingsToJson(this);

  ConnectionSettings copyWith({
    bool? autoDiscoveryEnabled,
    int? discoveryTimeoutSeconds,
    bool? manualIpOverride,
    String? manualIpAddress,
    int? manualPort,
    String? username,
    String? password,
    int? reconnectMaxAttempts,
    int? reconnectBaseDelay,
    bool? enableHeartbeat,
    int? heartbeatInterval,
  }) {
    return ConnectionSettings(
      autoDiscoveryEnabled: autoDiscoveryEnabled ?? this.autoDiscoveryEnabled,
      discoveryTimeoutSeconds: discoveryTimeoutSeconds ?? this.discoveryTimeoutSeconds,
      manualIpOverride: manualIpOverride ?? this.manualIpOverride,
      manualIpAddress: manualIpAddress ?? this.manualIpAddress,
      manualPort: manualPort ?? this.manualPort,
      username: username ?? this.username,
      password: password ?? this.password,
      reconnectMaxAttempts: reconnectMaxAttempts ?? this.reconnectMaxAttempts,
      reconnectBaseDelay: reconnectBaseDelay ?? this.reconnectBaseDelay,
      enableHeartbeat: enableHeartbeat ?? this.enableHeartbeat,
      heartbeatInterval: heartbeatInterval ?? this.heartbeatInterval,
    );
  }
}

// ========== PATCHING DEFAULTS ==========
@JsonSerializable()
class PatchingDefaults {
  final int defaultUniverseCount;
  final int defaultChannelsPerUniverse;
  final int defaultStartChannel;
  final String channelNumbering; // "1-512" oder "0-511"
  final String autoFindStrategy; // "sequential", "consolidate", "spread"
  final bool autoNameFixtures;
  final String namePattern; // "{type}-{number}"

  const PatchingDefaults({
    this.defaultUniverseCount = 4,
    this.defaultChannelsPerUniverse = 512,
    this.defaultStartChannel = 1,
    this.channelNumbering = '1-512',
    this.autoFindStrategy = 'sequential',
    this.autoNameFixtures = true,
    this.namePattern = '{type}-{number}',
  });

  factory PatchingDefaults.fromJson(Map<String, dynamic> json) =>
      _$PatchingDefaultsFromJson(json);
  Map<String, dynamic> toJson() => _$PatchingDefaultsToJson(this);

  PatchingDefaults copyWith({
    int? defaultUniverseCount,
    int? defaultChannelsPerUniverse,
    int? defaultStartChannel,
    String? channelNumbering,
    String? autoFindStrategy,
    bool? autoNameFixtures,
    String? namePattern,
  }) {
    return PatchingDefaults(
      defaultUniverseCount: defaultUniverseCount ?? this.defaultUniverseCount,
      defaultChannelsPerUniverse: defaultChannelsPerUniverse ?? this.defaultChannelsPerUniverse,
      defaultStartChannel: defaultStartChannel ?? this.defaultStartChannel,
      channelNumbering: channelNumbering ?? this.channelNumbering,
      autoFindStrategy: autoFindStrategy ?? this.autoFindStrategy,
      autoNameFixtures: autoNameFixtures ?? this.autoNameFixtures,
      namePattern: namePattern ?? this.namePattern,
    );
  }
}

// ========== STAGE DEFAULTS ==========
@JsonSerializable()
class StageDefaults {
  final double defaultStageWidthM;
  final double defaultStageHeightM;
  final double defaultStageDepthM;
  final double defaultGridSize;
  final double defaultFixtureIconSize;
  final bool showGridByDefault;
  final bool showLabelsbyDefault;
  final bool showChannelNumbersByDefault;
  final int defaultPixelsPerMeter;
  final Map<String, String> fixtureTypeColors; // type -> hex color

  const StageDefaults({
    this.defaultStageWidthM = 10,
    this.defaultStageHeightM = 8,
    this.defaultStageDepthM = 5,
    this.defaultGridSize = 1.0,
    this.defaultFixtureIconSize = 24,
    this.showGridByDefault = true,
    this.showLabelsbyDefault = true,
    this.showChannelNumbersByDefault = false,
    this.defaultPixelsPerMeter = 50,
    this.fixtureTypeColors = const {
      'Moving Light': '#FF6B00',
      'Wash': '#0066FF',
      'Spot': '#FF0000',
      'LED': '#00FF00',
      'Strobe': '#FFFF00',
      'Effect': '#FF00FF',
    },
  });

  factory StageDefaults.fromJson(Map<String, dynamic> json) =>
      _$StageDefaultsFromJson(json);
  Map<String, dynamic> toJson() => _$StageDefaultsToJson(this);

  StageDefaults copyWith({
    double? defaultStageWidthM,
    double? defaultStageHeightM,
    double? defaultStageDepthM,
    double? defaultGridSize,
    double? defaultFixtureIconSize,
    bool? showGridByDefault,
    bool? showLabelsbyDefault,
    bool? showChannelNumbersByDefault,
    int? defaultPixelsPerMeter,
    Map<String, String>? fixtureTypeColors,
  }) {
    return StageDefaults(
      defaultStageWidthM: defaultStageWidthM ?? this.defaultStageWidthM,
      defaultStageHeightM: defaultStageHeightM ?? this.defaultStageHeightM,
      defaultStageDepthM: defaultStageDepthM ?? this.defaultStageDepthM,
      defaultGridSize: defaultGridSize ?? this.defaultGridSize,
      defaultFixtureIconSize: defaultFixtureIconSize ?? this.defaultFixtureIconSize,
      showGridByDefault: showGridByDefault ?? this.showGridByDefault,
      showLabelsbyDefault: showLabelsbyDefault ?? this.showLabelsbyDefault,
      showChannelNumbersByDefault:
          showChannelNumbersByDefault ?? this.showChannelNumbersByDefault,
      defaultPixelsPerMeter: defaultPixelsPerMeter ?? this.defaultPixelsPerMeter,
      fixtureTypeColors: fixtureTypeColors ?? this.fixtureTypeColors,
    );
  }
}

// ========== EXPORT SETTINGS ==========
@JsonSerializable()
class ExportDefaults {
  final bool exportToMA3;
  final bool exportToJSON;
  final bool exportToCSV;
  final String ma3Version; // "3.0", "2.9", etc.
  final bool includeStagePositions;
  final bool includeFixtureNotes;
  final bool includeProperties;
  final String csvDelimiter;
  final bool csvIncludeHeaders;

  const ExportDefaults({
    this.exportToMA3 = true,
    this.exportToJSON = true,
    this.exportToCSV = true,
    this.ma3Version = '3.0',
    this.includeStagePositions = true,
    this.includeFixtureNotes = true,
    this.includeProperties = true,
    this.csvDelimiter = ',',
    this.csvIncludeHeaders = true,
  });

  factory ExportDefaults.fromJson(Map<String, dynamic> json) =>
      _$ExportDefaultsFromJson(json);
  Map<String, dynamic> toJson() => _$ExportDefaultsToJson(this);

  ExportDefaults copyWith({
    bool? exportToMA3,
    bool? exportToJSON,
    bool? exportToCSV,
    String? ma3Version,
    bool? includeStagePositions,
    bool? includeFixtureNotes,
    bool? includeProperties,
    String? csvDelimiter,
    bool? csvIncludeHeaders,
  }) {
    return ExportDefaults(
      exportToMA3: exportToMA3 ?? this.exportToMA3,
      exportToJSON: exportToJSON ?? this.exportToJSON,
      exportToCSV: exportToCSV ?? this.exportToCSV,
      ma3Version: ma3Version ?? this.ma3Version,
      includeStagePositions: includeStagePositions ?? this.includeStagePositions,
      includeFixtureNotes: includeFixtureNotes ?? this.includeFixtureNotes,
      includeProperties: includeProperties ?? this.includeProperties,
      csvDelimiter: csvDelimiter ?? this.csvDelimiter,
      csvIncludeHeaders: csvIncludeHeaders ?? this.csvIncludeHeaders,
    );
  }
}

// ========== PERFORMANCE SETTINGS ==========
@JsonSerializable()
class PerformanceSettings {
  final int maxFixturesInMemory;
  final bool enableVirtualScroll;
  final int cacheSize; // MB
  final bool enableHardwareAcceleration;
  final int fixtureRenderBatchSize;

  const PerformanceSettings({
    this.maxFixturesInMemory = 500,
    this.enableVirtualScroll = true,
    this.cacheSize = 256,
    this.enableHardwareAcceleration = true,
    this.fixtureRenderBatchSize = 50,
  });

  factory PerformanceSettings.fromJson(Map<String, dynamic> json) =>
      _$PerformanceSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$PerformanceSettingsToJson(this);

  PerformanceSettings copyWith({
    int? maxFixturesInMemory,
    bool? enableVirtualScroll,
    int? cacheSize,
    bool? enableHardwareAcceleration,
    int? fixtureRenderBatchSize,
  }) {
    return PerformanceSettings(
      maxFixturesInMemory: maxFixturesInMemory ?? this.maxFixturesInMemory,
      enableVirtualScroll: enableVirtualScroll ?? this.enableVirtualScroll,
      cacheSize: cacheSize ?? this.cacheSize,
      enableHardwareAcceleration: enableHardwareAcceleration ?? this.enableHardwareAcceleration,
      fixtureRenderBatchSize: fixtureRenderBatchSize ?? this.fixtureRenderBatchSize,
    );
  }
}

// ========== COMPLETE DMX PREFERENCES ==========
@JsonSerializable()
class DMXPreferences {
  final String id;
  final String profileId;
  final ConnectionSettings connectionSettings;
  final PatchingDefaults patchingDefaults;
  final StageDefaults stageDefaults;
  final ExportDefaults exportDefaults;
  final PerformanceSettings performanceSettings;
  final DateTime createdAt;
  final DateTime updatedAt;

  DMXPreferences({
    String? id,
    required this.profileId,
    ConnectionSettings? connectionSettings,
    PatchingDefaults? patchingDefaults,
    StageDefaults? stageDefaults,
    ExportDefaults? exportDefaults,
    PerformanceSettings? performanceSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        connectionSettings = connectionSettings ?? const ConnectionSettings(),
        patchingDefaults = patchingDefaults ?? const PatchingDefaults(),
        stageDefaults = stageDefaults ?? const StageDefaults(),
        exportDefaults = exportDefaults ?? const ExportDefaults(),
        performanceSettings = performanceSettings ?? const PerformanceSettings(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory DMXPreferences.fromJson(Map<String, dynamic> json) => _$DMXPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$DMXPreferencesToJson(this);

  DMXPreferences copyWith({
    String? id,
    String? profileId,
    ConnectionSettings? connectionSettings,
    PatchingDefaults? patchingDefaults,
    StageDefaults? stageDefaults,
    ExportDefaults? exportDefaults,
    PerformanceSettings? performanceSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DMXPreferences(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      connectionSettings: connectionSettings ?? this.connectionSettings,
      patchingDefaults: patchingDefaults ?? this.patchingDefaults,
      stageDefaults: stageDefaults ?? this.stageDefaults,
      exportDefaults: exportDefaults ?? this.exportDefaults,
      performanceSettings: performanceSettings ?? this.performanceSettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
