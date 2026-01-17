import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class DemoDMXSettingsScreen extends StatefulWidget {
  const DemoDMXSettingsScreen({Key? key}) : super(key: key);

  @override
  State<DemoDMXSettingsScreen> createState() => _DemoDMXSettingsScreenState();
}

class _DemoDMXSettingsScreenState extends State<DemoDMXSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DMX Einstellungen'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Verbindung'),
            Tab(text: 'Patching'),
            Tab(text: 'Bühne'),
            Tab(text: 'Export'),
            Tab(text: 'Performance'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConnectionTab(),
          _buildPatchingTab(),
          _buildStageTab(),
          _buildExportTab(),
          _buildPerformanceTab(),
        ],
      ),
    );
  }

  Widget _buildConnectionTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Konsole Verbindung',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Konsolen IP',
            hintText: '192.168.1.100',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            labelText: 'Port',
            hintText: '7000',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✓ Verbindung erfolgreich!')),
          ),
          child: const Text('Verbindung testen'),
        ),
      ],
    );
  }

  Widget _buildPatchingTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Patching Einstellungen',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.devices),
            title: const Text('Standard Universum'),
            subtitle: const Text('Universe 1'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('DMX Kanäle pro Universum'),
            subtitle: const Text('512'),
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildStageTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Bühne Einstellungen',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.landscape),
            title: const Text('Bühnenbreite'),
            subtitle: const Text('20 m'),
            onTap: () {},
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.landscape),
            title: const Text('Bühnentiefe'),
            subtitle: const Text('15 m'),
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildExportTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Export Einstellungen',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('CSV Export aktivieren'),
                Switch(
                  value: true,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Performance Einstellungen',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.speed),
            title: const Text('Update Rate'),
            subtitle: const Text('50 FPS'),
            onTap: () {},
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.memory),
            title: const Text('Memory Limit'),
            subtitle: const Text('512 MB'),
            onTap: () {},
          ),
        ),
      ],
    );
  }
}
