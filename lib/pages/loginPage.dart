import 'package:flutter/material.dart';
import 'package:nct/api/PublicApi.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginCardState createState() => LoginCardState();
}

class LoginCardState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    //context.read<PublicApi>().getCurrentUserFromToken(PublicApi.getToken());
  }

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PublicApi>(
      builder: (context, userApi, _) {
        return Container(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Login: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 16),

                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(labelText: 'Username'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),

                    SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      onFieldSubmitted: (value) async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            User user = User.fromJson({
                              'username': _usernameController.text,
                              'password': _passwordController.text,
                            });
                            await userApi.login(user);

                            userApi.getCurrentUserFromToken(
                              PublicApi.getToken(),
                            );

                            context.go('/');
                          } catch (e) {}
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: ExcludeFocus(
                          child: IconButton(
                            iconSize: 16,
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
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

                            userApi.getCurrentUserFromToken(
                              PublicApi.getToken(),
                            );

                            //await userApi.login(
                            //  _usernameController.text,
                            //  _passwordController.text,
                            //);
                            context.go('/');

                            //print("error: $_errorMessage");
                            //print("is logged in???? ${userApi.isLoggedIn}");
                            // print("token: ${userApi.getToken()}");
                          } catch (e) {}
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
                          builder: (context) => AlertDialog(
                            title: Text('Reset Password'),
                            content: Text(
                              'reset default admin password using the maintenance port on the front of the unit: \nsudo ns resetpw',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text('Reset Password'),
                    ),
                    SizedBox(height: 8),

                    ElevatedButton(
                      onPressed: () {
                        context.go('/support');
                        print("help me ");
                      },
                      child: Text('Contact'),
                    ),
                  ], ////////////////////////
                ),
              ),
            ),
          ),
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
