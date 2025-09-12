import 'package:flutter/material.dart';
import 'package:nct/pages/basePage.dart';
import 'package:nct/pages/device/deviceCards.dart';

class DeviceOverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Device',
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
                width: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [DeviceActionsCard()],
                ),
              ),
              SizedBox(
                width: 550,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [DeviceStatusCard()],
                ),
              ),
              //SizedBox(
              //  width: 750,
              //  child: Column(
              //    crossAxisAlignment: CrossAxisAlignment.start,
              //    children: [
              //      DeviceVersion12Card(),
              //      SizedBox(height: 16),
              //
              //      SizedBox(height: 16),
              //      //DeviceTrapsCard(),
              //    ],
              //  ),
              //),
            ],
          ),
        ),
      ],
    );
  }
}
