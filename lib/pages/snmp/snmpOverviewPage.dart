import 'package:flutter/material.dart';
import 'package:nct/pages/basePage.dart';
import 'package:nct/pages/snmp/snmpCards.dart';

class SnmpOverviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'SNMP',
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
                    // cards
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
                    SnmpVersion3Card(),
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
