import 'package:flutter/material.dart';
import 'package:nct/pages/basePage.dart';
import 'package:nct/custom/custom.dart';
import 'package:nct/api/NetworkApi.dart';
import 'package:provider/provider.dart';

class NetworkSettingsCard extends StatefulWidget {
  const NetworkSettingsCard({super.key});

  @override
  State<NetworkSettingsCard> createState() => _NetworkTrapCardState();
}

class _NetworkTrapCardState extends State<NetworkSettingsCard> {
  final ipAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<NetworkApi>().readTelnetInfo();
    context.read<NetworkApi>().readSshInfo();
    context.read<NetworkApi>().readHttpInfo();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //context.read<NetworkApi>().getStatus();
      //context.read<NetworkApi>().getSysDetails();
    });
  }

  @override
  void dispose() {
    ipAddressController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkApi>(
      builder: (context, networkApi, _) {
        return Card(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: title and add button
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Ethernet Settings:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  LabeledSwitch(
                    myGap: 300,
                    label: "Enable eth0 interface",
                    value: true, //details.Status == "active",
                    onChanged: (bool value) {
                      setState(() {
                        //details.Action = value ? "start" : "stop";
                        //networkApi.editNetworkInfo(details);
                      });
                    },
                  ),

                  LabeledSwitch(
                    myGap: 300,
                    label: "Telnet",
                    value: networkApi.telnet.Status == "active",
                    onChanged: (bool value) {
                      setState(() {
                        networkApi.telnet.Action = value ? "start" : "stop";
                        networkApi.editTelnetInfo(networkApi.telnet);
                      });
                    },
                  ),
                  LabeledSwitch(
                    myGap: 300,
                    label: "SSH + SFTP",
                    value: networkApi.ssh.Status == "active",
                    onChanged: (bool value) {
                      setState(() {
                        networkApi.ssh.Action = value ? "start" : "stop";
                        networkApi.editSshInfo(networkApi.ssh);
                      });
                    },
                  ),
                  LabeledSwitch(
                    myGap: 300,
                    label: "HTTP",
                    value: networkApi.http.Status == "active",
                    onChanged: (bool value) {
                      setState(() {
                        networkApi.http.Action = value ? "start" : "stop";
                        networkApi.editHttpInfo(networkApi.http);
                      });
                    },
                  ),
                  LabeledSwitch(
                    myGap: 300,
                    label: "Enable DHCPv4",
                    value: true, //details.Status == "active",
                    onChanged: (bool value) {
                      setState(() {
                        //details.Action = value ? "start" : "stop";
                        //networkApi.editNetworkInfo(details);
                      });
                    },
                  ),

                  LabeledDropdown<String>(
                    myGap: 300,
                    label: 'IPv6 Auto Configuration',
                    value: "Auto",
                    items: ["Auto", "Disabled", "Stateful"],

                    onChanged: (newValue) {
                      setState(() {
                        //ntpApi.ntp['ip_mode'] = newValue;
                        //ntpApi.writeProperty('ip_mode');
                        //ntpApi.readProperty('ip_address');
                      });
                    },
                  ),
                  LabeledText(
                    label: "Static IP",
                    controller: TextEditingController(),
                    myGap: 300,
                    onSubmitted: (value) {
                      //ntpApi.ntp['mac'] = value;
                      //ntpApi.writeProperty('mac');
                    },
                  ),
                  LabeledText(
                    label: "DNS Primary",
                    controller: TextEditingController(),
                    myGap: 300,
                    onSubmitted: (value) {
                      //ntpApi.ntp['mac'] = value;
                      //ntpApi.writeProperty('mac');
                    },
                  ),
                  LabeledText(
                    label: "DNS Secondary",
                    controller: TextEditingController(),
                    myGap: 300,
                    onSubmitted: (value) {
                      //ntpApi.ntp['mac'] = value;
                      //ntpApi.writeProperty('mac');
                    },
                  ),
                  LabeledText(
                    label: "Domain",
                    controller: TextEditingController(),
                    myGap: 300,
                    onSubmitted: (value) {
                      // ntpApi.ntp['mac'] = value;
                      // ntpApi.writeProperty('mac');
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

//class NetworkSettingsPage extends StatelessWidget {
//  const NetworkSettingsPage({super.key});
//
//  @override
//  Widget build(BuildContext context) {
//    return BasePage(
//      title: 'NETWORK',
//      description: 'Ethernet Settings Config',
//      children: [
//        Row(
//          crossAxisAlignment: CrossAxisAlignment.start,
//          children: [
//            Expanded(
//              child: Padding(
//                padding: EdgeInsets.all(16),
//                child: Column(
//                  crossAxisAlignment: CrossAxisAlignment.start,
//                  children: [NetworkSettingsCard()],
//                ),
//              ),
//            ),
//          ],
//        ),
//      ],
//    );
//  }
//}
