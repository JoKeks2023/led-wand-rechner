// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dmx_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConnectionSettings _$ConnectionSettingsFromJson(Map<String, dynamic> json) =>
    ConnectionSettings(
      autoDiscoveryEnabled: json['autoDiscoveryEnabled'] as bool? ?? true,
      discoveryTimeoutSeconds:
          (json['discoveryTimeoutSeconds'] as num?)?.toInt() ?? 5,
      manualIpOverride: json['manualIpOverride'] as bool? ?? false,
      manualIpAddress: json['manualIpAddress'] as String?,
      manualPort: (json['manualPort'] as num?)?.toInt() ?? 7000,
      username: json['username'] as String?,
      password: json['password'] as String?,
      reconnectMaxAttempts:
          (json['reconnectMaxAttempts'] as num?)?.toInt() ?? 10,
      reconnectBaseDelay: (json['reconnectBaseDelay'] as num?)?.toInt() ?? 1000,
      enableHeartbeat: json['enableHeartbeat'] as bool? ?? true,
      heartbeatInterval: (json['heartbeatInterval'] as num?)?.toInt() ?? 30,
    );

Map<String, dynamic> _$ConnectionSettingsToJson(ConnectionSettings instance) =>
    <String, dynamic>{
      'autoDiscoveryEnabled': instance.autoDiscoveryEnabled,
      'discoveryTimeoutSeconds': instance.discoveryTimeoutSeconds,
      'manualIpOverride': instance.manualIpOverride,
      'manualIpAddress': instance.manualIpAddress,
      'manualPort': instance.manualPort,
      'username': instance.username,
      'password': instance.password,
      'reconnectMaxAttempts': instance.reconnectMaxAttempts,
      'reconnectBaseDelay': instance.reconnectBaseDelay,
      'enableHeartbeat': instance.enableHeartbeat,
      'heartbeatInterval': instance.heartbeatInterval,
    };

PatchingDefaults _$PatchingDefaultsFromJson(Map<String, dynamic> json) =>
    PatchingDefaults(
      defaultUniverseCount:
          (json['defaultUniverseCount'] as num?)?.toInt() ?? 4,
      defaultChannelsPerUniverse:
          (json['defaultChannelsPerUniverse'] as num?)?.toInt() ?? 512,
      defaultStartChannel: (json['defaultStartChannel'] as num?)?.toInt() ?? 1,
      channelNumbering: json['channelNumbering'] as String? ?? '1-512',
      autoFindStrategy: json['autoFindStrategy'] as String? ?? 'sequential',
      autoNameFixtures: json['autoNameFixtures'] as bool? ?? true,
      namePattern: json['namePattern'] as String? ?? '{type}-{number}',
    );

Map<String, dynamic> _$PatchingDefaultsToJson(PatchingDefaults instance) =>
    <String, dynamic>{
      'defaultUniverseCount': instance.defaultUniverseCount,
      'defaultChannelsPerUniverse': instance.defaultChannelsPerUniverse,
      'defaultStartChannel': instance.defaultStartChannel,
      'channelNumbering': instance.channelNumbering,
      'autoFindStrategy': instance.autoFindStrategy,
      'autoNameFixtures': instance.autoNameFixtures,
      'namePattern': instance.namePattern,
    };

StageDefaults _$StageDefaultsFromJson(Map<String, dynamic> json) =>
    StageDefaults(
      defaultStageWidthM:
          (json['defaultStageWidthM'] as num?)?.toDouble() ?? 10,
      defaultStageHeightM:
          (json['defaultStageHeightM'] as num?)?.toDouble() ?? 8,
      defaultStageDepthM: (json['defaultStageDepthM'] as num?)?.toDouble() ?? 5,
      defaultGridSize: (json['defaultGridSize'] as num?)?.toDouble() ?? 1.0,
      defaultFixtureIconSize:
          (json['defaultFixtureIconSize'] as num?)?.toDouble() ?? 24,
      showGridByDefault: json['showGridByDefault'] as bool? ?? true,
      showLabelsbyDefault: json['showLabelsbyDefault'] as bool? ?? true,
      showChannelNumbersByDefault:
          json['showChannelNumbersByDefault'] as bool? ?? false,
      defaultPixelsPerMeter:
          (json['defaultPixelsPerMeter'] as num?)?.toInt() ?? 50,
      fixtureTypeColors:
          (json['fixtureTypeColors'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as String),
              ) ??
              const {
                'Moving Light': '#FF6B00',
                'Wash': '#0066FF',
                'Spot': '#FF0000',
                'LED': '#00FF00',
                'Strobe': '#FFFF00',
                'Effect': '#FF00FF'
              },
    );

