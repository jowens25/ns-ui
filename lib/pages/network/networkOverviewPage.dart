import 'package:flutter/material.dart';
import 'package:nct/pages/basePage.dart';
import 'package:nct/pages/network/networkCards.dart';

class NetworkOverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Network',
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
                    NetworkInfoCard(),

                    //NetworkSettingsCard(),
                  ],
                ),
              ),
              SizedBox(
                width: 350,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NetworkProtcolCard(),
                    NetworkAccessCard(),
                    //NetworkAccessCard(),
                    //SizedBox(height: 16),
                    //NetworkVersion3Card(),
                    //SizedBox(height: 16),
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
