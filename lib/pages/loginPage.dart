import 'package:flutter/material.dart';
import 'package:nct/api/PublicApi.dart';
import 'package:go_router/go_router.dart';
import 'package:nct/api/TimeApi.dart';
import 'package:provider/provider.dart';
import 'package:nct/myDrawer.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginCardState createState() => LoginCardState();
}

class LoginCardState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
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
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: SvgPicture.asset('images/NOVUS_LOGO.svg', width: 180),
              padding: EdgeInsets.all(0),
              constraints: const BoxConstraints(),
              onPressed: () {
                launchUrl(Uri.parse("https://novuspower.com"));
              },
            ),
            Consumer<PublicApi>(
              builder: (context, userApi, _) {
                return Text(
                  userApi.currentUser?.name != null
                      ? "Welcome, ${userApi.currentUser!.name}"
                      : "Welcome",
                );
              },
            ),
            Consumer<TimeApi>(
              builder: (context, timeApi, _) {
                return Text(timeApi.time);
              },
            ),
          ],
        ),
      ),

      body: Consumer<PublicApi>(
        builder: (context, userApi, _) {
          return SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: 300,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(labelText: 'Username'),
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                      ),

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

                              context.go('/network');
                            } catch (e) {}
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Password',

                          suffixIcon: ExcludeFocus(
                            child: IconButton(
                              iconSize: 14,
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
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
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

                              context.go('/network');
                            } catch (e) {}
                          }
                        },
                        child: Text('Login'),
                      ),

                      SizedBox(height: 8),

                      ElevatedButton(
                        onPressed: () {
                          context.go('/support');
                          print("help me ");
                        },
                        child: Text('Support'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
