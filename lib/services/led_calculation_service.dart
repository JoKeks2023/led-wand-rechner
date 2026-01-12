import 'dart:math';
import '../models/led_models.dart';

class LEDCalculationService {
  static final LEDCalculationService _instance = LEDCalculationService._internal();

  factory LEDCalculationService() {
    return _instance;
  }

  LEDCalculationService._internal();

  /// Berechnet alle LED-Wandparameter basierend auf Inputs
  LEDCalculationResults calculateAll({
    required double widthMm,
    required double heightMm,
    required double pixelPitchMm,
    required double wattagePerLedMa, // in Milliamps
    required double? modulePriceEur,
    required double? installationCostEur,
    required double? serviceWarrantyCostEur,
    required double? shippingCostEur,
    required int? numberOfModules, // Optional: if directly provided
  }) {
    // 1. Pixeldichte (PPI - Pixel Per Inch)
    final pixelDensityPpi = calculatePixelDensity(pixelPitchMm);

    // 2. Gesamtauflösung in Pixeln
    final totalPixelsWidth = calculatePixelsInDimension(widthMm, pixelPitchMm);
    final totalPixelsHeight = calculatePixelsInDimension(heightMm, pixelPitchMm);
    final totalPixels = totalPixelsWidth * totalPixelsHeight;

    // 3. Gesamtfläche in m²
    final totalAreaM2 = calculateArea(widthMm, heightMm);

    // 4. Stromverbrauch
    final totalCurrentAmps = calculateTotalCurrent(totalPixels, wattagePerLedMa);
    final totalPowerWatts = calculateTotalPower(totalCurrentAmps);

    // 5. Helligkeit (Lux) - Geschätzter Wert basierend auf LED-Dichte
    final estimatedBrightness = calculateBrightness(pixelDensityPpi);

    // 6. Wärmeerzeugung (W)
    final heatGenerationW = calculateHeatGeneration(totalPowerWatts);

    // 7. Material-Gewicht (kg)
    final materialWeightKg = calculateMaterialWeight(totalAreaM2);

    // 8. Gesamtkosten (€)
    double? totalCostEur;
    if (modulePriceEur != null && numberOfModules != null && numberOfModules > 0) {
      totalCostEur = calculateTotalCost(
        modulePriceEur: modulePriceEur,
        numberOfModules: numberOfModules,
        installationCost: installationCostEur ?? 0,
        serviceWarrantyCost: serviceWarrantyCostEur ?? 0,
        shippingCost: shippingCostEur ?? 0,
      );
    }

    return LEDCalculationResults(
      pixelDensityPpi: pixelDensityPpi,
      totalPixelsWidth: totalPixelsWidth,
      totalPixelsHeight: totalPixelsHeight,
      totalPixels: totalPixels,
      totalAreaM2: totalAreaM2,
      totalPowerWatts: totalPowerWatts,
      totalCurrentAmps: totalCurrentAmps,
      estimatedBrightness: estimatedBrightness,
      heatGenerationW: heatGenerationW,
      materialWeightKg: materialWeightKg,
      totalCostEur: totalCostEur,
    );
  }

  /// Pixeldichte (PPI) = 25.4 / Pixel Pitch (mm)
  double calculatePixelDensity(double pixelPitchMm) {
    if (pixelPitchMm <= 0) return 0;
    return 25.4 / pixelPitchMm;
  }

  /// Anzahl Pixel in einer Dimension
  int calculatePixelsInDimension(double dimensionMm, double pixelPitchMm) {
    if (pixelPitchMm <= 0) return 0;
    return (dimensionMm / pixelPitchMm).round();
  }

  /// Fläche in m²
  double calculateArea(double widthMm, double heightMm) {
    final areaInMm2 = widthMm * heightMm;
    return areaInMm2 / 1000000; // Convert mm² to m²
  }

