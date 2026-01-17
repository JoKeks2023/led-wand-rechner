import 'dart:math';

/// Lightweight results model for the LED calculator
class LEDCalculationResults {
  final int totalPixels;
  final int widthPixels;
  final int heightPixels;
  final double estimatedCostEur;
  final double estimatedPowerWatts;
  final double pixelPitchMm;
  final double coverage;
  final double widthMeters;
  final double heightMeters;
  final double pixelsPerSqMeter;
  final double powerPerPixelWatts;

  const LEDCalculationResults({
    required this.totalPixels,
    required this.widthPixels,
    required this.heightPixels,
    required this.estimatedCostEur,
    required this.estimatedPowerWatts,
    required this.pixelPitchMm,
    required this.coverage,
    required this.widthMeters,
    required this.heightMeters,
    required this.pixelsPerSqMeter,
    required this.powerPerPixelWatts,
  });

  factory LEDCalculationResults.empty(
      {required double widthMm, required double heightMm}) {
    return LEDCalculationResults(
      totalPixels: 0,
      widthPixels: 0,
      heightPixels: 0,
      estimatedCostEur: 0,
      estimatedPowerWatts: 0,
      pixelPitchMm: 0,
      coverage: (widthMm * heightMm) / 1000000,
      widthMeters: widthMm / 1000,
      heightMeters: heightMm / 1000,
      pixelsPerSqMeter: 0,
      powerPerPixelWatts: 0,
    );
  }
}

class LEDCalculationService {
  LEDCalculationResults calculate({
    required double widthMm,
    required double heightMm,
    required double pixelPitchMm,
    required double wattagePerPixelMa,
    required double unitCostEur,
  }) {
    widthMm = widthMm.abs();
    heightMm = heightMm.abs();
    pixelPitchMm = pixelPitchMm.abs();
    wattagePerPixelMa = wattagePerPixelMa.abs();
    unitCostEur = unitCostEur.abs();

    if (pixelPitchMm <= 0 || widthMm <= 0 || heightMm <= 0) {
      return LEDCalculationResults.empty(widthMm: widthMm, heightMm: heightMm);
    }

    final widthPixels = (widthMm / pixelPitchMm).ceil();
    final heightPixels = (heightMm / pixelPitchMm).ceil();
    final totalPixels = widthPixels * heightPixels;

    final widthMeters = widthMm / 1000;
    final heightMeters = heightMm / 1000;
    final coverageSqMeters = widthMeters * heightMeters;

    const voltageV = 5.0;
    final powerPerPixelWatts = (wattagePerPixelMa * voltageV) / 1000;
    final estimatedPowerWatts = totalPixels * powerPerPixelWatts;

    const efficiencyFactor = 0.88;
    final estimatedCostEur = (totalPixels * unitCostEur) / efficiencyFactor;

    final pixelsPerSqMeter = coverageSqMeters > 0
        ? (totalPixels / max(coverageSqMeters, 0.0001))
        : 0.0;

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
}
