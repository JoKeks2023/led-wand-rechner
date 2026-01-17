import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_wand_app/models/led_models.dart';
import 'package:led_wand_app/services/device_catalog_service.dart';
import 'package:led_wand_app/services/led_calculation_service.dart';

// Theme mode (light/dark/system)
final themeModeProvider = StateProvider<String>((ref) => 'system');

// Calculation inputs
final ledWidthMmProvider = StateProvider<double>((ref) => 1000);
final ledHeightMmProvider = StateProvider<double>((ref) => 1000);
final unitCostEurProvider = StateProvider<double>((ref) => 100);

// Demo brands/models for the calculator
final _demoBrands = <LEDBrand>[
  LEDBrand(name: 'Unilumin', country: 'CN', description: 'LED solutions'),
  LEDBrand(name: 'ROE Visual', country: 'NL', description: 'Touring panels'),
];

final _demoModels = <LEDModel>[
  LEDModel(
    brandId: _demoBrands[0].id,
    modelName: 'Upad III 3.9',
    pixelPitchMm: 3.9,
    colorType: 'RGB',
    wattagePerLedMa: 18,
    pricePerUnitEur: 0.12,
  ),
  LEDModel(
    brandId: _demoBrands[1].id,
    modelName: 'Carbon Series 5',
    pixelPitchMm: 5.0,
    colorType: 'RGB',
    wattagePerLedMa: 18,
    pricePerUnitEur: 0.10,
  ),
];

final ledBrandsProvider =
    FutureProvider<List<LEDBrand>>((ref) async => _demoBrands);
final selectedBrandProvider = StateProvider<LEDBrand?>((ref) => null);
final ledModelsForBrandProvider =
    FutureProvider.family<List<LEDModel>, String>((ref, brandId) async {
  return _demoModels.where((m) => m.brandId == brandId).toList();
});
final selectedModelProvider = StateProvider<LEDModel?>((ref) => null);

// Calculation service
final ledCalculationServiceProvider =
    Provider<LEDCalculationService>((ref) => LEDCalculationService());

// Derived calculation results
final calculationResultsProvider = Provider<LEDCalculationResults>((ref) {
  final service = ref.watch(ledCalculationServiceProvider);
  final model = ref.watch(selectedModelProvider);
  final widthMm = ref.watch(ledWidthMmProvider);
  final heightMm = ref.watch(ledHeightMmProvider);
  final unitCost = ref.watch(unitCostEurProvider);

  if (model == null) {
    return LEDCalculationResults.empty(widthMm: widthMm, heightMm: heightMm);
  }

  return service.calculate(
    widthMm: widthMm,
    heightMm: heightMm,
    pixelPitchMm: model.pixelPitchMm,
    wattagePerPixelMa: model.wattagePerLedMa,
    unitCostEur: unitCost,
  );
});

// Device catalog
final deviceCatalogServiceProvider =
    Provider<DeviceCatalogService>((ref) => DeviceCatalogService());
final deviceCatalogProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(deviceCatalogServiceProvider);
  return service.loadLocalCatalog();
});

// Legacy bridges replaced by no-op notifiers so existing widgets compile
class DummyNotifier extends ChangeNotifier {}

final projectsProvider =
    ChangeNotifierProvider<DummyNotifier>((ref) => DummyNotifier());
final ledDataProvider =
    ChangeNotifierProvider<DummyNotifier>((ref) => DummyNotifier());
final calculationProvider =
    ChangeNotifierProvider<DummyNotifier>((ref) => DummyNotifier());
final authProvider =
    ChangeNotifierProvider<DummyNotifier>((ref) => DummyNotifier());
final connectivityStatusProvider =
    ChangeNotifierProvider<DummyNotifier>((ref) => DummyNotifier());
final connectivityProvider =
    StreamProvider<dynamic>((ref) => const Stream.empty());
