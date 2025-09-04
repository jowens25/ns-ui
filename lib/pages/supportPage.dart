import 'package:flutter/material.dart';
import 'package:nct/pages/basePage.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

final Uri websiteUrl = Uri.parse('https://novuspower.com');
final Uri phoneUrl = Uri(scheme: 'tel', path: '8168367446');
final Uri emailUrl = Uri(scheme: 'mailto', path: 'support@novuspower.com');

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  SupportPageState createState() => SupportPageState();
}

class SupportPageState extends State<SupportPage> {
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
      title: 'Support',
      description: 'Service Contacts',
      children: [SupportCard()],
    );
  }
}

class SupportCard extends StatelessWidget {
  const SupportCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () => _launchUrl(websiteUrl),
                  child: Text('Visit Our Site'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () => _launchUrl(phoneUrl),
                  child: Text('Call Us'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () => _launchUrl(emailUrl),
                  child: Text('Send Us an Email'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () => context.go('/login'),
                  child: Text('Go to Login Page'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
