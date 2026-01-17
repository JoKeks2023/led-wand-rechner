import 'package:hive/hive.dart';
import '../models/led_models.dart';

part 'hive_adapters.g.dart';

// Hive Box Names
const String ledBrandsBoxName = 'led_brands';
const String ledModelsBoxName = 'led_models';
const String modelVariantsBoxName = 'model_variants';
const String projectsBoxName = 'projects';
const String customModelsBoxName = 'custom_models';
const String syncMetadataBoxName = 'sync_metadata';

// Adapter für LEDBrand
@HiveType(typeId: 0)
class LEDBrandAdapter extends TypeAdapter<LEDBrand> {
  @override
  final int typeId = 0;

  @override
  LEDBrand read(BinaryReader reader) {
    return LEDBrand.fromJson(Map<String, dynamic>.from(reader.readMap()));
  }

  @override
  void write(BinaryWriter writer, LEDBrand obj) {
    writer.writeMap(obj.toJson());
  }
}

// Adapter für LEDModel
@HiveType(typeId: 1)
class LEDModelAdapter extends TypeAdapter<LEDModel> {
  @override
  final int typeId = 1;

  @override
  LEDModel read(BinaryReader reader) {
    return LEDModel.fromJson(Map<String, dynamic>.from(reader.readMap()));
  }

  @override
  void write(BinaryWriter writer, LEDModel obj) {
    writer.writeMap(obj.toJson());
  }
}

// Adapter für ModelVariant
@HiveType(typeId: 2)
class ModelVariantAdapter extends TypeAdapter<ModelVariant> {
  @override
  final int typeId = 2;

  @override
  ModelVariant read(BinaryReader reader) {
    return ModelVariant.fromJson(Map<String, dynamic>.from(reader.readMap()));
  }

  @override
  void write(BinaryWriter writer, ModelVariant obj) {
    writer.writeMap(obj.toJson());
  }
}

// Adapter für Project
@HiveType(typeId: 3)
class ProjectAdapter extends TypeAdapter<Project> {
  @override
  final int typeId = 3;

  @override
  Project read(BinaryReader reader) {
    return Project.fromJson(Map<String, dynamic>.from(reader.readMap()));
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer.writeMap(obj.toJson());
  }
}

// Adapter für CustomModel
@HiveType(typeId: 4)
class CustomModelAdapter extends TypeAdapter<CustomModel> {
  @override
  final int typeId = 4;

  @override
  CustomModel read(BinaryReader reader) {
    return CustomModel.fromJson(Map<String, dynamic>.from(reader.readMap()));
  }

  @override
  void write(BinaryWriter writer, CustomModel obj) {
    writer.writeMap(obj.toJson());
  }
}
