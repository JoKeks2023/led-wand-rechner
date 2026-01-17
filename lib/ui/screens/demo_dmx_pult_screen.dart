import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class DemoDMXPultScreen extends StatefulWidget {
  const DemoDMXPultScreen({Key? key}) : super(key: key);

  @override
  State<DemoDMXPultScreen> createState() => _DemoDMXPultScreenState();
}

class _DemoDMXPultScreenState extends State<DemoDMXPultScreen> {
  String? _selectedProfileId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DMX Pult'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Studio Main'),
                  selected: _selectedProfileId == '1',
                  onSelected: (s) =>
                      setState(() => _selectedProfileId = s ? '1' : null),
                ),
                FilterChip(
                  label: const Text('Event Setup'),
                  selected: _selectedProfileId == '2',
                  onSelected: (s) =>
                      setState(() => _selectedProfileId = s ? '2' : null),
                ),
                FilterChip(
                  label: const Text('Outdoor Rig'),
                  selected: _selectedProfileId == '3',
                  onSelected: (s) =>
                      setState(() => _selectedProfileId = s ? '3' : null),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_selectedProfileId != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedProfileId == '1'
                            ? 'Studio Main'
                            : _selectedProfileId == '2'
                                ? 'Event Setup'
                                : 'Outdoor Rig',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoColumn(
                              'Patches', _selectedProfileId == '1' ? '4' : '8'),
                          _buildInfoColumn('Fixtures',
                              _selectedProfileId == '1' ? '24' : '64'),
                          _buildInfoColumn('Universes', '1'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              child: const Text('Bearbeiten'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              child: const Text('Löschen'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ] else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.grid_on,
                      size: 64,
                      color: AppColors.neutral300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Wähle ein Profil',
                      style: TextStyle(
                        color: AppColors.neutral600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Neues Profil erstellt!')),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.neutral600,
          ),
        ),
      ],
    );
  }
}
