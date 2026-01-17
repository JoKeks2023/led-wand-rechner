import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class DemoLEDCalculatorScreen extends StatefulWidget {
  const DemoLEDCalculatorScreen({super.key});

  @override
  State<DemoLEDCalculatorScreen> createState() =>
      _DemoLEDCalculatorScreenState();
}

class _DemoLEDCalculatorScreenState extends State<DemoLEDCalculatorScreen> {
  final TextEditingController _widthController =
      TextEditingController(text: '10');
  final TextEditingController _heightController =
      TextEditingController(text: '5');
  String _ledType = 'P10';

  @override
  Widget build(BuildContext context) {
    final width = double.tryParse(_widthController.text) ?? 10;
    final height = double.tryParse(_heightController.text) ?? 5;
    final totalPixels = (width * height).toInt();

    return Scaffold(
      appBar: AppBar(
        title: const Text('LED Wand Rechner'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LED Dimensionen',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _widthController,
              decoration: InputDecoration(
                labelText: 'Breite (m)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _heightController,
              decoration: InputDecoration(
                labelText: 'Höhe (m)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Text(
              'LED Typ',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['P10', 'P6', 'P5', 'P4', 'P2.5']
                  .map((type) => FilterChip(
                        label: Text(type),
                        selected: _ledType == type,
                        onSelected: (selected) =>
                            setState(() => _ledType = type),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 32),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Berechnung',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Breite:'),
                        Text('${width.toStringAsFixed(2)} m',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Höhe:'),
                        Text('${height.toStringAsFixed(2)} m',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('LED Typ:'),
                        Text(_ledType,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Fläche:'),
                        Text('${(width * height).toStringAsFixed(2)} m²',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Gesamte Pixel:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '$totalPixels',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() {
                      _widthController.text = '10';
                      _heightController.text = '5';
                      _ledType = 'P10';
                    }),
                    child: const Text('Zurücksetzen'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Projekt gespeichert!')),
                    ),
                    child: const Text('Speichern'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }
}
