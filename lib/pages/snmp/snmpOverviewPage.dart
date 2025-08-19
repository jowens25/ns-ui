import 'package:flutter/material.dart';
import 'package:ntsc_ui/pages/basePage.dart';
import 'package:ntsc_ui/pages/snmp/snmpActions.dart';
import 'package:ntsc_ui/pages/snmp/snmpStatus.dart';
import 'package:ntsc_ui/pages/snmp/snmpTraps.dart';
import 'package:ntsc_ui/pages/snmp/snmpVersion12.dart';
import 'package:ntsc_ui/pages/snmp/snmpVersion3.dart';

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
