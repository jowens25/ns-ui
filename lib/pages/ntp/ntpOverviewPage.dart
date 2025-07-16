import 'package:flutter/material.dart';
import 'package:ntsc_ui/pages/basePage.dart';
import 'package:ntsc_ui/pages/ntp/ntpServerConfig.dart';
import 'package:ntsc_ui/pages/ntp/ntpStatus.dart';
import 'package:ntsc_ui/pages/ntp/ntpUtcConfig.dart';
import 'package:ntsc_ui/pages/ntp/ntpVersion.dart';
import 'package:ntsc_ui/pages/ntp/ntpNetwork.dart';

class NtpOverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'NTP',
      description: 'View and Manage NTP Server Configuration',
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.start,
            children: [
              SizedBox(
                width: 275,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NtpVersionCard(),
                    SizedBox(height: 16),
                    NtpStatusCard(),
                  ],
                ),
              ),
              SizedBox(
                width: 275,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NtpServerConfigCard(),
                    SizedBox(height: 16),
                    NtpUtcConfigCard(),
                  ],
                ),
              ),
              SizedBox(
                width: 600,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [NtpNetworkCard()],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
