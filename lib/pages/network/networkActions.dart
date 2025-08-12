import 'package:flutter/material.dart';
import 'package:ntsc_ui/api/SnmpApi.dart';
import 'package:ntsc_ui/pages/basePage.dart';

import 'package:provider/provider.dart';

class NetworkActionsCard extends StatelessWidget {
  const NetworkActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => {context.read<SnmpApi>().resetSnmpConfig()},
                child: Text('RESTORE DEFAULT NETWORK CONFIGURATION'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NetworkActionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'NETWORK',
      description: 'Actions:',
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Actions
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [NetworkActionsCard()],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
