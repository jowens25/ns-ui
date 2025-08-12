import 'package:flutter/material.dart';
import 'package:ntsc_ui/api/NetworkApi.dart';
import 'package:ntsc_ui/pages/basePage.dart';
import 'package:provider/provider.dart';
import 'package:ntsc_ui/pages/snmp/snmpStatus.dart';

class NetworkStatusPage extends StatefulWidget {
  @override
  NetworkStatusPageState createState() => NetworkStatusPageState();
}

class NetworkStatusPageState extends State<NetworkStatusPage> {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'NETWORK',
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
                  children: [NetworkStatusCard()],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class NetworkStatusCard extends StatefulWidget {
  @override
  NetworkStatusCardState createState() => NetworkStatusCardState();
}

class NetworkStatusCardState extends State<NetworkStatusCard> {
  final sysObjIdController = TextEditingController();
  final contactController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  @override
  void initState() {
    super.initState();
    context.read<NetworkApi>().readNetworkInfo();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //context.read<NetworkApi>().getStatus();
      //context.read<NetworkApi>().getSysDetails();
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
    return Consumer<NetworkApi>(
      builder: (context, networkApi, _) {
        var details = networkApi.sysDetails;

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
                    'Protocols:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  LabeledSwitch(
                    myGap: 200,
                    label: "Telnet",
                    value: details.Status == "active",
                    onChanged: (bool value) {
                      setState(() {
                        details.Action = value ? "start" : "stop";
                        networkApi.editNetworkInfo(details);
                      });
                    },
                  ),
                  LabeledSwitch(
                    myGap: 200,
                    label: "SSH + SFTP",
                    value: details.Status == "active",
                    onChanged: (bool value) {
                      setState(() {
                        details.Action = value ? "start" : "stop";
                        networkApi.editNetworkInfo(details);
                      });
                    },
                  ),
                  LabeledSwitch(
                    myGap: 200,
                    label: "HTTP",
                    value: details.Status == "active",
                    onChanged: (bool value) {
                      setState(() {
                        details.Action = value ? "start" : "stop";
                        networkApi.editNetworkInfo(details);
                      });
                    },
                  ),
                  SizedBox(height: 12),
                  /*
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
                            networkApi.editNetworkInfo(details);
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
                            networkApi.editNetworkInfo(details);
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
                            networkApi.editNetworkInfo(details);
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
                            networkApi.editNetworkInfo(details);
                          },
                          controller: descriptionController,
                          decoration: InputDecoration(isDense: true),
                        ),
                      ),
                    ],
                  ),
                  */
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
