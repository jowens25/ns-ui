import 'package:flutter/material.dart';
import 'package:ntsc_ui/api/LoginApi.dart';
import 'package:ntsc_ui/pages/basePage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
  }

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Consumer<LoginApi>(
      builder: (context, loginApi, _) {
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
                        if (_errorMessage != null)
                          Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red),
                          ),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                await loginApi.login(
                                  _usernameController.text,
                                  _passwordController.text,
                                );
                                context.go('/dashboard');

                                print(_errorMessage);
                              } catch (e) {
                                setState(() {
                                  _errorMessage = e.toString();
                                });
                              }
                            }
                          },
                          child: Text('Login'),
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
