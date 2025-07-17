import 'package:flutter/material.dart';
import 'package:ntsc_ui/pages/basePage.dart';
import 'package:ntsc_ui/pages/snmp/snmpStatus.dart';
import 'package:provider/provider.dart';
import 'package:ntsc_ui/api/NtpApi.dart';

class NtpServerConfigCard extends StatefulWidget {
  @override
  State<NtpServerConfigCard> createState() => _NtpServerConfigCardState();
}

class _NtpServerConfigCardState extends State<NtpServerConfigCard> {
  final stratumController = TextEditingController();
  final pollIntervalController = TextEditingController();
  final precisionController = TextEditingController();
  final referenceIdController = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ntpApi = context.read<NtpApi>();
      //ntpApi.readAll();
      ntpApi.readProperty("stratum");
      ntpApi.readProperty("poll_interval");
      ntpApi.readProperty("precision");
      ntpApi.readProperty("reference_id");
    });
  }

  @override
  void dispose() {
    stratumController.dispose();
    pollIntervalController.dispose();
    precisionController.dispose();
    referenceIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NtpApi>(
      builder: (context, ntpApi, _) {
        stratumController.text = ntpApi.ntp['stratum'];
        pollIntervalController.text = ntpApi.ntp['poll_interval'];
        precisionController.text = ntpApi.ntp['precision'];

        return Card(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ServerConfig: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),

                  LabeledText(
                    label: "Stratum",
                    controller: stratumController,
                    myGap: 150,
                    onSubmitted: (value) {
                      ntpApi.ntp['stratum'] = value;
                      ntpApi.writeProperty('stratum');
                    },
                  ),
                  LabeledText(
                    label: "Poll Interval",
                    controller: pollIntervalController,
                    myGap: 150,
                    onSubmitted: (value) {
                      ntpApi.ntp['poll_interval'] = value;
                      ntpApi.writeProperty('poll_interval');
                    },
                  ),
                  LabeledText(
                    label: "Precision",
                    controller: precisionController,
                    myGap: 150,
                    onSubmitted: (value) {
                      ntpApi.ntp['precision'] = value;
                      ntpApi.writeProperty('precision');
                    },
                  ),
                  LabeledDropdown<String>(
                    myGap: 150,
                    label: 'Reference ID:',
                    value: ntpApi.ntp['reference_id'],
                    items: [
                      "NTP",
                      "NULL",
                      "LOCL",
                      "CESM",
                      "RBDM",
                      "PPS",
                      "IRIG",
                      "ACTS",
                      "USNO",
                      "PTB",
                      "TDF",
                      "DCF",
                      "MSF",
                      "WWV",
                      "WWVB",
                      "WWVH",
                      "CHU",
                      "LORC",
                      "OMEG",
                      "GPS",
                      "NA",
                    ],
                    onChanged: (newValue) {
                      setState(() {
                        ntpApi.ntp['reference_id'] = newValue;
                        ntpApi.writeProperty('reference_id');
                      });
                    },
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

class NtpServerConfigPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'NTP',
      description: 'NTP Server ServerConfig Info:',
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
                  children: [NtpServerConfigCard()],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
