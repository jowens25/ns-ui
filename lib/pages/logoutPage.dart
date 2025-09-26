import 'package:flutter/material.dart';
import 'package:nct/api/UserApi.dart';
import 'package:nct/pages/basePage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LogoutPage extends StatefulWidget {
  @override
  LogoutPageState createState() => LogoutPageState();
}

// Page Components - now much simpler since routes are auto-generated
class LogoutPageState extends State<LogoutPage> {
  @override
  void initState() {
    super.initState();
    //final loginApi = Provider.of<LoginApi>(context, listen: false);
  }

  final _formKey = GlobalKey<FormState>();

  String? errorMessage;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserApi>(
      builder: (context, userApi, _) {
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
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            userApi.logout();
                            userApi.clearUser();
                            // Handle successful login (e.g., save token, navigate)
                            context.go('/login');
                          },
                          child: Text('Log out'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
