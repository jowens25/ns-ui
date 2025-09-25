import 'package:flutter/material.dart';
import 'package:nct/custom/custom.dart';
import 'package:provider/provider.dart';
import 'package:nct/api/NtpApi.dart';

class NtpVersionCard extends StatefulWidget {
  @override
  State<NtpVersionCard> createState() => _NtpVersionCardState();
}

class _NtpVersionCardState extends State<NtpVersionCard> {
  final versionController = TextEditingController();
  final instanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ntpApi = context.read<NtpApi>();
      //ntpApi.readAll();
      ntpApi.readProperty("instance");
      ntpApi.readProperty("version");
    });
  }

  @override
  void dispose() {
    versionController.dispose();
    instanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NtpApi>(
      builder: (context, ntpApi, _) {
        versionController.text = ntpApi.ntp['version'];
        instanceController.text = ntpApi.ntp['instance'];
        return Card(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Version: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),

                  ReadOnlyLabeledText(
                    label: "Version",
                    controller: versionController,
                    myGap: 100,
                  ),
                  ReadOnlyLabeledText(
                    label: "Instance",
                    controller: instanceController,
                    myGap: 100,
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
