import 'package:flutter/material.dart';
import '../../models/led_models.dart';
import '../../services/localization_service.dart';

class ResultsPanel extends StatelessWidget {
  final Map<String, dynamic> results;
  final Project project;

  const ResultsPanel({
    Key? key,
    required this.results,
    required this.project,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Text(
              localization.resultsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),
            _buildResultRow(
              label: localization.resultsPixelDensity,
              value: '${(results['pixelDensityPpi'] ?? 0).toStringAsFixed(2)} PPI',
            ),
            _buildResultRow(
              label: localization.resultsResolution,
              value:
                  '${results['totalPixelsWidth'] ?? 0} × ${results['totalPixelsHeight'] ?? 0} px',
            ),
            _buildResultRow(
              label: localization.resultsTotalPixels,
              value: '${results['totalPixels'] ?? 0}',
            ),
            _buildResultRow(
              label: localization.resultsTotalArea,
              value: '${(results['totalAreaM2'] ?? 0).toStringAsFixed(2)} m²',
            ),
            const Divider(),
            _buildResultRow(
              label: localization.resultsTotalPower,
              value: '${(results['totalPowerWatts'] ?? 0).toStringAsFixed(2)} W',
              highlight: true,
            ),
            _buildResultRow(
              label: localization.resultsTotalCurrent,
              value: '${(results['totalCurrentAmps'] ?? 0).toStringAsFixed(2)} A',
            ),
            _buildResultRow(
              label: localization.translate('results.brightness'),
              value: '${(results['estimatedBrightness'] ?? 0).toStringAsFixed(0)} Lux',
            ),
            _buildResultRow(
              label: localization.translate('results.heat_generation'),
              value: '${(results['heatGenerationW'] ?? 0).toStringAsFixed(2)} W',
            ),
            _buildResultRow(
              label: localization.translate('results.material_weight'),
              value: '${(results['materialWeightKg'] ?? 0).toStringAsFixed(2)} kg',
            ),
            if (results['totalCostEur'] != null) ...[
              const Divider(),
              _buildResultRow(
                label: localization.costTotal,
                value: '€ ${(results['totalCostEur'] ?? 0).toStringAsFixed(2)}',
                highlight: true,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // PDF Export wird später implementiert
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(localization.translate('export.pdf')),
                      ),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: Text(localization.exportPdf),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // CSV Export wird später implementiert
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(localization.translate('export.csv')),
                      ),
                    );
                  },
                  icon: const Icon(Icons.table_chart),
                  label: Text(localization.exportCsv),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow({
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: highlight ? 16 : 14,
            color: highlight ? Colors.green : null,
          ),
        ),
      ],
    );
  }
}
