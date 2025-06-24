import 'package:flutter/material.dart';
import 'package:ntsc_ui/pages/basePage.dart';

class SnmpStatusPage extends StatefulWidget {
  @override
  SnmpStatusPageState createState() => SnmpStatusPageState();
}

class SnmpStatusPageState extends State<SnmpStatusPage> {
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
      title: 'SNMP',
      description: 'SNMP Status:',
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
                  children: [SnmpStatusCard()],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SnmpStatusCard extends StatefulWidget {
  @override
  SnmpStatusCardState createState() => SnmpStatusCardState();
}

class SnmpStatusCardState extends State<SnmpStatusCard> {
  @override
  void initState() {
    super.initState();
  }

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
                'SNMP Status Card: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ElevatedButton(onPressed: () => {}, child: Text('SNMP ON/OFF')),
              SizedBox(height: 4),
              ElevatedButton(
                onPressed: () => {},
                child: Text('SNMP Authentication Error Trap'),
              ),
              SizedBox(height: 4),
              ElevatedButton(onPressed: () => {}, child: Text('SysObjID')),
              SizedBox(height: 4),
              ElevatedButton(onPressed: () => {}, child: Text('Contact')),
              SizedBox(height: 4),
              ElevatedButton(onPressed: () => {}, child: Text('Location')),
              SizedBox(height: 4),
              ElevatedButton(onPressed: () => {}, child: Text('Description')),
              SizedBox(height: 4),
              ElevatedButton(
                onPressed: () => {print("hello")},
                child: Text('Updated card feature'),
              ),
              SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}
