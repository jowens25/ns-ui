import 'package:flutter/material.dart';
import 'package:ntsc_ui/pages/basePage.dart';
import 'package:ntsc_ui/pages/network/networkSettings.dart';

class NetworkOverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'NETWORK',
      description: 'Configuration Overview',
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.start,
            children: [
              SizedBox(
                width: 450,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //NetworkActionsCard(),
                    //SizedBox(height: 16),
                    //NetworkStatusCard(),
                  ],
                ),
              ),
              SizedBox(
                width: 750,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //NetworkVersion12Card(),
                    //SizedBox(height: 16),
                    //NetworkVersion3Card(),
                    //SizedBox(height: 16),
                    NetworkSettingsCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
