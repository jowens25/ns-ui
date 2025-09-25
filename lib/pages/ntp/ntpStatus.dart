import 'package:flutter/material.dart';
import 'package:nct/custom/custom.dart';
import 'package:provider/provider.dart';
import 'package:nct/api/NtpApi.dart';

class NtpStatusCard extends StatefulWidget {
  @override
  State<NtpStatusCard> createState() => _NtpStatusCardState();
}

class _NtpStatusCardState extends State<NtpStatusCard> {
  final requestsController = TextEditingController();
  final responsesController = TextEditingController();
  final droppedController = TextEditingController();
  final broadcastsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ntpApi = context.read<NtpApi>();
      //ntpApi.readAll();
      ntpApi.readProperty("status");
      ntpApi.readProperty("requests");
      ntpApi.readProperty("responses");
      ntpApi.readProperty("requests_dropped");
      ntpApi.readProperty("broadcasts");
    });
  }

  @override
  void dispose() {
    requestsController.dispose();
    responsesController.dispose();
    droppedController.dispose();
    broadcastsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NtpApi>(
      builder: (context, ntpApi, _) {
        requestsController.text = ntpApi.ntp['requests'];
        responsesController.text = ntpApi.ntp['responses'];
        droppedController.text = ntpApi.ntp['requests_dropped'];
        broadcastsController.text = ntpApi.ntp['broadcasts'];

        return Card(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),

                  LabeledSwitch(
                    myGap: 146,
                    label: "Enable",
                    value: ntpApi.ntp['status'] == 'enabled',
                    onChanged: (bool value) {
                      ntpApi.ntp['status'] = value ? "enabled" : "disabled";
                      setState(() {
                        ntpApi.writeProperty('status');
                      });
                    },
                  ),

                  ReadOnlyLabeledText(
                    label: "Requests",
                    controller: requestsController,
                    myGap: 150,
                  ),

                  ReadOnlyLabeledText(
                    label: "Responses",
                    controller: responsesController,
                    myGap: 150,
                  ),

                  ReadOnlyLabeledText(
                    label: "Requests Dropped",
                    controller: droppedController,
                    myGap: 150,
                  ),

                  ReadOnlyLabeledText(
                    label: "Broadcasts",
                    controller: broadcastsController,
                    myGap: 150,
                  ),

                  //LabeledSwitch(
                  //  label: "SNMP Enabled",
                  //  value: details.Status == "active",
                  //  onChanged: (bool value) {
                  //    setState(() {
                  //      details.Action = value ? "start" : "stop";
                  //      snmpApi.editSnmpInfo(details);
                  //    });
                  //  },
                  //),

                  //ReadOnlyLabeledText(
                  //  label: "Status",
                  //  controller: versionController,
                  //  onSubmitted: (value) {},
                  //),
                  //ReadOnlyLabeledText(
                  //  label: "Instance",
                  //  controller: instanceController,
                  //  onSubmitted: (value) {},
                  //),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
