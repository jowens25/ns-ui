import 'package:flutter/material.dart';
import 'package:nct/pages/basePage.dart';
import 'package:nct/custom/custom.dart';
import 'package:provider/provider.dart';
import 'package:nct/api/NtpApi.dart';

class NtpUtcConfigCard extends StatefulWidget {
  @override
  State<NtpUtcConfigCard> createState() => _NtpUtcConfigCardState();
}

class _NtpUtcConfigCardState extends State<NtpUtcConfigCard> {
  final utcOffsetController = TextEditingController();

  final double gap = 175;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ntpApi = context.read<NtpApi>();

      ntpApi.readProperty("leap59");
      ntpApi.readProperty("leap59_inprogress");
      ntpApi.readProperty("leap61");
      ntpApi.readProperty("leap61_inprogress");
      ntpApi.readProperty("utc_smearing");
      ntpApi.readProperty("utc_offset_status");
      ntpApi.readProperty("utc_offset_value");
    });
  }

  @override
  void dispose() {
    utcOffsetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NtpApi>(
      builder: (context, ntpApi, _) {
        utcOffsetController.text = ntpApi.ntp['utc_offset_value'];
        return Card(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'UtcConfig: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  LabeledSwitch(
                    myGap: gap - 4,
                    label: "leap59",
                    value: ntpApi.ntp['leap59'] == 'enabled',
                    onChanged: (bool value) {
                      ntpApi.ntp['leap59'] = value ? "enabled" : "disabled";
                      setState(() {
                        ntpApi.writeProperty('leap59');
                      });
                    },
                  ),
                  LabeledSwitch(
                    myGap: gap - 4,
                    label: "leap59_inprogress",
                    value: ntpApi.ntp['leap59_inprogress'] == 'enabled',
                    onChanged: (bool value) {
                      ntpApi.ntp['leap59_inprogress'] =
                          value ? "enabled" : "disabled";
                      setState(() {
                        ntpApi.writeProperty('leap59_inprogress');
                      });
                    },
                  ),

                  LabeledSwitch(
                    myGap: gap - 4,
                    label: "leap61",
                    value: ntpApi.ntp['leap61'] == 'enabled',
                    onChanged: (bool value) {
                      ntpApi.ntp['leap61'] = value ? "enabled" : "disabled";
                      setState(() {
                        ntpApi.writeProperty('leap61');
                      });
                    },
                  ),

                  LabeledSwitch(
                    myGap: gap - 4,
                    label: "leap61_inprogress",
                    value: ntpApi.ntp['leap61_inprogress'] == 'enabled',
                    onChanged: (bool value) {
                      ntpApi.ntp['leap61_inprogress'] =
                          value ? "enabled" : "disabled";
                      setState(() {
                        ntpApi.writeProperty('leap61_inprogress');
                      });
                    },
                  ),
                  LabeledSwitch(
                    myGap: gap - 4,
                    label: "utc_smearing",
                    value: ntpApi.ntp['utc_smearing'] == 'enabled',
                    onChanged: (bool value) {
                      ntpApi.ntp['utc_smearing'] =
                          value ? "enabled" : "disabled";
                      setState(() {
                        ntpApi.writeProperty('utc_smearing');
                      });
                    },
                  ),
                  LabeledSwitch(
                    myGap: gap - 4,
                    label: "utc_offset_status",
                    value: ntpApi.ntp['utc_offset_status'] == 'enabled',
                    onChanged: (bool value) {
                      ntpApi.ntp['utc_offset_status'] =
                          value ? "enabled" : "disabled";
                      setState(() {
                        ntpApi.writeProperty('utc_offset_status');
                      });
                    },
                  ),
                  LabeledText(
                    myGap: gap,
                    label: "UTC Offset",
                    controller: utcOffsetController,
                    onSubmitted: (value) {
                      ntpApi.ntp['utc_offset_value'] = value;
                      ntpApi.writeProperty('utc_offset_value');
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

class NtpUtcConfigPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'NTP',
      description: 'NTP Server UtcConfig Info:',
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
                  children: [NtpUtcConfigCard()],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
