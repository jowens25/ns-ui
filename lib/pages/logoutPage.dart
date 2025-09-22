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

    return Consumer< UserApi>(
      builder: (context, userApi, _) {
        return BasePage(
          title: 'Logout',
          description: 'Please Logout',
          children: [
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //
                            //
                            //
                            //
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    userApi.logout();
                                    userApi.clearUser();
                                    // Handle successful login (e.g., save token, navigate)
                                    context.go('/login');
                                  } catch (e) {
                                    setState(() {
                                      errorMessage = e.toString();
                                    });
                                  }
                                }
                              },
                              child: Text('Log out'),
                            ),
                            //
                            //
                            //
                            //
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                //SizedBox(width: 16),
                //Expanded(
                //  child: Card(
                //    child: Padding(
                //      padding: EdgeInsets.all(16),
                //      child: Column(
                //        crossAxisAlignment: CrossAxisAlignment.start,
                //        children: [
                //          Text(
                //            'Recent Activity',
                //            style: TextStyle(fontWeight: FontWeight.bold),
                //          ),
                //          SizedBox(height: 8),
                //          Text(
                //            '12 updates',
                //            style: Theme.of(context).textTheme.headlineMedium,
                //          ),
                //        ],
                //      ),
                //    ),
                //  ),
                //),
              ],
            ),
          ],
        );
      },
    );
  }
}
