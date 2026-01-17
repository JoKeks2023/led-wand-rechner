import 'package:flutter/material.dart';
import '../../models/led_models.dart';
import '../../services/localization_service.dart';

class ProjectSelector extends StatelessWidget {
  final Project? currentProject;
  final List<Project> projects;
  final Function(Project) onProjectSelected;
  final VoidCallback onNewProject;

  const ProjectSelector({
    super.key,
    required this.currentProject,
    required this.projects,
    required this.onProjectSelected,
    required this.onNewProject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localization.projectsTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: onNewProject,
                  tooltip: localization.projectsNewProject,
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: projects.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final project = projects[index];
                  final isSelected = currentProject?.id == project.id;

                  return Tooltip(
                    message: project.description ?? project.name,
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(project.name),
                      onSelected: (_) => onProjectSelected(project),
                      onDeleted: () => _showDeleteConfirm(context, project),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localization.commonDelete),
        content: Text(
          '${localization.translate('projects.delete_confirm')}\n\n${project.name}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localization.commonCancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context);
              // Delete project - wird vom Parent-Provider gehandelt
            },
            child: Text(localization.commonDelete),
          ),
        ],
      ),
    );
  }
}