  /// Gesamtstrom in Ampere
  /// Wenn jede LED mit wattagePerLedMa (mA) arbeitet: Gesamt = totalPixels * wattagePerLedMa / 1000
  double calculateTotalCurrent(int totalPixels, double wattagePerLedMa) {
    return (totalPixels * wattagePerLedMa) / 1000; // Convert mA to A
  }

  /// Gesamtleistung in Watt
  /// Typische LED-Wandspannung: 5V
  double calculateTotalPower(double currentAmps, {double voltageV = 5.0}) {
    return currentAmps * voltageV;
  }

  /// Geschätzte Helligkeit (Lux)
  /// Basierend auf Pixel-Dichte und Standard-LED-Helligkeit
  /// Faustregel: Mehr Pixel = mehr Helligkeit
  double calculateBrightness(double pixelDensityPpi) {
    // Lineare Approximation: Höhere PPI → höhere mögliche Helligkeit
    // Basis: 1000 Lux bei 100 PPI
    return pixelDensityPpi * 10; // Rough estimation
  }

  /// Wärmeerzeugung
  /// Typisch: LED-Wirkungsgrad ~30%, d.h. 70% wird zu Wärme
  double calculateHeatGeneration(double powerWatts) {
    const double heatEfficiency = 0.70; // 70% wird zu Wärme
    return powerWatts * heatEfficiency;
  }

  /// Material-Gewicht
  /// Faustregel: ~2 kg pro m² für LED-Module mit Rahmen
  double calculateMaterialWeight(double areaM2) {
    const double weightPerM2 = 2.0; // kg/m²
    return areaM2 * weightPerM2;
  }

  /// Gesamtkosten
  double calculateTotalCost({
    required double modulePriceEur,
    required int numberOfModules,
    double installationCost = 0,
    double serviceWarrantyCost = 0,
    double shippingCost = 0,
  }) {
    final modulesTotalCost = modulePriceEur * numberOfModules;
    return modulesTotalCost + installationCost + serviceWarrantyCost + shippingCost;
  }

  /// Berechne Anzahl Module basierend auf Wandgröße und Modulgröße
  int calculateNumberOfModules({
    required double wallWidthMm,
    required double wallHeightMm,
    required String moduleSize, // z.B. "320x160"
  }) {
    try {
      final parts = moduleSize.split('x');
      if (parts.length != 2) return 0;

      final moduleWidth = double.parse(parts[0]);
      final moduleHeight = double.parse(parts[1]);

      if (moduleWidth <= 0 || moduleHeight <= 0) return 0;

      final modulesHorizontal = (wallWidthMm / moduleWidth).ceil();
      final modulesVertical = (wallHeightMm / moduleHeight).ceil();

      return modulesHorizontal * modulesVertical;
    } catch (e) {
      return 0;
    }
  }

  /// Refresh-Rate Schätzung basierend auf Pixeldichte und Bildwiederholfrequenz
  int estimateRefreshRate(double pixelDensityPpi) {
    // Höhere PPI-Dichte erfordert höhere Refresh-Rate für flüssiges Bild
    // Basis: 1920 Hz bei 50 PPI
    return (pixelDensityPpi * 38.4).round().clamp(960, 7680);
  }

  /// Stromversorgungskapazität (PSU-Größe in Watt)
  /// Mit 20% Overhead-Puffer
  double calculatePSUCapacity(double totalPowerWatts) {
    const double overheadFactor = 1.2; // 20% Puffer
    return totalPowerWatts * overheadFactor;
  }

  /// ROI-Berechnung (vereinfacht)
  /// Annahme: LED-Wand spart ~€5 pro Tag Energiekosten vs. traditionelle Beleuchtung
  double estimateROIMonths(double totalCostEur) {
    const double dailiySavings = 5.0; // € pro Tag
    final monthlySavings = dailiySavings * 30;
    
    if (monthlySavings <= 0) return 0;
    
    return totalCostEur / monthlySavings;
  }
}

final ledCalculationService = LEDCalculationService();
