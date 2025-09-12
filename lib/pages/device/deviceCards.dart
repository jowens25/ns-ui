import 'package:flutter/material.dart';
import 'package:nct/api/DeviceApi.dart';
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

class DeviceStatusCard extends StatefulWidget {
  @override
  DeviceStatusCardState createState() => DeviceStatusCardState();
}

class DeviceStatusCardState extends State<DeviceStatusCard> {
  final sysObjIdController = TextEditingController();
  final contactController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // context.read<DeviceApi>().readDeviceInfo();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //context.read<DeviceApi>().getStatus();
      //context.read<DeviceApi>().getSysDetails();
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
    return Consumer<DeviceApi>(
      builder: (context, deviceApi, _) {
        var details = deviceApi.sysDetails;

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
                    'Channels:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Channels(),
                  SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget Channels() {
    const List<List<String>> tableValues = [
      ["test", "test", "test"],
      ["test", "test", "test"],
      ["test", "test", "test"],
    ];
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      children: [
        for (var row in tableValues)
          TableRow(
            children: [
              for (var cell in row)
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Text(
                      cell,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
