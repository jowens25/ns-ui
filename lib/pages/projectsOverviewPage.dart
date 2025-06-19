import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ntsc_ui/pages/basePage.dart';

class ProjectsOverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Projects Overview',
      description: 'Here are all your available projects.',
      children: [
        ListTile(
          leading: Icon(Icons.work),
          title: Text('Project Alpha'),
          subtitle: Text('Active development'),
          trailing: ElevatedButton(
            onPressed: () => context.go('/projects/project1'),
            child: Text('View'),
          ),
        ),
        ListTile(
          leading: Icon(Icons.work),
          title: Text('Project Beta'),
          subtitle: Text('Planning phase'),
          trailing: ElevatedButton(
            onPressed: () => context.go('/projects/project2'),
            child: Text('View'),
          ),
        ),
      ],
    );
  }
}
