// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'led_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LEDBrand _$LEDBrandFromJson(Map<String, dynamic> json) => LEDBrand(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      country: json['country'] as String?,
      website: json['website'] as String?,
      logoUrl: json['logoUrl'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$LEDBrandToJson(LEDBrand instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'country': instance.country,
      'website': instance.website,
      'logoUrl': instance.logoUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

LEDModel _$LEDModelFromJson(Map<String, dynamic> json) => LEDModel(
      id: json['id'] as String?,
      brandId: json['brandId'] as String,
      modelName: json['modelName'] as String,
      pixelPitchMm: (json['pixelPitchMm'] as num).toDouble(),
      colorType: json['colorType'] as String,
      wattagePerLedMa: (json['wattagePerLedMa'] as num).toDouble(),
      pricePerUnitEur: (json['pricePerUnitEur'] as num?)?.toDouble(),
      specsJson: json['specsJson'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$LEDModelToJson(LEDModel instance) => <String, dynamic>{
      'id': instance.id,
      'brandId': instance.brandId,
      'modelName': instance.modelName,
      'pixelPitchMm': instance.pixelPitchMm,
      'colorType': instance.colorType,
      'wattagePerLedMa': instance.wattagePerLedMa,
      'pricePerUnitEur': instance.pricePerUnitEur,
      'specsJson': instance.specsJson,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

ModelVariant _$ModelVariantFromJson(Map<String, dynamic> json) => ModelVariant(
      id: json['id'] as String?,
      modelId: json['modelId'] as String,
      variantName: json['variantName'] as String,
      specificSpecsJson: json['specificSpecsJson'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ModelVariantToJson(ModelVariant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'modelId': instance.modelId,
      'variantName': instance.variantName,
      'specificSpecsJson': instance.specificSpecsJson,
      'createdAt': instance.createdAt.toIso8601String(),
    };

CustomModel _$CustomModelFromJson(Map<String, dynamic> json) => CustomModel(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      modelName: json['modelName'] as String,
      brandIdOrCustom: json['brandIdOrCustom'] as String?,
      specsJson: json['specsJson'] as Map<String, dynamic>,
      isPublished: json['isPublished'] as bool? ?? false,
      isPrivate: json['isPrivate'] as bool? ?? true,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CustomModelToJson(CustomModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'modelName': instance.modelName,
      'brandIdOrCustom': instance.brandIdOrCustom,
      'specsJson': instance.specsJson,
      'isPublished': instance.isPublished,
      'isPrivate': instance.isPrivate,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      selectedBrandId: json['selectedBrandId'] as String?,
      selectedModelId: json['selectedModelId'] as String?,
      selectedVariantId: json['selectedVariantId'] as String?,
      isCustomModel: json['isCustomModel'] as bool? ?? false,
      customModelId: json['customModelId'] as String?,
      parametersJson: json['parametersJson'] as Map<String, dynamic>,
      resultsJson: json['resultsJson'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'description': instance.description,
      'selectedBrandId': instance.selectedBrandId,
      'selectedModelId': instance.selectedModelId,
      'selectedVariantId': instance.selectedVariantId,
      'isCustomModel': instance.isCustomModel,
      'customModelId': instance.customModelId,
      'parametersJson': instance.parametersJson,
      'resultsJson': instance.resultsJson,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
