import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/dmx_models.dart';
import '../../providers/app_providers.dart';
import '../../services/localization_service.dart';
import '../theme/app_colors.dart';
import '../widgets/modern_components.dart';

class DMXPultScreen extends StatefulWidget {
  const DMXPultScreen({Key? key}) : super(key: key);

  @override
  State<DMXPultScreen> createState() => _DMXPultScreenState();
}

class _DMXPultScreenState extends State<DMXPultScreen> {
  String? _selectedProfileId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(localization.translate('dmx.pult_manager')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateProfileDialog(context),
            tooltip: localization.translate('dmx.create_profile'),
          ),
        ],
      ),
      body: Consumer2<DMXProfilesProvider, DMXServiceProvider>(
        builder: (context, profilesProvider, dmxService, _) {
          final profiles = profilesProvider.profiles;

          if (profiles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.devices_other_outlined,
                    size: 64,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    localization.translate('dmx.no_profiles'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  ModernButton(
                    label: localization.translate('dmx.create_profile'),
                    icon: Icons.add,
                    onPressed: () => _showCreateProfileDialog(context),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile Selection Section
              Text(
                localization.translate('dmx.select_profile'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: profiles.map((profile) {
                  final isSelected = profile.id == _selectedProfileId;
                  return FilterChip(
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedProfileId = selected ? profile.id : null;
                      });
                    },
                    backgroundColor: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surface,
                    label: Text(profile.name),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Selected Profile Details
              if (_selectedProfileId != null) ...[
                _ProfileDetailPanel(
                  profile: profiles.firstWhere(
                    (p) => p.id == _selectedProfileId,
                  ),
                  onUpdate: (updated) {
                    profilesProvider.updateProfile(updated);
                  },
                  onDelete: () {
                    profilesProvider.deleteProfile(_selectedProfileId!);
                    setState(() {
                      _selectedProfileId = null;
                    });
                  },
                ),
              ] else
                Center(
                  child: Text(
                    localization.translate('dmx.select_profile_to_edit'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.neutral500,
                        ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showCreateProfileDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localization.translate('dmx.create_profile')),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: localization.translate('dmx.profile_name'),
            border: const OutlineInputBorder(),
            hintText: 'Main Console',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localization.translate('common.cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final newProfile = DMXProfile(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  description: '',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  patches: [],
                  universes: {},
                );
                context.read<DMXProfilesProvider>().addProfile(newProfile);
                Navigator.pop(context);
              }
            },
            child: Text(localization.translate('common.create')),
          ),
        ],
      ),
    );
  }
}

class _ProfileDetailPanel extends StatelessWidget {
  final DMXProfile profile;
  final Function(DMXProfile) onUpdate;
  final VoidCallback onDelete;

  const _ProfileDetailPanel({
    required this.profile,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        ModernCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Text(
                profile.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (profile.description.isNotEmpty)
                Text(
                  profile.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.neutral600,
                      ),
                ),
              ModernDivider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localization.translate('dmx.patches'),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      Text(
                        '${profile.patches.length}',
                        style:
                            Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localization.translate('dmx.universes'),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      Text(
                        '${profile.universes.length}',
                        style:
                            Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localization.translate('dmx.total_fixtures'),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      Text(
                        '${_countFixtures(profile)}',
                        style:
                            Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        // Patches Section
        if (profile.patches.isNotEmpty) ...[
          Text(
            localization.translate('dmx.patches_list'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          ...profile.patches.map(
            (patch) => _PatchCard(patch: patch),
          ),
        ],

        // Action Buttons
        Row(
          spacing: 12,
          children: [
            Expanded(
              child: ModernButton(
                label: localization.translate('dmx.add_patch'),
                icon: Icons.add,
                onPressed: () => _showAddPatchDialog(context),
              ),
            ),
            ModernButton(
              label: localization.translate('common.delete'),
              icon: Icons.delete,
              variant: ButtonVariant.destructive,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(localization.translate('common.confirm_delete')),
                    content: Text(localization.translate('dmx.delete_profile_confirm')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(localization.translate('common.cancel')),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onDelete();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                        child: Text(localization.translate('common.delete')),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  int _countFixtures(DMXProfile profile) {
    int count = 0;
    for (var patch in profile.patches) {
      count += patch.fixtures.length;
    }
    return count;
  }

  void _showAddPatchDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localization.translate('dmx.add_patch')),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: localization.translate('dmx.patch_name'),
            border: const OutlineInputBorder(),
            hintText: 'Main Patch',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localization.translate('common.cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final newPatch = DMXPatch(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  profileId: profile.id,
                  name: nameController.text,
                  description: '',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  fixtures: [],
                );
                context
                    .read<DMXServiceProvider>()
                    .addPatch(profile.id, newPatch);
                Navigator.pop(context);
              }
            },
            child: Text(localization.translate('common.create')),
          ),
        ],
      ),
    );
  }
}

class _PatchCard extends StatelessWidget {
  final DMXPatch patch;

  const _PatchCard({required this.patch});

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(
            patch.name,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                label: Text(
                  '${patch.fixtures.length} Fixtures',
                ),
                backgroundColor: AppColors.primary.withOpacity(0.2),
              ),
              Icon(
                Icons.arrow_forward,
                size: 20,
                color: AppColors.neutral500,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
