import 'package:flutter/material.dart';
import 'package:ntsc_ui/pages/basePage.dart';

class GeneralSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'General Settings',
      description: 'Configure your basic application preferences.',
      children: [
        ListTile(
          title: Text('Theme'),
          subtitle: Text('Dark'),
          trailing: Switch(value: true, onChanged: null),
        ),
        ListTile(
          title: Text('Language'),
          subtitle: Text('English'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
        ),
        ListTile(
          title: Text('Auto-save'),
          subtitle: Text('Automatically save changes'),
          trailing: Switch(value: true, onChanged: (value) {}),
        ),
      ],
    );
  }
}
