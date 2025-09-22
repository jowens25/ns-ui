import 'package:flutter/material.dart';
import 'package:nct/api/UserApi.dart';
import 'package:nct/pages/basePage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:web/web.dart' as web;

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Login',
      description: '',
      children: [
        Row(children: [Expanded(child: LoginCard())]),
      ],
    );
  }
}

class LoginCard extends StatefulWidget {
  @override
  LoginCardState createState() => LoginCardState();
}

class LoginCardState extends State<LoginCard> {
  @override
  void initState() {
    super.initState();
    context.read<UserApi>().getCurrentUserFromToken(UserApi.getToken());
  }

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserApi>(
      builder: (context, userApi, _) {
        return Row(
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
                        Text(
                          'Login card',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(labelText: 'Username'),
                          validator:
                              (value) => value!.isEmpty ? 'Required' : null,
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          validator:
                              (value) => value!.isEmpty ? 'Required' : null,
                        ),
                        SizedBox(height: 16),
                        if (userApi.authResponse != null)
                          Text(
                            userApi.authResponse!,
                            style: TextStyle(color: Colors.red),
                          ),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                User user = User.fromJson({
                                  'username': _usernameController.text,
                                  'password': _passwordController.text,
                                });
                                await userApi.login(user);

                                context.read<UserApi>().getCurrentUserFromToken(
                                  UserApi.getToken(),
                                );

                                //await userApi.login(
                                //  _usernameController.text,
                                //  _passwordController.text,
                                //);
                                context.go('/dashboard');

                                //print("error: $_errorMessage");
                                //print("is logged in???? ${userApi.isLoggedIn}");
                                // print("token: ${userApi.getToken()}");
                              } catch (e) {}
                            }
                          },
                          child: Text('Login ' + web.window.location.origin),
                        ),

                        SizedBox(height: 8),

                        Text(
                          'Support',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),

                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: Text('Reset Password'),
                                    content: Text(
                                      'You can reset the administrator password using the maintenance port on the front of the unit: resetpw',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.of(context).pop(),
                                        child: Text('OK'),
                                      ),
                                    ],
                                  ),
                            );
                          },
                          child: Text('Forgot Username / Password'),
                        ),
                        SizedBox(height: 8),

                        ElevatedButton(
                          onPressed: () {
                            context.go('/support');
                            print("help me ");
                          },
                          child: Text('Contact'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  //void setCookie(String name, String value, [int? days]) {
  //  String expires = '';
  //  if (days != null) {
  //    final date = DateTime.now().add(Duration(days: days));
  //    expires = '; expires=${date.toUtc().toIso8601String()}';
  //  }
  //  document.cookie = '$name=$value$expires; path=/';
  //}
}
