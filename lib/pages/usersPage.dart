import 'package:flutter/material.dart';
import 'package:ntsc_ui/pages/basePage.dart';

class UsersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'User Management',
      description:
          'Manage users and their permissions. (This is a restricted page for demo purposes)',
      children: [
        Text(
          'This page is restricted and should not be accessible based on server permissions.',
        ),
      ],
    );
  }
}