Map<String, dynamic> _$StageDefaultsToJson(StageDefaults instance) =>
    <String, dynamic>{
      'defaultStageWidthM': instance.defaultStageWidthM,
      'defaultStageHeightM': instance.defaultStageHeightM,
      'defaultStageDepthM': instance.defaultStageDepthM,
      'defaultGridSize': instance.defaultGridSize,
      'defaultFixtureIconSize': instance.defaultFixtureIconSize,
      'showGridByDefault': instance.showGridByDefault,
      'showLabelsbyDefault': instance.showLabelsbyDefault,
      'showChannelNumbersByDefault': instance.showChannelNumbersByDefault,
      'defaultPixelsPerMeter': instance.defaultPixelsPerMeter,
      'fixtureTypeColors': instance.fixtureTypeColors,
    };

ExportDefaults _$ExportDefaultsFromJson(Map<String, dynamic> json) =>
    ExportDefaults(
      exportToMA3: json['exportToMA3'] as bool? ?? true,
      exportToJSON: json['exportToJSON'] as bool? ?? true,
      exportToCSV: json['exportToCSV'] as bool? ?? true,
      ma3Version: json['ma3Version'] as String? ?? '3.0',
      includeStagePositions: json['includeStagePositions'] as bool? ?? true,
      includeFixtureNotes: json['includeFixtureNotes'] as bool? ?? true,
      includeProperties: json['includeProperties'] as bool? ?? true,
      csvDelimiter: json['csvDelimiter'] as String? ?? ',',
      csvIncludeHeaders: json['csvIncludeHeaders'] as bool? ?? true,
    );

Map<String, dynamic> _$ExportDefaultsToJson(ExportDefaults instance) =>
    <String, dynamic>{
      'exportToMA3': instance.exportToMA3,
      'exportToJSON': instance.exportToJSON,
      'exportToCSV': instance.exportToCSV,
      'ma3Version': instance.ma3Version,
      'includeStagePositions': instance.includeStagePositions,
      'includeFixtureNotes': instance.includeFixtureNotes,
      'includeProperties': instance.includeProperties,
      'csvDelimiter': instance.csvDelimiter,
      'csvIncludeHeaders': instance.csvIncludeHeaders,
    };

PerformanceSettings _$PerformanceSettingsFromJson(Map<String, dynamic> json) =>
    PerformanceSettings(
      maxFixturesInMemory:
          (json['maxFixturesInMemory'] as num?)?.toInt() ?? 500,
      enableVirtualScroll: json['enableVirtualScroll'] as bool? ?? true,
      cacheSize: (json['cacheSize'] as num?)?.toInt() ?? 256,
      enableHardwareAcceleration:
          json['enableHardwareAcceleration'] as bool? ?? true,
      fixtureRenderBatchSize:
          (json['fixtureRenderBatchSize'] as num?)?.toInt() ?? 50,
    );

Map<String, dynamic> _$PerformanceSettingsToJson(
        PerformanceSettings instance) =>
    <String, dynamic>{
      'maxFixturesInMemory': instance.maxFixturesInMemory,
      'enableVirtualScroll': instance.enableVirtualScroll,
      'cacheSize': instance.cacheSize,
      'enableHardwareAcceleration': instance.enableHardwareAcceleration,
      'fixtureRenderBatchSize': instance.fixtureRenderBatchSize,
    };

DMXPreferences _$DMXPreferencesFromJson(Map<String, dynamic> json) =>
    DMXPreferences(
      id: json['id'] as String?,
      profileId: json['profileId'] as String,
      connectionSettings: json['connectionSettings'] == null
          ? null
          : ConnectionSettings.fromJson(
              json['connectionSettings'] as Map<String, dynamic>),
      patchingDefaults: json['patchingDefaults'] == null
          ? null
          : PatchingDefaults.fromJson(
              json['patchingDefaults'] as Map<String, dynamic>),
      stageDefaults: json['stageDefaults'] == null
          ? null
          : StageDefaults.fromJson(
              json['stageDefaults'] as Map<String, dynamic>),
      exportDefaults: json['exportDefaults'] == null
          ? null
          : ExportDefaults.fromJson(
              json['exportDefaults'] as Map<String, dynamic>),
      performanceSettings: json['performanceSettings'] == null
          ? null
          : PerformanceSettings.fromJson(
              json['performanceSettings'] as Map<String, dynamic>),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DMXPreferencesToJson(DMXPreferences instance) =>
    <String, dynamic>{
      'id': instance.id,
      'profileId': instance.profileId,
      'connectionSettings': instance.connectionSettings,
      'patchingDefaults': instance.patchingDefaults,
      'stageDefaults': instance.stageDefaults,
      'exportDefaults': instance.exportDefaults,
      'performanceSettings': instance.performanceSettings,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
