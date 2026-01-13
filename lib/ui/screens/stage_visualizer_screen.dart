import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/dmx_models.dart';
import '../../providers/app_providers.dart';
import '../../services/localization_service.dart';
import '../theme/app_colors.dart';
import '../widgets/modern_components.dart';

class StageVisualizerScreen extends StatefulWidget {
  const StageVisualizerScreen({Key? key}) : super(key: key);

  @override
  State<StageVisualizerScreen> createState() => _StageVisualizerScreenState();
}

class _StageVisualizerScreenState extends State<StageVisualizerScreen> {
  late TransformationController _transformationController;
  double _zoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(localization.translate('stage.visualizer')),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () => _zoom(1.2),
            tooltip: localization.translate('stage.zoom_in'),
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () => _zoom(0.8),
            tooltip: localization.translate('stage.zoom_out'),
          ),
          IconButton(
            icon: const Icon(Icons.fit_screen),
            onPressed: () => _resetZoom(),
            tooltip: localization.translate('stage.fit_screen'),
          ),
        ],
      ),
      body: Consumer3<DMXProfilesProvider, DMXServiceProvider,
          DMXPreferencesProvider>(
        builder: (context, profilesProvider, dmxService, prefsProvider, _) {
          final selectedProfile = profilesProvider.currentProfile;

          if (selectedProfile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    size: 64,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    localization.translate('stage.no_profile_selected'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              // Main Canvas Area
              InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.5,
                maxScale: 5.0,
                onInteractionEnd: (_) {
                  setState(() {});
                },
                child: CustomPaint(
                  painter: StagePainter(
                    profile: selectedProfile,
                    preferences: prefsProvider.preferences,
                    zoomLevel: _zoomLevel,
                  ),
                  size: Size.infinite,
                ),
              ),

              // Bottom Controls Panel
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _VisualizerControlPanel(
                  profile: selectedProfile,
                  zoomLevel: _zoomLevel,
                ),
              ),

              // Top Info Panel
              Positioned(
                top: 0,
                left: 16,
                right: 16,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ModernCard(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              selectedProfile.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${selectedProfile.patches.length} Patches • ${_countFixtures(selectedProfile)} Fixtures',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.neutral600),
                            ),
                          ],
                        ),
                        Chip(
                          label: Text(
                            '${(_zoomLevel * 100).toStringAsFixed(0)}%',
                          ),
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _zoom(double factor) {
    setState(() {
      _zoomLevel *= factor;
      _zoomLevel = _zoomLevel.clamp(0.5, 5.0);
    });
    _transformationController.value = Matrix4.identity()..scale(_zoomLevel);
  }

  void _resetZoom() {
    setState(() {
      _zoomLevel = 1.0;
    });
    _transformationController.value = Matrix4.identity();
  }

  int _countFixtures(DMXProfile profile) {
    int count = 0;
    for (var patch in profile.patches) {
      count += patch.fixtures.length;
    }
    return count;
  }
}

class StagePainter extends CustomPainter {
  final DMXProfile profile;
  final DMXPreferences preferences;
  final double zoomLevel;

  StagePainter({
    required this.profile,
    required this.preferences,
    this.zoomLevel = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stageBg = Paint()
      ..color = AppColors.neutral900.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final stageBorder = Paint()
      ..color = AppColors.primary.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw stage background
    canvas.drawRect(
      Rect.fromLTWH(50, 50, size.width - 100, size.height - 150),
      stageBg,
    );

    // Draw stage border
    canvas.drawRect(
      Rect.fromLTWH(50, 50, size.width - 100, size.height - 150),
      stageBorder,
    );

    // Draw grid if enabled
    if (preferences.stage.showGrid ?? true) {
      _drawGrid(canvas, size);
    }

    // Draw fixtures
    final fixtureRadius = 8.0 * zoomLevel;
    final fixturePaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.fill;

    int fixtureIndex = 0;
    for (final patch in profile.patches) {
      for (final fixture in patch.fixtures) {
        final x = 100 + (fixtureIndex % 10) * 50;
        final y = 100 + (fixtureIndex ~/ 10) * 50;
        canvas.drawCircle(Offset(x, y), fixtureRadius, fixturePaint);

        // Draw label if enabled
        if (preferences.stage.showLabels ?? true) {
          _drawFixtureLabel(
            canvas,
            fixture,
            Offset(x, y),
          );
        }

        fixtureIndex++;
      }
    }

    // Draw intensity indicator if enabled
    if (preferences.stage.showIntensity ?? true) {
      _drawIntensityIndicators(canvas, size, profile);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.neutral700.withOpacity(0.2)
      ..strokeWidth = 1;

    const gridSpacing = 50;
    final startX = 50.0;
    final startY = 50.0;
    final endX = size.width - 50;
    final endY = size.height - 100;

    // Vertical lines
    for (double x = startX; x <= endX; x += gridSpacing) {
      canvas.drawLine(Offset(x, startY), Offset(x, endY), gridPaint);
    }

    // Horizontal lines
    for (double y = startY; y <= endY; y += gridSpacing) {
      canvas.drawLine(Offset(startX, y), Offset(endX, y), gridPaint);
    }
  }

  void _drawFixtureLabel(
    Canvas canvas,
    Fixture fixture,
    Offset position,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: fixture.name.substring(0, 1),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawIntensityIndicators(Canvas canvas, Size size, DMXProfile profile) {
    // This would show intensity levels for active fixtures
    // For now, we'll just draw a simple bar
    final barHeight = 20.0;
    final barPaint = Paint()
      ..color = AppColors.secondary.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(50, size.height - 70, size.width - 100, barHeight),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(StagePainter oldDelegate) {
    return oldDelegate.profile != profile ||
        oldDelegate.zoomLevel != zoomLevel ||
        oldDelegate.preferences != preferences;
  }
}

class _VisualizerControlPanel extends StatelessWidget {
  final DMXProfile profile;
  final double zoomLevel;

  const _VisualizerControlPanel({
    required this.profile,
    required this.zoomLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localization.translate('stage.fixture_info'),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Chip(
                label: Text('${_countAllFixtures(profile)} Total'),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profile.patches.map((patch) {
              return Chip(
                label: Text(
                  '${patch.name}: ${patch.fixtures.length}',
                ),
                backgroundColor: AppColors.primary.withOpacity(0.2),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  int _countAllFixtures(DMXProfile profile) {
    int count = 0;
    for (var patch in profile.patches) {
      count += patch.fixtures.length;
    }
    return count;
  }
}
