import 'package:flutter/material.dart';
import 'package:ntsc_ui/pages/basePage.dart';

class ReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Reports',
      description: 'Generate and view detailed reports.',
      children: [
        ListTile(
          leading: Icon(Icons.assignment),
          title: Text('User Activity Report'),
          subtitle: Text('Last generated: 2 hours ago'),
        ),
        ListTile(
          leading: Icon(Icons.trending_up),
          title: Text('Performance Report'),
          subtitle: Text('Last generated: 1 day ago'),
        ),
      ],
    );
  }
}
