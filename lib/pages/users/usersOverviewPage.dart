import 'package:flutter/material.dart';
import 'package:nct/pages/basePage.dart';
import 'package:nct/pages/users/usersManagement.dart';

class UsersOverviewPage extends StatelessWidget {
  const UsersOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'User Management',
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.start,
            children: [
              SizedBox(
                width: 500,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [UsersManagementCard()],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
