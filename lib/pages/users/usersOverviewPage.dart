import 'package:flutter/material.dart';
import 'package:nct/pages/basePage.dart';
import 'package:nct/pages/users/usersActions.dart';
import 'package:nct/pages/users/usersManagement.dart';

class UsersOverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'User Management',
      description: 'Manage users, actions and authentication',
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.start,
            children: [
              SizedBox(
                width: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [UsersActionsCard(), SizedBox(height: 16)],
                ),
              ),
              SizedBox(
                width: 500,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [UsersManagementCard(), SizedBox(height: 16)],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
