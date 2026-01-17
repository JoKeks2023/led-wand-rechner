import 'package:flutter/material.dart';

class DMXPultScreen extends StatefulWidget {
  const DMXPultScreen({super.key});

  @override
  State<DMXPultScreen> createState() => _DMXPultScreenState();
}

class _Fixture {
  _Fixture({
    required this.name,
    required this.universe,
    required this.address,
    required this.channels,
    required this.layer,
  });

  final String name;
  final int universe;
  final int address;
  final int channels;
  final String layer;
}

class _DMXPultScreenState extends State<DMXPultScreen> {
  final List<_Fixture> _fixtures = [
    _Fixture(
      name: 'LED Wall Left',
      universe: 1,
      address: 1,
      channels: 48,
      layer: 'Video',
    ),
    _Fixture(
      name: 'LED Wall Right',
      universe: 1,
      address: 49,
      channels: 48,
      layer: 'Video',
    ),
    _Fixture(
      name: 'Front Wash 1',
      universe: 2,
      address: 1,
      channels: 16,
      layer: 'Light',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DMX Patch Planung'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Patch als CSV exportieren',
            onPressed: _exportPatch,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFixtureDialog,
        icon: const Icon(Icons.add),
        label: const Text('Fixture hinzufügen'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummary(),
          const SizedBox(height: 16),
          _buildFixtureList(),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final universes = _fixtures.map((f) => f.universe).toSet();
    final totalChannels = _fixtures.fold<int>(0, (sum, f) => sum + f.channels);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildStat(
              icon: Icons.hub,
              label: 'Universen',
              value: universes.length.toString(),
              color: Colors.indigo,
            ),
            _buildStat(
              icon: Icons.lightbulb_outline,
              label: 'Fixtures',
              value: _fixtures.length.toString(),
              color: Colors.blue,
            ),
            _buildStat(
              icon: Icons.format_list_numbered,
              label: 'Kanäle',
              value: totalChannels.toString(),
              color: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildFixtureList() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('Patch-Liste'),
            subtitle: const Text('Nur Planung, keine Live-Steuerung'),
          ),
          const Divider(height: 1),
          ..._fixtures.map((f) => _buildFixtureTile(f)),
        ],
      ),
    );
  }

  Widget _buildFixtureTile(_Fixture f) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.withValues(alpha: 0.1),
        child: const Icon(Icons.light_mode, color: Colors.blue),
      ),
      title: Text(
        f.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Row(
        children: [
          _buildChip('Uni ${f.universe}'),
          _buildChip('Addr ${f.address}'),
          _buildChip('${f.channels}ch'),
          _buildChip(f.layer),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () => _removeFixture(f),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8, top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showAddFixtureDialog() {
    final nameController = TextEditingController();
    final universeController = TextEditingController(text: '1');
    final addressController = TextEditingController(text: '1');
    final channelsController = TextEditingController(text: '16');
    final layerController = TextEditingController(text: 'Light');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fixture hinzufügen'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: universeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Universe',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: addressController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Startadresse',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: channelsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Kanäle',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: layerController,
                decoration: const InputDecoration(
                  labelText: 'Layer (z.B. Video, Light)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              final fixture = _Fixture(
                name: nameController.text.isEmpty
                    ? 'Fixture ${_fixtures.length + 1}'
                    : nameController.text,
                universe: int.tryParse(universeController.text) ?? 1,
                address: int.tryParse(addressController.text) ?? 1,
                channels: int.tryParse(channelsController.text) ?? 16,
                layer: layerController.text.isEmpty
                    ? 'Light'
                    : layerController.text,
              );
              setState(() => _fixtures.add(fixture));
              Navigator.pop(context);
            },
            child: const Text('Hinzufügen'),
          ),
        ],
      ),
    );
  }

  void _removeFixture(_Fixture fixture) {
    setState(() => _fixtures.remove(fixture));
  }

  void _exportPatch() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Patch exportiert (CSV-Stub).'),
      ),
    );
  }
}
