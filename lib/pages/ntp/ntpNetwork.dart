import 'package:flutter/material.dart';
import 'package:ntsc_ui/pages/basePage.dart';
import 'package:ntsc_ui/pages/snmp/snmpStatus.dart';
import 'package:provider/provider.dart';
import 'package:ntsc_ui/api/NtpApi.dart';

class NtpNetworkCard extends StatefulWidget {
  @override
  State<NtpNetworkCard> createState() => _NtpNetworkCardState();
}

class _NtpNetworkCardState extends State<NtpNetworkCard> {
  final macController = TextEditingController();
  final vlanController = TextEditingController();
  final ipAddressController = TextEditingController();

  final double gap = 175;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ntpApi = context.read<NtpApi>();

      ntpApi.readProperty("mac");
      ntpApi.readProperty("vlan_address");
      ntpApi.readProperty("vlan_status");
      ntpApi.readProperty("ip_mode");
      ntpApi.readProperty("ip_address");
    });
  }

  @override
  void dispose() {
    macController.dispose();
    vlanController.dispose();
    ipAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NtpApi>(
      builder: (context, ntpApi, _) {
        macController.text = ntpApi.ntp['mac'];
        vlanController.text = ntpApi.ntp['vlan_address'];
        ipAddressController.text = ntpApi.ntp['ip_address'];
        return Card(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Network: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),

                  LabeledText(
                    label: "MAC Address",
                    controller: macController,
                    myGap: gap,
                    onSubmitted: (value) {
                      ntpApi.ntp['mac'] = value;
                      ntpApi.writeProperty('mac');
                    },
                  ),
                  LabeledText(
                    label: "VLAN Address",
                    controller: vlanController,
                    myGap: gap,
                    onSubmitted: (value) {
                      ntpApi.ntp['vlan_address'] = value;
                      ntpApi.writeProperty('vlan_address');
                    },
                  ),
                  LabeledSwitch(
                    myGap: gap - 4,
                    label: "VLAN Enabled",
                    value: ntpApi.ntp['vlan_status'] == 'enabled',
                    onChanged: (bool value) {
                      ntpApi.ntp['vlan_status'] =
                          value ? "enabled" : "disabled";
                      setState(() {
                        ntpApi.writeProperty('vlan_status');
                      });
                    },
                  ),

                  LabeledDropdown<String>(
                    myGap: gap,
                    label: 'IP Version',
                    value: ntpApi.ntp['ip_mode'],
                    items: ["IPv4", "IPv6"],

                    onChanged: (newValue) {
                      setState(() {
                        ntpApi.ntp['ip_mode'] = newValue;
                        ntpApi.writeProperty('ip_mode');
                        ntpApi.readProperty('ip_address');
                      });
                    },
                  ),
                  LabeledText(
                    label: "IP Address",
                    controller: ipAddressController,
                    myGap: gap,
                    onSubmitted: (value) {
                      ntpApi.ntp['ip_address'] = value;
                      ntpApi.writeProperty('ip_address');
                    },
                  ),
                  LabeledSwitch(
                    myGap: gap - 4,
                    label: "Unicast Enabled",
                    value: ntpApi.ntp['unicast_mode'] == 'enabled',
                    onChanged: (bool value) {
                      ntpApi.ntp['unicast_mode'] =
                          value ? "enabled" : "disabled";
                      setState(() {
                        ntpApi.writeProperty('unicast_mode');
                      });
                    },
                  ),
                  LabeledSwitch(
                    myGap: gap - 4,
                    label: "Multicast Enabled",
                    value: ntpApi.ntp['multicast_mode'] == 'enabled',
                    onChanged: (bool value) {
                      ntpApi.ntp['multicast_mode'] =
                          value ? "enabled" : "disabled";
                      setState(() {
                        ntpApi.writeProperty('multicast_mode');
                      });
                    },
                  ),
                  LabeledSwitch(
                    myGap: gap - 4,
                    label: "Broadcast Enabled",
                    value: ntpApi.ntp['broadcast_mode'] == 'enabled',
                    onChanged: (bool value) {
                      ntpApi.ntp['broadcast_mode'] =
                          value ? "enabled" : "disabled";
                      setState(() {
                        ntpApi.writeProperty('broadcast_mode');
                      });
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

class NtpNetworkPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'NTP',
      description: 'NTP Server Network Info:',
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
                  children: [NtpNetworkCard()],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
