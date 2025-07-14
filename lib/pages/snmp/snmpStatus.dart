import 'package:flutter/material.dart';
import 'package:ntsc_ui/api/SnmpApi.dart';
import 'package:ntsc_ui/pages/basePage.dart';
import 'package:provider/provider.dart';

class SnmpStatusPage extends StatefulWidget {
  @override
  SnmpStatusPageState createState() => SnmpStatusPageState();
}

class SnmpStatusPageState extends State<SnmpStatusPage> {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'SNMP',
      description: 'Status:',
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
  final sysObjIdController = TextEditingController();
  final contactController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  @override
  void initState() {
    super.initState();
    context.read<SnmpApi>().readSnmpInfo();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //context.read<SnmpApi>().getStatus();
      //context.read<SnmpApi>().getSysDetails();
    });
  }

  @override
  void dispose() {
    sysObjIdController.dispose();
    contactController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SnmpApi>(
      builder: (context, snmpApi, _) {
        var details = snmpApi.sysDetails;

        sysObjIdController.text = details.SysObjId;
        contactController.text = details.SysContact;
        locationController.text = details.SysLocation;
        descriptionController.text = details.SysDescription;
        return Card(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  LabeledSwitch(
                    label: "SNMP Enabled",
                    value: details.Status == "active",
                    onChanged: (bool value) {
                      setState(() {
                        details.Action = value ? "start" : "stop";
                        snmpApi.editSnmpInfo(details);
                      });
                    },
                  ),
                  SizedBox(height: 12),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          "SysObjectID",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        child: TextField(
                          onSubmitted: (value) {
                            details.SysObjId = value;
                            snmpApi.editSnmpInfo(details);
                          },
                          controller: sysObjIdController,
                          decoration: InputDecoration(isDense: true),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          "Contact",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        child: TextField(
                          onSubmitted: (value) {
                            details.SysContact = value;
                            snmpApi.editSnmpInfo(details);
                          },
                          controller: contactController,
                          decoration: InputDecoration(isDense: true),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          "Location",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        child: TextField(
                          onSubmitted: (value) {
                            details.SysLocation = value;
                            snmpApi.editSnmpInfo(details);
                          },
                          controller: locationController,
                          decoration: InputDecoration(isDense: true),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          "Description",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        child: TextField(
                          onSubmitted: (value) {
                            details.SysDescription = value;
                            snmpApi.editSnmpInfo(details);
                          },
                          controller: descriptionController,
                          decoration: InputDecoration(isDense: true),
                        ),
                      ),
                    ],
                  ),
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
        Text('$label', style: const TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(width: 70),
        Transform.scale(
          scale: 0.60,
          child: Switch(value: value, onChanged: onChanged),
        ),
      ],
    );
  }
}

class LabeledText extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  const LabeledText({
    Key? key,
    required this.label,
    required this.controller,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: onSubmitted,
              decoration: InputDecoration(isDense: true),
            ),
          ),
        ],
      ),
    );
  }
}
