import 'package:flutter/material.dart';
import 'package:nct/api/DeviceApi.dart';
import 'package:nct/pages/basePage.dart';

import 'package:provider/provider.dart';

class DeviceActionsCard extends StatelessWidget {
  const DeviceActionsCard({super.key});

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
              Text('Flash', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed:
                    () => {context.read<DeviceApi>().resetDeviceConfig()},
                child: Text('Save current settings'),
              ),
              SizedBox(height: 8),

              ElevatedButton(
                onPressed:
                    () => {context.read<DeviceApi>().resetDeviceConfig()},
                child: Text('Restore default settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DeviceActionsPage extends StatelessWidget {
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
                  children: [DeviceActionsCard()],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
