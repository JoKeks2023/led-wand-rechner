import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/led_models.dart';
import '../../providers/app_providers.dart';
import '../../services/localization_service.dart';
import '../widgets/sync_status_indicator.dart';
import '../widgets/project_selector.dart';
import '../widgets/led_input_form.dart';
import '../widgets/results_panel.dart';
import '../widgets/auth_drawer.dart';
import '../widgets/modern_components.dart';
import '../theme/app_colors.dart';

class LEDCalculatorScreen extends StatefulWidget {
  const LEDCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<LEDCalculatorScreen> createState() => _LEDCalculatorScreenState();
}

class _LEDCalculatorScreenState extends State<LEDCalculatorScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localization.appTitle),
            Text(
              localization.appSubtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Consumer<ConnectivityProvider>(
                builder: (context, connectivity, _) {
                  return SyncStatusIndicator(isOnline: connectivity.isOnline);
                },
              ),
            ),
          ),
        ],
      ),
      drawer: const AuthDrawer(),
      body: SafeArea(
        child: Consumer2<ProjectsProvider, LEDDataProvider>(
          builder: (context, projectsProvider, ledDataProvider, _) {
            if (projectsProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (projectsProvider.projects.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.layers_outlined,
                      size: 64,
                      color: AppColors.neutral400,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      localization.translate('projects.empty_state'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    ModernButton(
                      label: localization.projectsNewProject,
                      icon: Icons.add,
                      onPressed: () => _showNewProjectDialog(context),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                spacing: 16,
                children: [
                  // Project Selector
                  ProjectSelector(
                    currentProject: projectsProvider.currentProject,
                    projects: projectsProvider.projects,
                    onProjectSelected: (project) {
                      projectsProvider.setCurrentProject(project);
                    },
                    onNewProject: () => _showNewProjectDialog(context),
                  ),

                  // LED Input Form
                  LEDInputForm(
                    project: projectsProvider.currentProject!,
                    brands: ledDataProvider.brands,
                    onProjectUpdated: (updatedProject) {
                      projectsProvider.updateProject(updatedProject);
                    },
                  ),

                  // Results Panel
                  if (projectsProvider.currentProject?.resultsJson != null)
                    ResultsPanel(
                      results:
                          projectsProvider.currentProject!.resultsJson!,
                      project: projectsProvider.currentProject!,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showNewProjectDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localization.projectsNewProject),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: localization.projectsProjectName,
            border: const OutlineInputBorder(),
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
                final newProject = LEDProject(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  description: '',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  ledWallCount: 1,
                  brands: {},
                  resultsJson: {},
                );
                context.read<ProjectsProvider>().addProject(newProject);
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
