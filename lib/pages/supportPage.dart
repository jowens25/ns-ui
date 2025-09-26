import 'package:flutter/material.dart';
import 'package:nct/custom/custom.dart';
import 'package:nct/main.dart';
import 'package:nct/pages/basePage.dart';
import 'package:web/web.dart' as web;

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
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.start,
            children: [
              SizedBox(
                width: 500,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [SupportCard()],
                ),
              ),
            ],
          ),
        ),
      ],
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(width: 16),

              Expanded(
                child: Text(
                  'Contact:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                tooltip: "Info",
                onPressed: () => _showInfo(context),
              ),
            ],
          ),
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
          SizedBox(height: 10),

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

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text("Host"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(web.window.location.origin)],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text("Close"),
              ),
            ],
          ),
    );
  }
}
