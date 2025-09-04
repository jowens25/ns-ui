import 'package:flutter/material.dart';
import 'package:nct/pages/basePage.dart';

class SecuritySettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Security Settings',
      description: 'Manage your privacy and security preferences.',
      children: [
        ListTile(
          title: Text('Two-factor Authentication'),
          subtitle: Text('Extra security for your account'),
          trailing: Switch(value: true, onChanged: (value) {}),
        ),
        ListTile(
          title: Text('Session Timeout'),
          subtitle: Text('30 minutes'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
        ),
        ListTile(
          title: Text('Password Strength'),
          subtitle: Text('Strong'),
          trailing: Icon(Icons.check_circle, color: Colors.green),
        ),
      ],
    );
  }
}
