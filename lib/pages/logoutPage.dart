import 'package:flutter/material.dart';
import 'package:nct/api/PublicApi.dart';
import 'package:nct/pages/basePage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LogoutPage extends StatefulWidget {
  const LogoutPage({super.key});

  @override
  LogoutPageState createState() => LogoutPageState();
}

class LogoutPageState extends State<LogoutPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Logout',
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
                  children: [LogoutCard()],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LogoutCard extends StatelessWidget {
  const LogoutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PublicApi>(
      builder: (context, userApi, _) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                userApi.logout();
                userApi.clearUser();
                context.go('/login');
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
