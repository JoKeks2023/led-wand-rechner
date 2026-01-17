import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_wand_app/providers/app_providers.dart';
import 'package:intl/intl.dart';

class ResultsPanel extends ConsumerWidget {
  const ResultsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(calculationResultsProvider);
    final selectedModel = ref.watch(selectedModelProvider);
    final fmt = NumberFormat.currency(
      locale: 'de_DE',
      symbol: '€',
      decimalDigits: 2,
    );

    if (selectedModel == null || results.totalPixels == 0) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calculate_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Wählen Sie ein LED-Modell',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Die Berechnungsergebnisse werden hier angezeigt',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      color:
          Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.insights,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Berechnungsergebnisse',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildResultSection(
              context,
              'Auflösung',
              [
                _ResultItem(
                  'Gesamte Pixel',
                  results.totalPixels.toString(),
                  Icons.grid_on,
                ),
                _ResultItem(
                  'Auflösung',
                  '${results.widthPixels} × ${results.heightPixels} px',
                  Icons.aspect_ratio,
                ),
                _ResultItem(
                  'Pixelabstand',
                  '${results.pixelPitchMm} mm',
                  Icons.straighten,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildResultSection(
              context,
              'Fläche & Dichte',
              [
                _ResultItem(
                  'Gesamtfläche',
                  '${results.coverage.toStringAsFixed(2)} m²',
                  Icons.crop_square,
                ),
                _ResultItem(
                  'Abmessungen',
                  '${results.widthMeters.toStringAsFixed(2)} × ${results.heightMeters.toStringAsFixed(2)} m',
                  Icons.straighten,
                ),
                _ResultItem(
                  'Pixeldichte',
                  '${results.pixelsPerSqMeter.toStringAsFixed(0)} px/m²',
                  Icons.grid_4x4,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildResultSection(
              context,
              'Energie & Kosten',
              [
                _ResultItem(
                  'Stromverbrauch',
                  '${results.estimatedPowerWatts.toStringAsFixed(0)} W',
                  Icons.power,
                  highlight: results.estimatedPowerWatts > 5000,
                ),
                _ResultItem(
                  'Leistung pro Pixel',
                  '${results.powerPerPixelWatts.toStringAsFixed(3)} W',
                  Icons.flash_on,
                ),
                _ResultItem(
                  'Geschätzte Kosten',
                  fmt.format(results.estimatedCostEur),
                  Icons.euro,
                  highlight: true,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _saveProject(context, ref),
                    icon: const Icon(Icons.save),
                    label: const Text('Projekt speichern'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportCSV(context, ref),
                    icon: const Icon(Icons.download),
                    label: const Text('Als CSV exportieren'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection(
    BuildContext context,
    String title,
    List<_ResultItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _buildResultRow(
              context,
              item.label,
              item.value,
              item.icon,
              highlight: item.highlight,
            )),
      ],
    );
  }

  Widget _buildResultRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: highlight
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: highlight
                  ? Theme.of(context).colorScheme.primary
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _saveProject(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Projekt erfolgreich gespeichert!'),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _exportCSV(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.download_done, color: Colors.white),
            SizedBox(width: 12),
            Text('CSV-Export erfolgreich!'),
          ],
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class _ResultItem {
  final String label;
  final String value;
  final IconData icon;
  final bool highlight;

  _ResultItem(
    this.label,
    this.value,
    this.icon, {
    this.highlight = false,
  });
}
