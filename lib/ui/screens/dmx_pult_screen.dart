import 'package:flutter/material.dart';

class DMXPultScreen extends StatefulWidget {
  const DMXPultScreen({super.key});

  @override
  State<DMXPultScreen> createState() => _DMXPultScreenState();
}

class _Fixture {
  _Fixture({
    required this.id,
    required this.name,
    required this.universe,
    required this.address,
    required this.channels,
    required this.fixtureType,
    this.notes = '',
  });

  final String id;
  final String name;
  final int universe;
  final int address;
  final int channels;
  final String fixtureType; // LED Panel, Moving Head, PAR, etc.
  final String notes;

  int get endAddress => address + channels - 1;

  bool overlapsWith(_Fixture other) {
    if (universe != other.universe) return false;
    return !(endAddress < other.address || address > other.endAddress);
  }
}

class _DMXPultScreenState extends State<DMXPultScreen> {
  final List<_Fixture> _fixtures = [
    _Fixture(
      id: '1',
      name: 'LED Wall Left',
      universe: 1,
      address: 1,
      channels: 48,
      fixtureType: 'LED Panel',
      notes: 'Linke Wand, 16x3 Pixel',
    ),
    _Fixture(
      id: '2',
      name: 'LED Wall Right',
      universe: 1,
      address: 49,
      channels: 48,
      fixtureType: 'LED Panel',
      notes: 'Rechte Wand, 16x3 Pixel',
    ),
    _Fixture(
      id: '3',
      name: 'Front Wash 1',
      universe: 2,
      address: 1,
      channels: 16,
      fixtureType: 'Moving Head',
      notes: 'RGBW mit Zoom',
    ),
  ];

  String _selectedUniverse = 'Alle';
  int _nextFixtureId = 4;

  List<_Fixture> get _filteredFixtures {
    if (_selectedUniverse == 'Alle') return _fixtures;
    final uni = int.tryParse(_selectedUniverse);
    if (uni == null) return _fixtures;
    return _fixtures.where((f) => f.universe == uni).toList();
  }

  List<_Fixture> _getConflicts() {
    final conflicts = <_Fixture>[];
    for (var i = 0; i < _fixtures.length; i++) {
      for (var j = i + 1; j < _fixtures.length; j++) {
        if (_fixtures[i].overlapsWith(_fixtures[j])) {
          if (!conflicts.contains(_fixtures[i])) conflicts.add(_fixtures[i]);
          if (!conflicts.contains(_fixtures[j])) conflicts.add(_fixtures[j]);
        }
      }
    }
    return conflicts;
  }

