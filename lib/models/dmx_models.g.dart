// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dmx_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DMXProfile _$DMXProfileFromJson(Map<String, dynamic> json) => DMXProfile(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      profileName: json['profileName'] as String,
      consoleBrand: json['consoleBrand'] as String,
      consoleModel: json['consoleModel'] as String,
      universeCount: (json['universeCount'] as num?)?.toInt() ?? 4,
      channelsPerUniverse:
          (json['channelsPerUniverse'] as num?)?.toInt() ?? 512,
      isDefault: json['isDefault'] as bool? ?? false,
      settings: json['settings'] as Map<String, dynamic>? ?? const {},
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DMXProfileToJson(DMXProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'profileName': instance.profileName,
      'consoleBrand': instance.consoleBrand,
      'consoleModel': instance.consoleModel,
      'universeCount': instance.universeCount,
      'channelsPerUniverse': instance.channelsPerUniverse,
      'isDefault': instance.isDefault,
      'settings': instance.settings,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

DMXPatch _$DMXPatchFromJson(Map<String, dynamic> json) => DMXPatch(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      profileId: json['profileId'] as String,
      patchName: json['patchName'] as String,
      description: json['description'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DMXPatchToJson(DMXPatch instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'profileId': instance.profileId,
      'patchName': instance.patchName,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

FixtureType _$FixtureTypeFromJson(Map<String, dynamic> json) => FixtureType(
      id: json['id'] as String?,
      gdtfId: json['gdtfId'] as String,
      manufacturer: json['manufacturer'] as String,
      model: json['model'] as String,
      channels: (json['channels'] as num).toInt(),
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String?,
      gdtfData: json['gdtfData'] as Map<String, dynamic>,
      cachedAt: json['cachedAt'] == null
          ? null
          : DateTime.parse(json['cachedAt'] as String),
    );

Map<String, dynamic> _$FixtureTypeToJson(FixtureType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gdtfId': instance.gdtfId,
      'manufacturer': instance.manufacturer,
      'model': instance.model,
      'channels': instance.channels,
      'category': instance.category,
      'imageUrl': instance.imageUrl,
      'gdtfData': instance.gdtfData,
      'cachedAt': instance.cachedAt.toIso8601String(),
    };

Fixture _$FixtureFromJson(Map<String, dynamic> json) => Fixture(
      id: json['id'] as String?,
      patchId: json['patchId'] as String,
      fixtureTypeId: json['fixtureTypeId'] as String,
      fixtureName: json['fixtureName'] as String,
      fixtureNumber: (json['fixtureNumber'] as num).toInt(),
      universe: json['universe'] as String,
      startChannel: (json['startChannel'] as num).toInt(),
      endChannel: (json['endChannel'] as num).toInt(),
      xPosition: (json['xPosition'] as num?)?.toDouble(),
      yPosition: (json['yPosition'] as num?)?.toDouble(),
      zPosition: (json['zPosition'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FixtureToJson(Fixture instance) => <String, dynamic>{
      'id': instance.id,
      'patchId': instance.patchId,
      'fixtureTypeId': instance.fixtureTypeId,
      'fixtureName': instance.fixtureName,
      'fixtureNumber': instance.fixtureNumber,
      'universe': instance.universe,
      'startChannel': instance.startChannel,
      'endChannel': instance.endChannel,
      'xPosition': instance.xPosition,
      'yPosition': instance.yPosition,
      'zPosition': instance.zPosition,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

DMXUniverse _$DMXUniverseFromJson(Map<String, dynamic> json) => DMXUniverse(
      id: json['id'] as String?,
      patchId: json['patchId'] as String,
      universeName: json['universeName'] as String,
      universeNumber: (json['universeNumber'] as num).toInt(),
      channelOccupancy: (json['channelOccupancy'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$DMXUniverseToJson(DMXUniverse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patchId': instance.patchId,
      'universeName': instance.universeName,
      'universeNumber': instance.universeNumber,
      'channelOccupancy': instance.channelOccupancy,
    };

StageSettings _$StageSettingsFromJson(Map<String, dynamic> json) =>
    StageSettings(
      id: json['id'] as String?,
      patchId: json['patchId'] as String,
      stageWidthM: (json['stageWidthM'] as num?)?.toDouble() ?? 10,
      stageHeightM: (json['stageHeightM'] as num?)?.toDouble() ?? 8,
      stageDepthM: (json['stageDepthM'] as num?)?.toDouble() ?? 5,
      showGrid: json['showGrid'] as bool? ?? true,
      showFixtureLabels: json['showFixtureLabels'] as bool? ?? true,
      showChannelNumbers: json['showChannelNumbers'] as bool? ?? false,
      gridSize: (json['gridSize'] as num?)?.toDouble() ?? 1.0,
      fixtureIconSize: (json['fixtureIconSize'] as num?)?.toDouble() ?? 24,
      zoomLevel: (json['zoomLevel'] as num?)?.toDouble() ?? 1.0,
      pixelsPerMeter: (json['pixelsPerMeter'] as num?)?.toInt() ?? 50,
    );

Map<String, dynamic> _$StageSettingsToJson(StageSettings instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patchId': instance.patchId,
      'stageWidthM': instance.stageWidthM,
      'stageHeightM': instance.stageHeightM,
      'stageDepthM': instance.stageDepthM,
      'showGrid': instance.showGrid,
      'showFixtureLabels': instance.showFixtureLabels,
      'showChannelNumbers': instance.showChannelNumbers,
      'gridSize': instance.gridSize,
      'fixtureIconSize': instance.fixtureIconSize,
      'zoomLevel': instance.zoomLevel,
      'pixelsPerMeter': instance.pixelsPerMeter,
    };

GrandMA3Config _$GrandMA3ConfigFromJson(Map<String, dynamic> json) =>
    GrandMA3Config(
      id: json['id'] as String?,
      profileId: json['profileId'] as String,
      ipAddress: json['ipAddress'] as String,
      oscPort: (json['oscPort'] as num?)?.toInt() ?? 7000,
      username: json['username'] as String?,
      password: json['password'] as String?,
      autoDiscoveryEnabled: json['autoDiscoveryEnabled'] as bool? ?? true,
      discoveryTimeoutSeconds:
          (json['discoveryTimeoutSeconds'] as num?)?.toInt() ?? 5,
      isConnected: json['isConnected'] as bool? ?? false,
      lastConnected: json['lastConnected'] == null
          ? null
          : DateTime.parse(json['lastConnected'] as String),
    );

Map<String, dynamic> _$GrandMA3ConfigToJson(GrandMA3Config instance) =>
    <String, dynamic>{
      'id': instance.id,
      'profileId': instance.profileId,
      'ipAddress': instance.ipAddress,
      'oscPort': instance.oscPort,
      'username': instance.username,
      'password': instance.password,
      'autoDiscoveryEnabled': instance.autoDiscoveryEnabled,
      'discoveryTimeoutSeconds': instance.discoveryTimeoutSeconds,
      'isConnected': instance.isConnected,
      'lastConnected': instance.lastConnected?.toIso8601String(),
    };

ConnectionHistory _$ConnectionHistoryFromJson(Map<String, dynamic> json) =>
    ConnectionHistory(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      ipAddress: json['ipAddress'] as String,
      port: (json['port'] as num?)?.toInt() ?? 7000,
      connectedAt: json['connectedAt'] == null
          ? null
          : DateTime.parse(json['connectedAt'] as String),
      disconnectedAt: json['disconnectedAt'] == null
          ? null
          : DateTime.parse(json['disconnectedAt'] as String),
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$ConnectionHistoryToJson(ConnectionHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'ipAddress': instance.ipAddress,
      'port': instance.port,
      'connectedAt': instance.connectedAt.toIso8601String(),
      'disconnectedAt': instance.disconnectedAt?.toIso8601String(),
      'errorMessage': instance.errorMessage,
    };
