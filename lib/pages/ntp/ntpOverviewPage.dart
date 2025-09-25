import 'package:flutter/material.dart';
import 'package:nct/pages/basePage.dart';
import 'package:nct/pages/ntp/ntpServerConfig.dart';
import 'package:nct/pages/ntp/ntpStatus.dart';
import 'package:nct/pages/ntp/ntpUtcConfig.dart';
import 'package:nct/pages/ntp/ntpVersion.dart';
import 'package:nct/pages/ntp/ntpNetwork.dart';

class NtpOverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'NTP',
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
