import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_wand_app/providers/app_providers.dart';

class LEDInputForm extends ConsumerStatefulWidget {
  const LEDInputForm({super.key});

  @override
  ConsumerState<LEDInputForm> createState() => _LEDInputFormState();
}

class _LEDInputFormState extends ConsumerState<LEDInputForm> {
  late TextEditingController _widthController;
  late TextEditingController _heightController;

  @override
  void initState() {
    super.initState();
    _widthController = TextEditingController(text: '1000');
    _heightController = TextEditingController(text: '1000');
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brands = ref.watch(ledBrandsProvider);
    final selectedBrand = ref.watch(selectedBrandProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'LED Konfiguration',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            brands.when(
              data: (brandsList) => _buildBrandDropdown(brandsList),
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Fehler: $err'),
            ),
            if (selectedBrand != null) ...[
              const SizedBox(height: 16),
              _buildModelDropdown(selectedBrand),
            ],
            const SizedBox(height: 20),
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
                    decoration: const InputDecoration(
                      labelText: 'Breite (mm)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.straighten),
                    ),
                    onChanged: (value) {
                      final width = double.tryParse(value) ?? 1000;
                      ref.read(ledWidthMmProvider.notifier).state = width;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Höhe (mm)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.height),
                    ),
                    onChanged: (value) {
                      final height = double.tryParse(value) ?? 1000;
                      ref.read(ledHeightMmProvider.notifier).state = height;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandDropdown(List<dynamic> brandsList) {
    final selectedBrand = ref.watch(selectedBrandProvider);
    return DropdownButtonFormField<String>(
      initialValue: selectedBrand?.id,
      decoration: const InputDecoration(
        labelText: 'Hersteller',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.business),
      ),
      items: brandsList.map((brand) {
        return DropdownMenuItem<String>(
          value: brand.id,
          child: Text(brand.name),
        );
      }).toList(),
      onChanged: (brandId) {
        if (brandId != null) {
          final brand = brandsList.firstWhere((b) => b.id == brandId);
          ref.read(selectedBrandProvider.notifier).state = brand;
          ref.read(selectedModelProvider.notifier).state = null;
        }
      },
    );
  }

  Widget _buildModelDropdown(dynamic brand) {
    final models = ref.watch(ledModelsForBrandProvider(brand.id));
    final selectedModel = ref.watch(selectedModelProvider);

    return models.when(
      data: (modelsList) => DropdownButtonFormField<String>(
        initialValue: selectedModel?.id,
        decoration: const InputDecoration(
          labelText: 'LED Modell',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.memory),
        ),
        items: modelsList.map((model) {
          return DropdownMenuItem<String>(
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
      ),
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('Fehler: $err'),
    );
  }
}
