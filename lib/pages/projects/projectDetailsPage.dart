import 'package:flutter/material.dart';
import 'package:ntsc_ui/pages/basePage.dart';
import 'package:go_router/go_router.dart';

class ProjectDetailsPage extends StatelessWidget {
  final String projectId;
  final String projectName;

  const ProjectDetailsPage({
    Key? key,
    required this.projectId,
    required this.projectName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: '$projectName Details',
      description:
          'This is $projectName with all its configurations and settings.',
      children: [
        Text(
          'Project ID: $projectId',
          style: TextStyle(fontFamily: 'monospace'),
        ),
        SizedBox(height: 8),
        if (projectId == 'project1')
          ElevatedButton(
            onPressed: () => context.go('/projects/project1/files'),
            child: Text('View Files'),
          ),
      ],
    );
  }
}
