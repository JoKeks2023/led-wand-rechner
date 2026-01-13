import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/dmx_models.dart';
import '../../models/dmx_preferences.dart';
import '../../providers/app_providers.dart';
import '../../services/localization_service.dart';
import '../theme/app_colors.dart';
import '../widgets/modern_components.dart';

class DMXSettingsScreen extends StatefulWidget {
  const DMXSettingsScreen({Key? key}) : super(key: key);

  @override
  State<DMXSettingsScreen> createState() => _DMXSettingsScreenState();
}

class _DMXSettingsScreenState extends State<DMXSettingsScreen>
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
        title: Text(localization.translate('dmx.settings')),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(
              icon: const Icon(Icons.wifi),
              text: localization.translate('dmx.settings.connection'),
            ),
            Tab(
              icon: const Icon(Icons.dashboard),
              text: localization.translate('dmx.settings.patching'),
            ),
            Tab(
              icon: const Icon(Icons.stage),
              text: localization.translate('dmx.settings.stage'),
            ),
            Tab(
              icon: const Icon(Icons.file_download),
              text: localization.translate('dmx.settings.export'),
            ),
            Tab(
              icon: const Icon(Icons.speed),
              text: localization.translate('dmx.settings.performance'),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ConnectionTab(),
          _PatchingTab(),
          _StageTab(),
          _ExportTab(),
          _PerformanceTab(),
        ],
      ),
    );
  }
}

// ==================== CONNECTION TAB ====================
class _ConnectionTab extends StatefulWidget {
  const _ConnectionTab();

  @override
  State<_ConnectionTab> createState() => _ConnectionTabState();
}

class _ConnectionTabState extends State<_ConnectionTab> {
  late TextEditingController _ipController;
  late TextEditingController _portController;
  late TextEditingController _timeoutController;

