import 'dart:math';
import '../models/led_models.dart';

/// Results from LED wall calculation
class LEDCalculationResults {
  final int totalPixels;
  final int widthPixels;
  final int heightPixels;
  final double estimatedCostEur;
  final double estimatedPowerWatts;
  final double pixelPitchMm;
  final double coverage; // In square meters
  final double widthMeters;
  final double heightMeters;
  final double pixelsPerSqMeter;
  final double powerPerPixelWatts;

  LEDCalculationResults({
    required this.totalPixels,
    required this.widthPixels,
    required this.heightPixels,
    required this.estimatedCostEur,
    required this.estimatedPowerWatts,
    required this.pixelPitchMm,
    required this.coverage,
    double? widthMeters,
    double? heightMeters,
    double? pixelsPerSqMeter,
    double? powerPerPixelWatts,
  })  : widthMeters = widthMeters ?? 0,
        heightMeters = heightMeters ?? 0,
        pixelsPerSqMeter = pixelsPerSqMeter ??
            (totalPixels > 0 ? totalPixels / max(coverage, 0.01) : 0),
        powerPerPixelWatts = powerPerPixelWatts ??
            (totalPixels > 0 ? estimatedPowerWatts / totalPixels : 0);

  Map<String, dynamic> toJson() => {
        'totalPixels': totalPixels,
        'widthPixels': widthPixels,
        'heightPixels': heightPixels,
        'estimatedCostEur': estimatedCostEur,
        'estimatedPowerWatts': estimatedPowerWatts,
        'pixelPitchMm': pixelPitchMm,
        'coverageSqMeters': coverage,
        'widthMeters': widthMeters,
        'heightMeters': heightMeters,
        'pixelsPerSqMeter': pixelsPerSqMeter,
        'powerPerPixelWatts': powerPerPixelWatts,
      };
}

class LEDCalculationService {
  static final LEDCalculationService _instance =
      LEDCalculationService._internal();

  factory LEDCalculationService() {
    return _instance;
  }

  LEDCalculationService._internal();

  /// Main calculation method for LED wall specifications
  LEDCalculationResults calculate({
    required double widthMm,
    required double heightMm,
    required double pixelPitchMm,
    required double wattagePerPixelMa,
    required double unitCostEur,
  }) {
    // Ensure positive values
    widthMm = widthMm.abs();
    heightMm = heightMm.abs();
    pixelPitchMm = pixelPitchMm.abs();
    wattagePerPixelMa = wattagePerPixelMa.abs();
    unitCostEur = unitCostEur.abs();

    // Handle edge cases
    if (pixelPitchMm <= 0 || widthMm <= 0 || heightMm <= 0) {
      return LEDCalculationResults(
        totalPixels: 0,
        widthPixels: 0,
        heightPixels: 0,
        estimatedCostEur: 0,
        estimatedPowerWatts: 0,
        pixelPitchMm: pixelPitchMm,
        coverage: 0,
        widthMeters: widthMm / 1000,
        heightMeters: heightMm / 1000,
        pixelsPerSqMeter: 0,
      );
    }

    // Calculate pixel count
    final widthPixels = (widthMm / pixelPitchMm).ceil();
    final heightPixels = (heightMm / pixelPitchMm).ceil();
    final totalPixels = widthPixels * heightPixels;

    // Calculate physical dimensions in meters
    final widthMeters = widthMm / 1000;
    final heightMeters = heightMm / 1000;
    final coverageSqMeters = widthMeters * heightMeters;

    // Calculate power consumption
    // wattagePerPixelMa is in mA at 5V, convert to watts: W = (mA * 5V) / 1000
    const voltageV = 5.0;
    final powerPerPixelWatts = (wattagePerPixelMa * voltageV) / 1000;
    final estimatedPowerWatts = totalPixels * powerPerPixelWatts;

    // Calculate cost with efficiency factor
    const efficiencyFactor = 0.88; // 88% efficiency
    final estimatedCostEur = (totalPixels * unitCostEur) / efficiencyFactor;

    // Pixels per square meter
    final pixelsPerSqMeter = coverageSqMeters > 0 ? totalPixels / coverageSqMeters : 0;

    return LEDCalculationResults(
      totalPixels: totalPixels,
      widthPixels: widthPixels,
      heightPixels: heightPixels,
      estimatedCostEur: estimatedCostEur,
      estimatedPowerWatts: estimatedPowerWatts,
      pixelPitchMm: pixelPitchMm,
      coverage: coverageSqMeters,
      widthMeters: widthMeters,
      heightMeters: heightMeters,
      pixelsPerSqMeter: pixelsPerSqMeter,
      powerPerPixelWatts: powerPerPixelWatts,
    );
  }

  /// DEPRECATED: Old methods below - kept for reference

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
    final totalPixelsHeight =
        calculatePixelsInDimension(heightMm, pixelPitchMm);
    final totalPixels = totalPixelsWidth * totalPixelsHeight;

    // 3. Gesamtfläche in m²
    final totalAreaM2 = calculateArea(widthMm, heightMm);

    // 4. Stromverbrauch
    final totalCurrentAmps =
        calculateTotalCurrent(totalPixels, wattagePerLedMa);
    final totalPowerWatts = calculateTotalPower(totalCurrentAmps);

    // 5. Helligkeit (Lux) - Geschätzter Wert basierend auf LED-Dichte
    final estimatedBrightness = calculateBrightness(pixelDensityPpi);

    // 6. Wärmeerzeugung (W)
    final heatGenerationW = calculateHeatGeneration(totalPowerWatts);

    // 7. Material-Gewicht (kg)
    final materialWeightKg = calculateMaterialWeight(totalAreaM2);

    // 8. Gesamtkosten (€)
    double? totalCostEur;
    if (modulePriceEur != null &&
        numberOfModules != null &&
        numberOfModules > 0) {
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
    return modulesTotalCost +
        installationCost +
        serviceWarrantyCost +
        shippingCost;
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
