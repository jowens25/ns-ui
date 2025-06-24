import 'package:flutter/material.dart';
import 'package:ntsc_ui/pages/basePage.dart';

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
              Text(
                'SNMP ACTIONS Card: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => {},
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
