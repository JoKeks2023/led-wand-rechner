import 'package:flutter/material.dart';

class DMXSettingsScreen extends StatefulWidget {
  const DMXSettingsScreen({super.key});

  @override
  State<DMXSettingsScreen> createState() => _DMXSettingsScreenState();
}

class _DMXSettingsScreenState extends State<DMXSettingsScreen> {
  int _defaultUniverse = 1;
  int _safetyGapChannels = 4;
  bool _autoPackAddresses = true;
  bool _enforce512Limit = true;
  String _notes = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DMX Planungs-Parameter'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPatchRulesCard(),
          const SizedBox(height: 16),
          _buildDefaultsCard(),
          const SizedBox(height: 16),
          _buildNotesCard(),
        ],
      ),
    );
  }

  Widget _buildPatchRulesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.rule,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Patch-Regeln',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Universumsgrenze strikt einhalten (512ch)'),
              subtitle: const Text('Erinnerung bei Überschreitung anzeigen'),
              value: _enforce512Limit,
              onChanged: (v) => setState(() => _enforce512Limit = v),
            ),
            SwitchListTile(
              title: const Text('Adressen automatisch packen'),
              subtitle: const Text(
                  'Lücken minimieren und Überschneidungen vermeiden'),
              value: _autoPackAddresses,
              onChanged: (v) => setState(() => _autoPackAddresses = v),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.space_bar),
              title: const Text('Sicherheitsabstand zwischen Fixtures'),
              subtitle: Text('$_safetyGapChannels Kanäle frei lassen'),
              trailing: DropdownButton<int>(
                value: _safetyGapChannels,
                onChanged: (v) {
                  if (v != null) setState(() => _safetyGapChannels = v);
                },
                items: const [0, 2, 4, 8, 16]
                    .map((e) =>
                        DropdownMenuItem<int>(value: e, child: Text('$e ch')))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tune,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Standardwerte',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.hub),
              title: const Text('Standard-Universe'),
              trailing: DropdownButton<int>(
                value: _defaultUniverse,
                onChanged: (v) {
                  if (v != null) setState(() => _defaultUniverse = v);
                },
                items: List.generate(4, (i) => i + 1)
                    .map((e) => DropdownMenuItem<int>(
                        value: e, child: Text('Universe $e')))
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Diese Werte werden beim Hinzufügen neuer Fixtures in der Patch-Ansicht vorausgefüllt.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.note_alt_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Planungsnotizen',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText:
                    'Hinweise für Lichtdesigner, Patch-Strategien, Ansprechpartner ...',
              ),
              onChanged: (v) => setState(() => _notes = v),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save),
                label: const Text('Speichern'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Planungsparameter gespeichert (${_notes.length} Zeichen Notizen)'),
      ),
    );
  }
}