  @override
  void initState() {
    super.initState();
    final prefs = context.read<DMXPreferencesProvider>().preferences;
    _ipController =
        TextEditingController(text: prefs.connection.consoleIpAddress ?? '');
    _portController =
        TextEditingController(text: (prefs.connection.consolePort ?? 7000).toString());
    _timeoutController = TextEditingController(
        text: (prefs.connection.connectionTimeout ?? 5000).toString());
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    _timeoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DMXPreferencesProvider>(
      builder: (context, prefsProvider, _) {
        final connection = prefsProvider.preferences.connection;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              // Connection Method
              _SectionHeader(title: localization.translate('dmx.settings.connection_method')),
              ModernCard(
                child: Column(
                  spacing: 12,
                  children: [
                    ModernSwitch(
                      label: localization.translate('dmx.settings.auto_discovery'),
                      value: connection.useAutoDiscovery ?? true,
                      onChanged: (value) {
                        prefsProvider.updateConnectionSettings(
                          connection.copyWith(useAutoDiscovery: value),
                        );
                      },
                      description: localization
                          .translate('dmx.settings.auto_discovery_desc'),
                    ),
                    ModernDivider(),
                    ModernSwitch(
                      label: localization.translate('dmx.settings.mdns'),
                      value: connection.useMDNS ?? true,
                      onChanged: (value) {
                        prefsProvider.updateConnectionSettings(
                          connection.copyWith(useMDNS: value),
                        );
                      },
                      description:
                          localization.translate('dmx.settings.mdns_desc'),
                    ),
                    ModernDivider(),
                    ModernSwitch(
                      label: localization.translate('dmx.settings.manual_ip'),
                      value: connection.useManualIP ?? false,
                      onChanged: (value) {
                        prefsProvider.updateConnectionSettings(
                          connection.copyWith(useManualIP: value),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Manual IP Configuration
              if (connection.useManualIP ?? false) ...[
                _SectionHeader(title: localization.translate('dmx.settings.manual_configuration')),
                ModernCard(
                  child: Column(
                    spacing: 16,
                    children: [
                      ModernInput(
                        label: localization.translate('dmx.settings.console_ip'),
                        hint: '192.168.1.100',
                        controller: _ipController,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          prefsProvider.updateConnectionSettings(
                            connection.copyWith(consoleIpAddress: value),
                          );
                        },
                      ),
                      ModernInput(
                        label: localization.translate('dmx.settings.console_port'),
                        hint: '7000',
                        controller: _portController,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          prefsProvider.updateConnectionSettings(
                            connection.copyWith(consolePort: int.tryParse(value)),
                          );
                        },
                      ),
                      ModernInput(
                        label: localization
                            .translate('dmx.settings.connection_timeout'),
                        hint: '5000',
                        controller: _timeoutController,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          prefsProvider.updateConnectionSettings(
                            connection.copyWith(
                              connectionTimeout: int.tryParse(value),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],

              // Connection Status
              _SectionHeader(title: localization.translate('dmx.settings.connection_status')),
              Consumer<GrandMA3ConnectionProvider>(
                builder: (context, connProvider, _) {
                  final isConnected = connProvider.isConnected;
                  return ModernCard(
                    backgroundColor: isConnected
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: isConnected
                                ? AppColors.success
                                : AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isConnected
                              ? localization
                                  .translate('dmx.settings.connected')
                              : localization
                                  .translate('dmx.settings.disconnected'),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// ==================== PATCHING TAB ====================
class _PatchingTab extends StatelessWidget {
  const _PatchingTab();

  @override
  Widget build(BuildContext context) {
    return Consumer2<DMXPreferencesProvider, DMXServiceProvider>(
      builder: (context, prefsProvider, dmxService, _) {
        final patching = prefsProvider.preferences.patching;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              _SectionHeader(title: localization.translate('dmx.settings.patching_mode')),
              ModernCard(
                child: Column(
                  spacing: 12,
                  children: [
                    ModernSwitch(
                      label: localization.translate('dmx.settings.auto_patch'),
                      value: patching.useAutoPatching ?? true,
                      onChanged: (value) {
                        prefsProvider.updatePatchingSettings(
                          patching.copyWith(useAutoPatching: value),
                        );
                      },
                      description:
                          localization.translate('dmx.settings.auto_patch_desc'),
                    ),
                    ModernDivider(),
                    ModernSwitch(
                      label: localization.translate('dmx.settings.fixture_merging'),
                      value: patching.allowFixtureMerging ?? false,
                      onChanged: (value) {
                        prefsProvider.updatePatchingSettings(
                          patching.copyWith(allowFixtureMerging: value),
                        );
                      },
                    ),
                  ],
                ),
              ),
              _SectionHeader(title: localization.translate('dmx.settings.channel_allocation')),
              ModernCard(
                child: Column(
                  spacing: 16,
                  children: [
                    _ChannelAllocationOption(
                      title: localization.translate('dmx.settings.sequential'),
                      description:
                          localization.translate('dmx.settings.sequential_desc'),
                      selected:
                          patching.channelAllocationMode == 'sequential',
                      onTap: () {
                        prefsProvider.updatePatchingSettings(
                          patching.copyWith(
                            channelAllocationMode: 'sequential',
                          ),
                        );
                      },
                    ),
                    ModernDivider(),
                    _ChannelAllocationOption(
                      title: localization.translate('dmx.settings.sparse'),
                      description:
                          localization.translate('dmx.settings.sparse_desc'),
                      selected: patching.channelAllocationMode == 'sparse',
                      onTap: () {
                        prefsProvider.updatePatchingSettings(
                          patching.copyWith(channelAllocationMode: 'sparse'),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ==================== STAGE TAB ====================
class _StageTab extends StatelessWidget {
  const _StageTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<DMXPreferencesProvider>(
      builder: (context, prefsProvider, _) {
        final stage = prefsProvider.preferences.stage;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              _SectionHeader(title: localization.translate('dmx.settings.stage_layout')),
              ModernCard(
                child: Column(
                  spacing: 16,
                  children: [
                    ModernInput(
                      label: localization.translate('dmx.settings.stage_width'),
                      hint: '12',
                      controller: null,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        prefsProvider.updateStageSettings(
                          stage.copyWith(stageWidth: double.tryParse(value)),
                        );
                      },
                    ),
                    ModernInput(
                      label: localization.translate('dmx.settings.stage_depth'),
                      hint: '8',
                      controller: null,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        prefsProvider.updateStageSettings(
                          stage.copyWith(stageDepth: double.tryParse(value)),
                        );
                      },
                    ),
                  ],
                ),
              ),
              _SectionHeader(title: localization.translate('dmx.settings.visualization')),
              ModernCard(
                child: Column(
                  spacing: 12,
                  children: [
                    ModernSwitch(
                      label: localization.translate('dmx.settings.show_grid'),
                      value: stage.showGrid ?? true,
                      onChanged: (value) {
                        prefsProvider.updateStageSettings(
                          stage.copyWith(showGrid: value),
                        );
                      },
                    ),
                    ModernDivider(),
                    ModernSwitch(
                      label: localization.translate('dmx.settings.show_labels'),
                      value: stage.showLabels ?? true,
                      onChanged: (value) {
                        prefsProvider.updateStageSettings(
                          stage.copyWith(showLabels: value),
                        );
                      },
                    ),
                    ModernDivider(),
                    ModernSwitch(
                      label: localization.translate('dmx.settings.show_intensity'),
                      value: stage.showIntensity ?? true,
                      onChanged: (value) {
                        prefsProvider.updateStageSettings(
                          stage.copyWith(showIntensity: value),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ==================== EXPORT TAB ====================
class _ExportTab extends StatelessWidget {
  const _ExportTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<DMXPreferencesProvider>(
      builder: (context, prefsProvider, _) {
        final export = prefsProvider.preferences.export;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              _SectionHeader(title: localization.translate('dmx.settings.export_format')),
              ModernCard(
                child: Column(
                  spacing: 12,
                  children: [
                    ModernSwitch(
                      label: 'GrandMA 3 XML',
                      value: export.exportFormats?.contains('grandma3') ?? false,
                      onChanged: (value) {
                        final formats =
                            export.exportFormats?.toList() ?? [];
                        if (value) {
                          formats.add('grandma3');
                        } else {
                          formats.remove('grandma3');
                        }
                        prefsProvider.updateExportSettings(
                          export.copyWith(exportFormats: formats),
                        );
                      },
                      description: 'Export as GrandMA 3 show file',
                    ),
                    ModernDivider(),
                    ModernSwitch(
                      label: 'Standard DMX',
                      value: export.exportFormats?.contains('dmx') ?? false,
                      onChanged: (value) {
                        final formats =
                            export.exportFormats?.toList() ?? [];
                        if (value) {
                          formats.add('dmx');
                        } else {
                          formats.remove('dmx');
                        }
                        prefsProvider.updateExportSettings(
                          export.copyWith(exportFormats: formats),
                        );
                      },
                      description: 'Standard DMX 512 format',
                    ),
                  ],
                ),
              ),
              _SectionHeader(title: localization.translate('dmx.settings.export_options')),
              ModernCard(
                child: Column(
                  spacing: 12,
                  children: [
                    ModernSwitch(
                      label: localization.translate('dmx.settings.include_metadata'),
                      value: export.includeMetadata ?? true,
                      onChanged: (value) {
                        prefsProvider.updateExportSettings(
                          export.copyWith(includeMetadata: value),
                        );
                      },
                    ),
                    ModernDivider(),
                    ModernSwitch(
                      label: localization.translate('dmx.settings.include_effects'),
                      value: export.includeEffects ?? true,
                      onChanged: (value) {
                        prefsProvider.updateExportSettings(
                          export.copyWith(includeEffects: value),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ==================== PERFORMANCE TAB ====================
class _PerformanceTab extends StatelessWidget {
  const _PerformanceTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<DMXPreferencesProvider>(
      builder: (context, prefsProvider, _) {
        final performance = prefsProvider.preferences.performance;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              _SectionHeader(title: localization.translate('dmx.settings.performance_tuning')),
              ModernCard(
                child: Column(
                  spacing: 16,
                  children: [
                    _PerformanceSlider(
                      label: localization
                          .translate('dmx.settings.update_frequency'),
                      value:
                          (performance.updateFrequencyHz ?? 50).toDouble(),
                      min: 10,
                      max: 200,
                      onChanged: (value) {
                        prefsProvider.updatePerformanceSettings(
                          performance.copyWith(updateFrequencyHz: value.toInt()),
                        );
                      },
                      unit: 'Hz',
                    ),
                    ModernDivider(),
                    _PerformanceSlider(
                      label: localization.translate('dmx.settings.max_fixtures'),
                      value:
                          (performance.maxSimultaneousFixtures ?? 1000)
                              .toDouble(),
                      min: 100,
                      max: 5000,
                      step: 100,
                      onChanged: (value) {
                        prefsProvider.updatePerformanceSettings(
                          performance.copyWith(
                            maxSimultaneousFixtures: value.toInt(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              _SectionHeader(title: localization.translate('dmx.settings.caching')),
              ModernCard(
                child: Column(
                  spacing: 12,
                  children: [
                    ModernSwitch(
                      label: localization.translate('dmx.settings.enable_caching'),
                      value: performance.enableCaching ?? true,
                      onChanged: (value) {
                        prefsProvider.updatePerformanceSettings(
                          performance.copyWith(enableCaching: value),
                        );
                      },
                      description:
                          localization.translate('dmx.settings.caching_desc'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ==================== HELPER WIDGETS ====================

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _ChannelAllocationOption extends StatelessWidget {
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _ChannelAllocationOption({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Radio<bool>(
            value: true,
            groupValue: selected,
            onChanged: (_) => onTap(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final double? step;
  final ValueChanged<double> onChanged;
  final String? unit;

  const _PerformanceSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.step,
    required this.onChanged,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              '${value.toStringAsFixed(0)} ${unit ?? ''}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: step != null ? ((max - min) / step!).toInt() : null,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
