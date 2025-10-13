import 'package:flutter/material.dart';
import 'package:nct/api/SnmpApi.dart';
import 'package:provider/provider.dart';
import 'package:nct/custom/custom.dart';

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
        sysObjIdController.text = snmpApi.sysDetails.SysObjId;
        contactController.text = snmpApi.sysDetails.SysContact;
        locationController.text = snmpApi.sysDetails.SysLocation;
        descriptionController.text = snmpApi.sysDetails.SysDescription;
        return Card(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Info',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        tooltip: "Info",
                        onPressed: _showInfo,
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  LabeledSwitch(
                    myGap: 120,
                    label: "SNMP Enabled",
                    value: snmpApi.sysDetails.Status == "active",
                    onChanged: (bool value) {
                      setState(() {
                        snmpApi.sysDetails.Action = value ? "start" : "stop";
                        snmpApi.editSnmpInfo(snmpApi.sysDetails);
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
                            snmpApi.sysDetails.SysObjId = value;
                            snmpApi.editSnmpInfo(snmpApi.sysDetails);
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
                            snmpApi.sysDetails.SysContact = value;
                            snmpApi.editSnmpInfo(snmpApi.sysDetails);
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
                            snmpApi.sysDetails.SysLocation = value;
                            snmpApi.editSnmpInfo(snmpApi.sysDetails);
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
                            snmpApi.sysDetails.SysDescription = value;
                            snmpApi.editSnmpInfo(snmpApi.sysDetails);
                          },
                          controller: descriptionController,
                          decoration: InputDecoration(isDense: true),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () => {_showRestoreDefaultSNMPConfigDialog()},
                    child: Text('RESTORE DEFAULT CONFIGURATION'),
                  ),
                  //// addd button here
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text("Add, edit, remove and review SNMP")],
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

  void _showRestoreDefaultSNMPConfigDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<SnmpApi>(
          builder: (context, snmpApi, _) {
            return AlertDialog(
              content: Text(
                'Are you sure you want to restore the SNMP config?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    await context.read<SnmpApi>().resetSnmpConfig();
                    Navigator.pop(context);
                  },
                  child: Text('Restore', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
