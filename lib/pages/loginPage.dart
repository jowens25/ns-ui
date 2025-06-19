import 'package:flutter/material.dart';
import 'package:ntsc_ui/api/LoginApi.dart';
import 'package:ntsc_ui/pages/basePage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

// Page Components - now much simpler since routes are auto-generated
class LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    //final loginApi = Provider.of<LoginApi>(context, listen: false);
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

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginApi>(
      builder: (context, loginApi, _) {
        return BasePage(
          title: 'Login',
          description: 'Please Login',
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
                            //                    Text(
                            //                      'Active Projects',
                            //                      style: TextStyle(fontWeight: FontWeight.bold),
                            //                    ),
                            //                    SizedBox(height: 8),
                            //                    Text(
                            //                      '4',
                            //                      style: Theme.of(context).textTheme.headlineMedium,
                            //                    ),
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: 'Username',
                              ),
                              validator:
                                  (value) => value!.isEmpty ? 'Required' : null,
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                              ),
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
                                    final response = await loginApi.login(
                                      _usernameController.text,
                                      _passwordController.text,
                                    );
                                    // Handle successful login (e.g., save token, navigate)
                                    context.go('/dashboard');

                                    _errorMessage =
                                        'Login successful: $response';
                                  } catch (e) {
                                    setState(() {
                                      _errorMessage = e.toString();
                                    });
                                  }
                                }
                              },
                              child: Text('Sign In'),
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
                SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Register',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '???',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
