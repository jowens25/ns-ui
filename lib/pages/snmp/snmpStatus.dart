import 'package:flutter/material.dart';
import 'package:ntsc_ui/api/LoginApi.dart';
import 'package:ntsc_ui/pages/basePage.dart';
import 'package:provider/provider.dart';

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
  bool light0 = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loginApi = context.read<LoginApi>();
      loginApi.getSnmpStatus();
      //_searchController.addListener(() {
      //  loginApi.searchUsers(_searchController.text);
      //});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginApi>(
      builder: (context, loginApi, _) {
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

                  LabeledSwitch(
                    label: "SNMP Status",
                    value: loginApi.snmpStatus,
                    onChanged: (bool value) {
                      setState(() {
                        //loginApi.snmpStatus = value;
                        loginApi.setSnmpStatus(value);
                      });
                    },
                  ),

                  Text(loginApi.snmpStatus ? "active" : "inactive"),

                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => {},
                    child: Text('SNMP ON/OFF'),
                  ),
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
                  ElevatedButton(
                    onPressed: () => {},
                    child: Text('Description'),
                  ),
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
      },
    );
  }
}

class LabeledSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const LabeledSwitch({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Transform.scale(
          scale: 0.60,
          child: Switch(value: value, onChanged: onChanged),
        ),
      ],
    );
  }
}
