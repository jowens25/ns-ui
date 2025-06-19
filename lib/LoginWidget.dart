import 'package:flutter/material.dart';
import 'package:ntsc_ui/LoginApi.dart';
import 'package:provider/provider.dart';

class LoginWidget extends StatefulWidget {
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  @override
  void initState() {
    super.initState();
    final loginApi = Provider.of<LoginApi>(context, listen: false);
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
        return Card(
          elevation: 4,
          margin: EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Login',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
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
                              final response = await loginApi.login(
                                _usernameController.text,
                                _passwordController.text,
                              );
                              // Handle successful login (e.g., save token, navigate)
                              _errorMessage = 'Login successful: $response';
                            } catch (e) {
                              setState(() {
                                _errorMessage = e.toString();
                              });
                            }
                          }
                        },
                        child: Text('Sign In'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