  @override
  Widget build(BuildContext context) {
    final conflicts = _getConflicts();

    return Scaffold(
      appBar: AppBar(
        title: const Text('DMX Patch Planung'),
        actions: [
          if (conflicts.isNotEmpty)
            IconButton(
              icon: Badge(
                label: Text('${conflicts.length}'),
                child: const Icon(Icons.warning),
              ),
              onPressed: () => _showConflictsDialog(conflicts),
              tooltip: 'Adresskonflikte anzeigen',
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_alt),
            tooltip: 'Universe filtern',
            initialValue: _selectedUniverse,
            onSelected: (value) => setState(() => _selectedUniverse = value),
            itemBuilder: (context) {
              final universes =
                  _fixtures.map((f) => f.universe).toSet().toList()..sort();
              return [
                const PopupMenuItem(
                    value: 'Alle', child: Text('Alle Universes')),
                const PopupMenuDivider(),
                ...universes.map((u) => PopupMenuItem(
                      value: u.toString(),
                      child: Text('Universe $u'),
                    )),
              ];
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportPatch,
            tooltip: 'Patch exportieren',
          ),
        ],
      ),
      body: Column(
        children: [
          if (conflicts.isNotEmpty)
            MaterialBanner(
              backgroundColor: Colors.orange.withValues(alpha: 0.2),
              leading: const Icon(Icons.warning, color: Colors.orange),
              content: Text(
                  '${conflicts.length} Fixture(s) mit Adressüberschneidungen'),
              actions: [
                TextButton(
                  onPressed: () => _showConflictsDialog(conflicts),
                  child: const Text('Details'),
                ),
              ],
            ),
          _buildSummary(),
          const Divider(height: 1),
          Expanded(child: _buildFixtureList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFixtureDialog,
        icon: const Icon(Icons.add),
        label: const Text('Fixture'),
      ),
    );
  }

  Widget _buildSummary() {
    final totalChannels = _fixtures.fold<int>(0, (sum, f) => sum + f.channels);
    final universes = _fixtures.map((f) => f.universe).toSet().length;
    final conflicts = _getConflicts();

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStat('Universes', universes.toString(), Icons.hub),
            _buildStat(
                'Fixtures', _fixtures.length.toString(), Icons.lightbulb),
            _buildStat('Kanäle', totalChannels.toString(),
                Icons.settings_input_component),
            _buildStat(
              'Status',
              conflicts.isEmpty ? 'OK' : '${conflicts.length} Konflikte',
              conflicts.isEmpty ? Icons.check_circle : Icons.warning,
              color: conflicts.isEmpty ? Colors.green : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon,
            color: color ?? Theme.of(context).colorScheme.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildFixtureList() {
    final fixtures = _filteredFixtures;
    final conflicts = _getConflicts().toSet();

    return Column(
      children: [
        if (_selectedUniverse != 'Alle')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                const Icon(Icons.filter_alt, size: 16),
                const SizedBox(width: 8),
                Text('Gefiltert: Universe $_selectedUniverse'),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => _selectedUniverse = 'Alle'),
                  child: const Text('Filter entfernen'),
                ),
              ],
            ),
          ),
        Expanded(
          child: fixtures.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lightbulb_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline),
                      const SizedBox(height: 16),
                      Text(
                        'Keine Fixtures',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Füge dein erstes Fixture hinzu',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: fixtures.length,
                  itemBuilder: (context, index) {
                    final fixture = fixtures[index];
                    final hasConflict = conflicts.contains(fixture);
                    return _buildFixtureTile(fixture, hasConflict);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFixtureTile(_Fixture fixture, bool hasConflict) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: hasConflict ? Colors.orange.withValues(alpha: 0.1) : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: hasConflict
              ? Colors.orange
              : Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            hasConflict ? Icons.warning : Icons.lightbulb,
            color: hasConflict
                ? Colors.white
                : Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Row(
          children: [
            if (hasConflict) ...[
              const Icon(Icons.error, color: Colors.red, size: 18),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Text(
                fixture.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildChip('Universe ${fixture.universe}', Icons.hub),
                _buildChip(
                    '${fixture.address}–${fixture.endAddress}', Icons.pin),
                _buildChip(
                    '${fixture.channels} CH', Icons.settings_input_component),
                _buildChip(fixture.fixtureType, Icons.category),
              ],
            ),
            if (fixture.notes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                fixture.notes,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _showEditFixtureDialog(fixture),
              tooltip: 'Bearbeiten',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: () => _confirmDelete(fixture),
              tooltip: 'Löschen',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }

  void _showAddFixtureDialog() {
    final nameController = TextEditingController();
    final universeController = TextEditingController(text: '1');
    final addressController = TextEditingController(text: '1');
    final channelsController = TextEditingController(text: '16');
    final notesController = TextEditingController();
    String fixtureType = 'LED Panel';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Fixture hinzufügen'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name *',
                      hintText: 'z.B. LED Wall Front',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.label),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: fixtureType,
                    decoration: const InputDecoration(
                      labelText: 'Fixture-Typ',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'LED Panel', child: Text('LED Panel')),
                      DropdownMenuItem(
                          value: 'Moving Head', child: Text('Moving Head')),
                      DropdownMenuItem(value: 'PAR', child: Text('PAR')),
                      DropdownMenuItem(value: 'Wash', child: Text('Wash')),
                      DropdownMenuItem(value: 'Spot', child: Text('Spot')),
                      DropdownMenuItem(value: 'Strobe', child: Text('Strobe')),
                      DropdownMenuItem(
                          value: 'Sonstige', child: Text('Sonstige')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => fixtureType = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: universeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Universe *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.hub),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: addressController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Startadresse *',
                            hintText: '1-512',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.pin),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: channelsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Anzahl Kanäle *',
                      hintText: 'z.B. 16 für RGBW',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.format_list_numbered),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Notizen (optional)',
                      hintText: 'Position, Funktionen, etc.',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bitte Namen eingeben')),
                  );
                  return;
                }

                final fixture = _Fixture(
                  id: (_nextFixtureId++).toString(),
                  name: nameController.text,
                  universe: int.tryParse(universeController.text) ?? 1,
                  address: int.tryParse(addressController.text) ?? 1,
                  channels: int.tryParse(channelsController.text) ?? 16,
                  fixtureType: fixtureType,
                  notes: notesController.text,
                );

                setState(() => _fixtures.add(fixture));
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Fixture "${fixture.name}" hinzugefügt'),
                    action: SnackBarAction(
                      label: 'Rückgängig',
                      onPressed: () {
                        setState(() => _fixtures.remove(fixture));
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Hinzufügen'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditFixtureDialog(_Fixture fixture) {
    final nameController = TextEditingController(text: fixture.name);
    final universeController =
        TextEditingController(text: fixture.universe.toString());
    final addressController =
        TextEditingController(text: fixture.address.toString());
    final channelsController =
        TextEditingController(text: fixture.channels.toString());
    final notesController = TextEditingController(text: fixture.notes);
    String fixtureType = fixture.fixtureType;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Fixture bearbeiten'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.label),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: fixtureType,
                    decoration: const InputDecoration(
                      labelText: 'Fixture-Typ',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'LED Panel', child: Text('LED Panel')),
                      DropdownMenuItem(
                          value: 'Moving Head', child: Text('Moving Head')),
                      DropdownMenuItem(value: 'PAR', child: Text('PAR')),
                      DropdownMenuItem(value: 'Wash', child: Text('Wash')),
                      DropdownMenuItem(value: 'Spot', child: Text('Spot')),
                      DropdownMenuItem(value: 'Strobe', child: Text('Strobe')),
                      DropdownMenuItem(
                          value: 'Sonstige', child: Text('Sonstige')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => fixtureType = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: universeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Universe *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.hub),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: addressController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Startadresse *',
                            hintText: '1-512',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.pin),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: channelsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Anzahl Kanäle *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.format_list_numbered),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Notizen (optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen'),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() => _fixtures.remove(fixture));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Fixture "${fixture.name}" gelöscht')),
                );
              },
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text('Löschen', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bitte Namen eingeben')),
                  );
                  return;
                }

                final index = _fixtures.indexOf(fixture);
                final updated = _Fixture(
                  id: fixture.id,
                  name: nameController.text,
                  universe: int.tryParse(universeController.text) ?? 1,
                  address: int.tryParse(addressController.text) ?? 1,
                  channels: int.tryParse(channelsController.text) ?? 16,
                  fixtureType: fixtureType,
                  notes: notesController.text,
                );

                setState(() => _fixtures[index] = updated);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Fixture "${updated.name}" aktualisiert')),
                );
              },
              icon: const Icon(Icons.save),
              label: const Text('Speichern'),
            ),
          ],
        ),
      ),
    );
  }

  void _showConflictsDialog(List<_Fixture> conflicts) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Adresskonflikte'),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${conflicts.length} Fixture(s) mit Adressüberschneidungen:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: conflicts.length,
                  itemBuilder: (context, index) {
                    final fixture = conflicts[index];
                    final overlaps = conflicts
                        .where((f) => f != fixture && fixture.overlapsWith(f))
                        .toList();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: Colors.orange.withValues(alpha: 0.1),
                      child: ListTile(
                        title: Text(
                          fixture.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Universe ${fixture.universe}: ${fixture.address}–${fixture.endAddress}'),
                            if (overlaps.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Überschneidet sich mit: ${overlaps.map((f) => f.name).join(', ')}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.pop(context);
                            _showEditFixtureDialog(fixture);
                          },
                          tooltip: 'Bearbeiten',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schließen'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(_Fixture fixture) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fixture löschen?'),
        content: Text('Soll "${fixture.name}" wirklich gelöscht werden?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _fixtures.remove(fixture));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Fixture "${fixture.name}" gelöscht'),
                  action: SnackBarAction(
                    label: 'Rückgängig',
                    onPressed: () {
                      setState(() => _fixtures.add(fixture));
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }

  void _exportPatch() {
    if (_fixtures.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keine Fixtures zum Exportieren')),
      );
      return;
    }

    // Generate CSV content
    final buffer = StringBuffer();
    buffer.writeln('Universe,Startadresse,Endadresse,Kanäle,Name,Typ,Notizen');

    final sortedFixtures = List<_Fixture>.from(_fixtures)
      ..sort((a, b) {
        final universeCompare = a.universe.compareTo(b.universe);
        return universeCompare != 0
            ? universeCompare
            : a.address.compareTo(b.address);
      });

    for (final fixture in sortedFixtures) {
      buffer.writeln(
        '${fixture.universe},${fixture.address},${fixture.endAddress},${fixture.channels},"${fixture.name}","${fixture.fixtureType}","${fixture.notes}"',
      );
    }

    // Print to console for debugging (in production, save to file)
    debugPrint('=== DMX PATCH EXPORT ===');
    debugPrint(buffer.toString());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Patch-Liste in Console ausgegeben (CSV)'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
