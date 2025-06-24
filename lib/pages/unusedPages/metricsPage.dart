import 'package:flutter/material.dart';
import 'package:ntsc_ui/pages/basePage.dart';

class MetricsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Metrics',
      description: 'Real-time application metrics and performance indicators.',
      children: [
        ListTile(
          leading: Icon(Icons.speed),
          title: Text('Response Time'),
          subtitle: Text('Average: 120ms'),
        ),
        ListTile(
          leading: Icon(Icons.memory),
          title: Text('Memory Usage'),
          subtitle: Text('Current: 45%'),
        ),
      ],
    );
  }
}
