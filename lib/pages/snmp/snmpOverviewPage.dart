import 'package:flutter/material.dart';
import 'package:nct/pages/basePage.dart';
import 'package:nct/pages/snmp/snmpCards.dart';

class SnmpOverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'SNMP',
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
                    SnmpActionsCard(),
                    SizedBox(height: 16),
                    SnmpStatusCard(),
                  ],
                ),
              ),
              SizedBox(
                width: 750,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SnmpVersion12Card(),
                    SizedBox(height: 16),
                    SnmpVersion3Card(),
                    SizedBox(height: 16),
                    //SnmpTrapsCard(),
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
