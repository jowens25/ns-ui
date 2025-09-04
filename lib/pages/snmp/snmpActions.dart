import 'package:flutter/material.dart';
import 'package:nct/api/SnmpApi.dart';
import 'package:nct/pages/basePage.dart';

import 'package:provider/provider.dart';

class SnmpActionsCard extends StatelessWidget {
  const SnmpActionsCard({super.key});

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
                child: Text('RESTORE DEFAULT SNMP CONFIGURATION'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SnmpActionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'SNMP',
      description: 'SNMP Actions:',
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
                  children: [SnmpActionsCard()],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
