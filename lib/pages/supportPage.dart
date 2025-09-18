import 'package:flutter/material.dart';
import 'package:nct/custom/custom.dart';
import 'package:nct/main.dart';
import 'package:nct/pages/basePage.dart';
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
          SizedBox(height: 10),
          StaticLabeledText(
            label: "  Website",
            myGap: 150,
            myText: "novuspower.com",
          ),
          SizedBox(height: 10),
          StaticLabeledText(
            label: "  Phone",
            myGap: 150,
            myText: "(816) 836-7446",
          ),
          SizedBox(height: 10),
          StaticLabeledText(
            label: "  Email",
            myGap: 150,
            myText: "support@novuspower.com",
          ),
          StaticLabeledText(
            label: "  Version",
            myGap: 150,
            myText: frontendVersion,
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
