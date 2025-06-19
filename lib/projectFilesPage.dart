import 'package:flutter/material.dart';
import 'package:ntsc_ui/basePage.dart';

class ProjectFilesPage extends StatelessWidget {
  final String projectId;

  const ProjectFilesPage({Key? key, required this.projectId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Project Files',
      description: 'Files for project: $projectId',
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.insert_drive_file),
              title: Text('main.dart'),
              subtitle: Text('Application entry point'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('config.json'),
              subtitle: Text('Configuration file'),
            ),
            ListTile(
              leading: Icon(Icons.description),
              title: Text('README.md'),
              subtitle: Text('Project documentation'),
            ),
            ListTile(
              leading: Icon(Icons.folder),
              title: Text('assets/'),
              subtitle: Text('Asset directory'),
            ),
          ],
        ),
      ],
    );
  }
}
