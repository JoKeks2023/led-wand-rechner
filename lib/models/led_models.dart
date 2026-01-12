import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'led_models.g.dart';

// LED Brand Model
@JsonSerializable()
class LEDBrand {
  final String id;
  final String name;
  final String? description;
  final String? country;
  final String? website;
  final String? logoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  LEDBrand({
    String? id,
    required this.name,
    this.description,
    this.country,
    this.website,
    this.logoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory LEDBrand.fromJson(Map<String, dynamic> json) => _$LEDBrandFromJson(json);
  Map<String, dynamic> toJson() => _$LEDBrandToJson(this);

  LEDBrand copyWith({
    String? id,
    String? name,
    String? description,
    String? country,
    String? website,
    String? logoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LEDBrand(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      country: country ?? this.country,
      website: website ?? this.website,
      logoUrl: logoUrl ?? this.logoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// LED Model (Produkt-Modell)
@JsonSerializable()
class LEDModel {
  final String id;
  final String brandId;
  final String modelName;
  final double pixelPitchMm;
  final String colorType; // RGB, RGBW, Full Color
  final double wattagePerLedMa;
  final double? pricePerUnitEur;
  final Map<String, dynamic>? specsJson;
  final DateTime createdAt;
  final DateTime updatedAt;

  LEDModel({
    String? id,
    required this.brandId,
    required this.modelName,
    required this.pixelPitchMm,
    required this.colorType,
    required this.wattagePerLedMa,
    this.pricePerUnitEur,
    this.specsJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory LEDModel.fromJson(Map<String, dynamic> json) => _$LEDModelFromJson(json);
  Map<String, dynamic> toJson() => _$LEDModelToJson(this);

  LEDModel copyWith({
    String? id,
    String? brandId,
    String? modelName,
    double? pixelPitchMm,
    String? colorType,
    double? wattagePerLedMa,
    double? pricePerUnitEur,
    Map<String, dynamic>? specsJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LEDModel(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      modelName: modelName ?? this.modelName,
      pixelPitchMm: pixelPitchMm ?? this.pixelPitchMm,
      colorType: colorType ?? this.colorType,
      wattagePerLedMa: wattagePerLedMa ?? this.wattagePerLedMa,
      pricePerUnitEur: pricePerUnitEur ?? this.pricePerUnitEur,
      specsJson: specsJson ?? this.specsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Model Variant (z.B. CF5 RGB vs RGBW)
@JsonSerializable()
class ModelVariant {
  final String id;
  final String modelId;
  final String variantName;
  final Map<String, dynamic>? specificSpecsJson;
  final DateTime createdAt;

  ModelVariant({
    String? id,
    required this.modelId,
    required this.variantName,
    this.specificSpecsJson,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  factory ModelVariant.fromJson(Map<String, dynamic> json) => _$ModelVariantFromJson(json);
  Map<String, dynamic> toJson() => _$ModelVariantToJson(this);
}

// Custom Model (Benutzer-definiert)
@JsonSerializable()
class CustomModel {
  final String id;
  final String userId;
  final String modelName;
  final String? brandIdOrCustom;
  final Map<String, dynamic> specsJson;
  final bool isPublished;
  final bool isPrivate;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomModel({
    String? id,
    required this.userId,
    required this.modelName,
    this.brandIdOrCustom,
    required this.specsJson,
    this.isPublished = false,
    this.isPrivate = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory CustomModel.fromJson(Map<String, dynamic> json) => _$CustomModelFromJson(json);
  Map<String, dynamic> toJson() => _$CustomModelToJson(this);

  CustomModel copyWith({
    String? id,
    String? userId,
    String? modelName,
    String? brandIdOrCustom,
    Map<String, dynamic>? specsJson,
    bool? isPublished,
    bool? isPrivate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      modelName: modelName ?? this.modelName,
      brandIdOrCustom: brandIdOrCustom ?? this.brandIdOrCustom,
      specsJson: specsJson ?? this.specsJson,
      isPublished: isPublished ?? this.isPublished,
      isPrivate: isPrivate ?? this.isPrivate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Project Model
@JsonSerializable()
class Project {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? selectedBrandId;
  final String? selectedModelId;
  final String? selectedVariantId;
  final bool isCustomModel;
  final String? customModelId;
  final Map<String, dynamic> parametersJson;
  final Map<String, dynamic>? resultsJson;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    String? id,
    required this.userId,
    required this.name,
    this.description,
    this.selectedBrandId,
    this.selectedModelId,
    this.selectedVariantId,
    this.isCustomModel = false,
    this.customModelId,
    required this.parametersJson,
    this.resultsJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  Project copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? selectedBrandId,
    String? selectedModelId,
    String? selectedVariantId,
    bool? isCustomModel,
    String? customModelId,
    Map<String, dynamic>? parametersJson,
    Map<String, dynamic>? resultsJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      selectedBrandId: selectedBrandId ?? this.selectedBrandId,
      selectedModelId: selectedModelId ?? this.selectedModelId,
      selectedVariantId: selectedVariantId ?? this.selectedVariantId,
      isCustomModel: isCustomModel ?? this.isCustomModel,
      customModelId: customModelId ?? this.customModelId,
      parametersJson: parametersJson ?? this.parametersJson,
      resultsJson: resultsJson ?? this.resultsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// LED Calculation Results
@JsonSerializable()
class LEDCalculationResults {
  final double pixelDensityPpi;
  final int totalPixelsWidth;
  final int totalPixelsHeight;
  final int totalPixels;
  final double totalAreaM2;
  final double totalPowerWatts;
  final double totalCurrentAmps;
  final double? estimatedBrightness; // Lux
  final double? heatGenerationW;
  final double? materialWeightKg;
  final double? totalCostEur;
  final DateTime calculatedAt;

  LEDCalculationResults({
    required this.pixelDensityPpi,
    required this.totalPixelsWidth,
    required this.totalPixelsHeight,
    required this.totalPixels,
    required this.totalAreaM2,
    required this.totalPowerWatts,
    required this.totalCurrentAmps,
    this.estimatedBrightness,
    this.heatGenerationW,
    this.materialWeightKg,
    this.totalCostEur,
    DateTime? calculatedAt,
  }) : calculatedAt = calculatedAt ?? DateTime.now();

  factory LEDCalculationResults.fromJson(Map<String, dynamic> json) =>
      _$LEDCalculationResultsFromJson(json);
  Map<String, dynamic> toJson() => _$LEDCalculationResultsToJson(this);
}
