import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_wand_app/models/led_models.dart';
import 'package:led_wand_app/providers/app_providers.dart';
import 'package:led_wand_app/services/led_calculation_service.dart';
import 'dart:math' as math;

class StageVisualizerScreen extends ConsumerStatefulWidget {
  const StageVisualizerScreen({super.key});

  @override
  ConsumerState<StageVisualizerScreen> createState() =>
      _StageVisualizerScreenState();
}

class _StageVisualizerScreenState extends ConsumerState<StageVisualizerScreen> {
  double _rotationX = -0.3;
  double _rotationY = 0.0;
  double _zoom = 1.0;

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(calculationResultsProvider);
    final selectedModel = ref.watch(selectedModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stage Visualizer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Zurücksetzen',
            onPressed: () {
              setState(() {
                _rotationX = -0.3;
                _rotationY = 0.0;
                _zoom = 1.0;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey[900],
              child: selectedModel == null || results.totalPixels == 0
                  ? _buildEmptyState()
                  : _build3DVisualization(results),
            ),
          ),
          Expanded(
            child: _buildControlPanel(results, selectedModel),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.view_in_ar_outlined,
            size: 80,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'Keine LED-Konfiguration ausgewählt',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Wählen Sie ein LED-Modell im Rechner-Tab',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DVisualization(LEDCalculationResults results) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _rotationY += details.delta.dx * 0.01;
          _rotationX += details.delta.dy * 0.01;
          _rotationX = _rotationX.clamp(-math.pi / 2, math.pi / 2);
        });
      },
      child: CustomPaint(
        painter: _LEDWall3DPainter(
          rotationX: _rotationX,
          rotationY: _rotationY,
          zoom: _zoom,
          widthPixels: results.widthPixels,
          heightPixels: results.heightPixels,
          widthMeters: results.widthMeters,
          heightMeters: results.heightMeters,
        ),
        child: Container(),
      ),
    );
  }

  Widget _buildControlPanel(
      LEDCalculationResults results, LEDModel? selectedModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.straighten,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Ansicht anpassen',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.zoom_out, size: 20),
              Expanded(
                child: Slider(
                  value: _zoom,
                  min: 0.5,
                  max: 2.0,
                  onChanged: (value) {
                    setState(() {
                      _zoom = value;
                    });
                  },
                ),
              ),
              const Icon(Icons.zoom_in, size: 20),
            ],
          ),
          if (selectedModel != null && results.totalPixels > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoChip(
                    Icons.aspect_ratio,
                    '${results.widthPixels}×${results.heightPixels}',
                  ),
                  _buildInfoChip(
                    Icons.straighten,
                    '${results.widthMeters.toStringAsFixed(1)}×${results.heightMeters.toStringAsFixed(1)} m',
                  ),
                  _buildInfoChip(
                    Icons.grid_on,
                    '${results.totalPixels} px',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .primaryContainer
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LEDWall3DPainter extends CustomPainter {
  final double rotationX;
  final double rotationY;
  final double zoom;
  final int widthPixels;
  final int heightPixels;
  final double widthMeters;
  final double heightMeters;

  _LEDWall3DPainter({
    required this.rotationX,
    required this.rotationY,
    required this.zoom,
    required this.widthPixels,
    required this.heightPixels,
    required this.widthMeters,
    required this.heightMeters,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw grid floor
    _drawGrid(canvas, size, centerX, centerY);

    // Draw LED wall
    _drawLEDWall(canvas, size, centerX, centerY);

    // Draw labels
    _drawLabels(canvas, size, centerX, centerY);
  }

  void _drawGrid(Canvas canvas, Size size, double centerX, double centerY) {
    final paint = Paint()
      ..color = Colors.grey[800]!
      ..strokeWidth = 1;

    const gridSize = 10;
    const gridSpacing = 30.0;

    for (int i = -gridSize; i <= gridSize; i++) {
      final offset = i * gridSpacing;
      // Horizontal lines
      canvas.drawLine(
        Offset(centerX - gridSize * gridSpacing, centerY + offset + 100),
        Offset(centerX + gridSize * gridSpacing, centerY + offset + 100),
        paint,
      );
      // Vertical lines
      canvas.drawLine(
        Offset(centerX + offset, centerY - gridSize * gridSpacing + 100),
        Offset(centerX + offset, centerY + gridSize * gridSpacing + 100),
        paint,
      );
    }
  }

  void _drawLEDWall(Canvas canvas, Size size, double centerX, double centerY) {
    final wallWidth = math.min(size.width * 0.6, 400.0) * zoom;
    final aspectRatio = heightMeters / widthMeters;
    final wallHeight = wallWidth * aspectRatio;

    // Transform for 3D rotation
    final cosX = math.cos(rotationX);
    final sinX = math.sin(rotationX);
    final cosY = math.cos(rotationY);
    final sinY = math.sin(rotationY);

    List<Offset> corners = [
      Offset(-wallWidth / 2, -wallHeight / 2),
      Offset(wallWidth / 2, -wallHeight / 2),
      Offset(wallWidth / 2, wallHeight / 2),
      Offset(-wallWidth / 2, wallHeight / 2),
    ];

    // Apply 3D transformation
    final transformedCorners = corners.map((corner) {
      double x = corner.dx;
      double y = corner.dy;
      double z = 0;

      // Rotate around Y axis
      double x1 = x * cosY - z * sinY;
      double z1 = x * sinY + z * cosY;

      // Rotate around X axis
      double y2 = y * cosX - z1 * sinX;

      return Offset(centerX + x1, centerY + y2);
    }).toList();

    // Draw wall
    final wallPaint = Paint()
      ..color = Colors.grey[850]!
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(transformedCorners[0].dx, transformedCorners[0].dy)
      ..lineTo(transformedCorners[1].dx, transformedCorners[1].dy)
      ..lineTo(transformedCorners[2].dx, transformedCorners[2].dy)
      ..lineTo(transformedCorners[3].dx, transformedCorners[3].dy)
      ..close();

    canvas.drawPath(path, wallPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, borderPaint);

    // Draw pixel grid (simplified for performance)
    final pixelPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    const maxGridLines = 20;
    final gridStepW =
        widthPixels > maxGridLines ? (widthPixels / maxGridLines).ceil() : 1;
    final gridStepH =
        heightPixels > maxGridLines ? (heightPixels / maxGridLines).ceil() : 1;

    for (int i = 0; i <= widthPixels; i += gridStepW) {
      final t = i / widthPixels;
      final x1 = transformedCorners[0].dx +
          (transformedCorners[1].dx - transformedCorners[0].dx) * t;
      final y1 = transformedCorners[0].dy +
          (transformedCorners[1].dy - transformedCorners[0].dy) * t;
      final x2 = transformedCorners[3].dx +
          (transformedCorners[2].dx - transformedCorners[3].dx) * t;
      final y2 = transformedCorners[3].dy +
          (transformedCorners[2].dy - transformedCorners[3].dy) * t;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), pixelPaint);
    }

    for (int i = 0; i <= heightPixels; i += gridStepH) {
      final t = i / heightPixels;
      final x1 = transformedCorners[0].dx +
          (transformedCorners[3].dx - transformedCorners[0].dx) * t;
      final y1 = transformedCorners[0].dy +
          (transformedCorners[3].dy - transformedCorners[0].dy) * t;
      final x2 = transformedCorners[1].dx +
          (transformedCorners[2].dx - transformedCorners[1].dx) * t;
      final y2 = transformedCorners[1].dy +
          (transformedCorners[2].dy - transformedCorners[1].dy) * t;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), pixelPaint);
    }
  }

  void _drawLabels(Canvas canvas, Size size, double centerX, double centerY) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Title
    textPainter.text = TextSpan(
      text: 'LED Wand Visualisierung',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(20, 20));

    // Dimensions
    textPainter.text = TextSpan(
      text:
          '${widthMeters.toStringAsFixed(2)}m × ${heightMeters.toStringAsFixed(2)}m',
      style: TextStyle(
        color: Colors.grey[400],
        fontSize: 14,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(20, 45));

    // Resolution
    textPainter.text = TextSpan(
      text: '$widthPixels × $heightPixels Pixel',
      style: TextStyle(
        color: Colors.grey[400],
        fontSize: 14,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(20, 65));
  }

  @override
  bool shouldRepaint(_LEDWall3DPainter oldDelegate) {
    return oldDelegate.rotationX != rotationX ||
        oldDelegate.rotationY != rotationY ||
        oldDelegate.zoom != zoom ||
        oldDelegate.widthPixels != widthPixels ||
        oldDelegate.heightPixels != heightPixels;
  }
}
