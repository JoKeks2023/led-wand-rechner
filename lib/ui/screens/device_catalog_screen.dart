import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_wand_app/providers/app_providers.dart';
import 'package:led_wand_app/ui/theme/app_colors.dart';

class DeviceCatalogScreen extends ConsumerStatefulWidget {
  const DeviceCatalogScreen({super.key});

  @override
  ConsumerState<DeviceCatalogScreen> createState() =>
      _DeviceCatalogScreenState();
}

class _DeviceCatalogScreenState extends ConsumerState<DeviceCatalogScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(deviceCatalogProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerätekatalog'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Suche (Hersteller, Modell, Kategorie)',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: catalog.when(
                data: (data) {
                  final ledPanels =
                      (data['catalog']?['led_panels'] as List?) ?? [];
                  final fixtures =
                      (data['catalog']?['fixtures'] as List?) ?? [];

                  final filteredPanels = ledPanels.where((p) {
                    final text = '${p['brand']} ${p['model']}'.toLowerCase();
                    return text.contains(_query);
                  }).toList();

                  final filteredFixtures = fixtures.where((f) {
                    final text =
                        '${f['manufacturer']} ${f['name']} ${f['category']}'
                            .toLowerCase();
                    return text.contains(_query);
                  }).toList();

                  return ListView(
                    children: [
                      _SectionHeader(title: 'LED-Panels'),
                      if (filteredPanels.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('Keine Panels gefunden'),
                        )
                      else
                        ...filteredPanels.map((p) => _PanelTile(panel: p)),
                      const SizedBox(height: 12),
                      _SectionHeader(title: 'Fixtures'),
                      if (filteredFixtures.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('Keine Fixtures gefunden'),
                        )
                      else
                        ...filteredFixtures
                            .map((f) => _FixtureTile(fixture: f)),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Fehler beim Laden: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _PanelTile extends StatelessWidget {
  final Map panel;
  const _PanelTile({required this.panel});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.grid_on, color: AppColors.primary),
        title: Text('${panel['brand']} ${panel['model']}'),
        subtitle: Text(
            'Pixel Pitch: ${panel['pixel_pitch_mm']} mm, Strom: ${panel['wattage_per_pixel_ma']} mA'),
        trailing: Text(panel['reference'] ?? ''),
      ),
    );
  }
}

class _FixtureTile extends StatelessWidget {
  final Map fixture;
  const _FixtureTile({required this.fixture});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.light, color: AppColors.secondary),
        title: Text('${fixture['manufacturer']} ${fixture['name']}'),
        subtitle: Text(
            'Kategorie: ${fixture['category']}  |  Kanäle: ${fixture['channels']}'),
        onTap: fixture['link'] != null
            ? () => _openLink(context, fixture['link'] as String)
            : null,
      ),
    );
  }

  void _openLink(BuildContext context, String url) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Link: $url')),
    );
  }
}
