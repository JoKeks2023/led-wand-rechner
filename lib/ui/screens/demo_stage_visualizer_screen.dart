import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class DemoStageVisualizerScreen extends StatefulWidget {
  const DemoStageVisualizerScreen({Key? key}) : super(key: key);

  @override
  State<DemoStageVisualizerScreen> createState() =>
      _DemoStageVisualizerScreenState();
}

class _DemoStageVisualizerScreenState extends State<DemoStageVisualizerScreen> {
  double _zoomLevel = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bühnen Visualizer'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Toolbar
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.zoom_out),
                      onPressed: () => setState(() =>
                          _zoomLevel = (_zoomLevel - 0.1).clamp(0.5, 3.0)),
                    ),
                    Text('${(_zoomLevel * 100).toStringAsFixed(0)}%'),
                    IconButton(
                      icon: const Icon(Icons.zoom_in),
                      onPressed: () => setState(() =>
                          _zoomLevel = (_zoomLevel + 0.1).clamp(0.5, 3.0)),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.fullscreen),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const Divider(height: 0),

          // Stage Canvas
          Expanded(
            child: Container(
              color: AppColors.backgroundLight,
              child: Stack(
                children: [
                  // Stage Background
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    margin: const EdgeInsets.all(24),
                    child: CustomPaint(
                      painter: StageGridPainter(zoomLevel: _zoomLevel),
                      child: Container(),
                    ),
                  ),

                  // Fixture Overlays
                  Positioned(
                    left: 50,
                    top: 80,
                    child: Container(
                      width: 40 * _zoomLevel,
                      height: 40 * _zoomLevel,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.7),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'F1',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12 * _zoomLevel,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 120,
                    top: 100,
                    child: Container(
                      width: 40 * _zoomLevel,
                      height: 40 * _zoomLevel,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondary.withOpacity(0.7),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'F2',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12 * _zoomLevel,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Legend
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Legende',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('Aktiv'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.secondary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('Idle'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Info Panel
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Studio Main',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '4 Patches • 24 Fixtures',
                        style: TextStyle(color: AppColors.neutral600),
                      ),
                    ],
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Details'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StageGridPainter extends CustomPainter {
  final double zoomLevel;

  StageGridPainter({required this.zoomLevel});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.neutral200
      ..strokeWidth = 0.5;

    final gridSize = 40.0 * zoomLevel;

    // Draw grid
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw center lines
    final centerPaint = Paint()
      ..color = AppColors.neutral300
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      centerPaint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(StageGridPainter oldDelegate) {
    return oldDelegate.zoomLevel != zoomLevel;
  }
}
