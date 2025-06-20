import 'package:flutter/material.dart';
import 'package:ntsc_ui/api/LoginApi.dart';
import 'package:ntsc_ui/pages/basePage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

final Uri websiteUrl = Uri.parse('https://novuspower.com');
final Uri phoneUrl = Uri(scheme: 'tel', path: '8168367446');
final Uri emailUrl = Uri(scheme: 'mailto', path: 'support@novuspower.com');

class SupportPage extends StatefulWidget {
  @override
  SupportPageState createState() => SupportPageState();
}

class SupportPageState extends State<SupportPage> {
  @override
  void initState() {
    super.initState();
  }

  //final _formKey = GlobalKey<FormState>();
  //final _usernameController = TextEditingController();
  //final _passwordController = TextEditingController();
  //String? _errorMessage;

  @override
  void dispose() {
    //_usernameController.dispose();
    //_passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginApi>(
      builder: (context, loginApi, _) {
        return BasePage(
          title: 'Support',
          description: 'Service Contacts',
          children: [
            Column(
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        //Expanded(flex: 3, child: Text("Website")),
                        ElevatedButton(
                          onPressed: () => _launchUrl(websiteUrl),
                          child: Text('Visit Our Site'),
                        ),
                        Text(websiteUrl.toString()),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => _launchUrl(phoneUrl),
                          child: Text('Call Us'),
                        ),
                        Text(phoneUrl.toString()),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        //Expanded(flex: 3, child: Text("Email")),
                        ElevatedButton(
                          onPressed: () => _launchUrl(emailUrl),
                          child: Text('Send Us an Email'),
                        ),
                        Text(emailUrl.toString()),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        //Expanded(flex: 3, child: Text("Email")),
                        ElevatedButton(
                          onPressed: () => context.go('/login'),
                          child: Text('Go to Login Page'),
                        ),
                      ],
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

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}


 //   showDialog(
 //     context: context,
 //     builder:
 //         (context) => AlertDialog(
 //           title: Text('Access Denied'),
 //           content: Text('You don\'t have permission to access: $route'),
 //           actions: [
 //             TextButton(
 //               onPressed: () => Navigator.of(context).pop(),
 //               child: Text('OK'),
 //             ),
 //           ],
 //         ),
 //   );