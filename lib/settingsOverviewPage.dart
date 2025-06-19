import 'package:flutter/material.dart';
import 'package:ntsc_ui/basePage.dart';
import 'package:go_router/go_router.dart';

class SettingsOverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Settings Overview',
      description: 'Manage your application settings here.',
      children: [
        ListTile(
          leading: Icon(Icons.tune),
          title: Text('General Settings'),
          subtitle: Text('Basic app preferences'),
          trailing: ElevatedButton(
            onPressed: () => context.go('/settings/general'),
            child: Text('Configure'),
          ),
        ),
        ListTile(
          leading: Icon(Icons.security),
          title: Text('Security Settings'),
          subtitle: Text('Privacy and security options'),
          trailing: ElevatedButton(
            onPressed: () => context.go('/settings/security'),
            child: Text('Configure'),
          ),
        ),
      ],
    );
  }
}
