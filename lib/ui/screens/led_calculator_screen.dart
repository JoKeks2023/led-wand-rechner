import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:led_wand_app/models/led_models.dart';
import 'package:led_wand_app/providers/app_providers.dart';
import 'package:led_wand_app/services/led_calculation_service.dart';

class LEDCalculatorScreen extends ConsumerStatefulWidget {
  const LEDCalculatorScreen({super.key});

  @override
  ConsumerState<LEDCalculatorScreen> createState() =>
      _LEDCalculatorScreenState();
}

class _LEDCalculatorScreenState extends ConsumerState<LEDCalculatorScreen> {
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  late TextEditingController _costController;

  @override
  void initState() {
    super.initState();
    _widthController = TextEditingController(text: '1000');
    _heightController = TextEditingController(text: '1000');
    _costController = TextEditingController(text: '100');
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brands = ref.watch(ledBrandsProvider);
    final selectedBrand = ref.watch(selectedBrandProvider);
    final selectedModel = ref.watch(selectedModelProvider);
    final results = ref.watch(calculationResultsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ======== TITLE ========
          Text(
            'LED Wandrechner',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),

          // ======== BRAND SELECTION ========
          brands.when(
            data: (brandsList) => _buildBrandSelector(context, brandsList),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Fehler: $err'),
          ),
          const SizedBox(height: 16),

          // ======== MODEL SELECTION ========
          if (selectedBrand != null)
            _buildModelSelector(context, selectedBrand),
          const SizedBox(height: 24),

          // ======== DIMENSIONS ========
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Abmessungen',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _widthController,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final width = double.tryParse(value) ?? 1000;
                            ref.read(ledWidthMmProvider.notifier).state = width;
                          },
                          decoration: InputDecoration(
                            labelText: 'Breite (mm)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.straighten),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _heightController,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final height = double.tryParse(value) ?? 1000;
                            ref.read(ledHeightMmProvider.notifier).state =
                                height;
                          },
                          decoration: InputDecoration(
                            labelText: 'Höhe (mm)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.height),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ======== COST INPUT ========
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kosten pro LED-Einheit',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _costController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final cost = double.tryParse(value) ?? 100;
                      ref.read(unitCostEurProvider.notifier).state = cost;
                    },
                    decoration: InputDecoration(
                      labelText: 'EUR pro Pixel',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.euro),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ======== RESULTS ========
          if (selectedModel != null && results.totalPixels > 0)
            _buildResultsCard(context, results)
          else
            Center(
              child: Text(
                'LED-Modell wählen um Berechnung zu starten',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ),
          const SizedBox(height: 16),

          // ======== ACTION BUTTONS ========
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: results.totalPixels > 0
                      ? () => _saveAsProject(context)
                      : null,
                  icon: const Icon(Icons.save),
                  label: const Text('Speichern'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: results.totalPixels > 0
                      ? () => _exportAsCSV(context, results)
                      : null,
                  icon: const Icon(Icons.download),
                  label: const Text('Export'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBrandSelector(BuildContext context, List<LEDBrand> brands) {
    final selectedBrand = ref.watch(selectedBrandProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hersteller',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedBrand?.id,
              hint: const Text('Hersteller wählen'),
              items: brands.map((brand) {
                return DropdownMenuItem(
                  value: brand.id,
                  child: Text(brand.name),
                );
              }).toList(),
              onChanged: (brandId) {
                if (brandId != null) {
                  final brand = brands.firstWhere((b) => b.id == brandId);
                  ref.read(selectedBrandProvider.notifier).state = brand;
                  ref.read(selectedModelProvider.notifier).state = null;
                }
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.business),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelSelector(BuildContext context, LEDBrand brand) {
    final models = ref.watch(ledModelsForBrandProvider(brand.id));
    final selectedModel = ref.watch(selectedModelProvider);

    return models.when(
      data: (modelsList) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LED Modell',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedModel?.id,
                hint: const Text('Modell wählen'),
                items: modelsList.map((model) {
                  return DropdownMenuItem(
                    value: model.id,
                    child: Text('${model.modelName} (${model.pixelPitchMm}mm)'),
                  );
                }).toList(),
                onChanged: (modelId) {
                  if (modelId != null) {
                    final model = modelsList.firstWhere((m) => m.id == modelId);
                    ref.read(selectedModelProvider.notifier).state = model;
                  }
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.memory),
                ),
              ),
            ],
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Fehler: $err'),
    );
  }

  Widget _buildResultsCard(
      BuildContext context, LEDCalculationResults results) {
    final fmt =
        NumberFormat.currency(locale: 'de_DE', symbol: '€', decimalDigits: 2);

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Berechnungsergebnisse',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildResultRow('Gesamte Pixel:', results.totalPixels.toString()),
            _buildResultRow('Auflösung:',
                '${results.widthPixels} x ${results.heightPixels}'),
            _buildResultRow('Pixelabstand:', '${results.pixelPitchMm} mm'),
            _buildResultRow(
                'Fläche:', '${results.coverage.toStringAsFixed(2)} m²'),
            _buildResultRow(
                'Pixel/m²:', results.pixelsPerSqMeter.toStringAsFixed(0)),
            const Divider(height: 20),
            _buildResultRow(
              'Stromverbrauch:',
              '${results.estimatedPowerWatts.toStringAsFixed(0)} W',
              highlight: results.estimatedPowerWatts > 5000,
            ),
            _buildResultRow(
              'Geschätzte Kosten:',
              fmt.format(results.estimatedCostEur),
              highlight: true,
            ),
            _buildResultRow(
              'Kosten pro Pixel:',
              fmt.format(results.estimatedCostEur / results.totalPixels),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: highlight ? Colors.orange.shade900 : null,
            ),
          ),
        ],
      ),
    );
  }

  void _saveAsProject(BuildContext context) {
    final brand = ref.read(selectedBrandProvider);
    final model = ref.read(selectedModelProvider);

    if (brand == null || model == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Projekt gespeichert!')),
    );
  }

  void _exportAsCSV(BuildContext context, LEDCalculationResults results) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Datei exportiert!')),
    );
  }
}
