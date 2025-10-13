import 'package:flutter/material.dart';
import 'package:nct/custom/custom.dart';
import 'package:nct/api/NetworkApi.dart';
import 'package:provider/provider.dart';
import 'package:web/web.dart' as web;

class NetworkInfoCard extends StatefulWidget {
  @override
  State<NetworkInfoCard> createState() => _NetworkInfoCardState();
}

class _NetworkInfoCardState extends State<NetworkInfoCard> {
  final port_statusCtrller = TextEditingController();
  final hostnameCtrller = TextEditingController();
  final gatewayCtrller = TextEditingController();
  final interfaceCtrller = TextEditingController();
  final speedCtrller = TextEditingController();
  final macCtrller = TextEditingController();
  final ip_addressCtrller = TextEditingController();
  final netmaskCtrller = TextEditingController();

  final dhcpCtrller = TextEditingController();
  final dns1Ctrller = TextEditingController();
  final dns2Ctrller = TextEditingController();
  final ignore_auto_dnsCtrller = TextEditingController();
  final connection_statusCtrller = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<NetworkApi>().readNetworkInfo();
  }

  @override
  void dispose() {
    port_statusCtrller.dispose();
    hostnameCtrller.dispose();
    gatewayCtrller.dispose();
    interfaceCtrller.dispose();
    speedCtrller.dispose();
    macCtrller.dispose();
    ip_addressCtrller.dispose();
    netmaskCtrller.dispose();
    dhcpCtrller.dispose();
    dns1Ctrller.dispose();
    dns2Ctrller.dispose();
    ignore_auto_dnsCtrller.dispose();
    connection_statusCtrller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkApi>(
      builder: (context, networkApi, _) {
        hostnameCtrller.text = networkApi.networkInfo['hostname'];
        gatewayCtrller.text = networkApi.networkInfo['gateway'];
        interfaceCtrller.text = networkApi.networkInfo['interface'];
        speedCtrller.text = networkApi.networkInfo['speed'];
        macCtrller.text = networkApi.networkInfo['mac'];
        ip_addressCtrller.text = networkApi.networkInfo['ip_address'];
        netmaskCtrller.text = networkApi.networkInfo['netmask'];
        dhcpCtrller.text = networkApi.networkInfo['dhcp'];
        dns1Ctrller.text = networkApi.networkInfo['dns1'];
        dns2Ctrller.text = networkApi.networkInfo['dns2'];
        ignore_auto_dnsCtrller.text = networkApi.networkInfo['ignore_auto_dns'];
        connection_statusCtrller.text =
            networkApi.networkInfo['connection_status'];

        return Card(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Status:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        tooltip: "Info",
                        onPressed: _showInfo,
                      ),
                    ],
                  ),
                  ReadOnlyLabeledText(
                    label: "Connection Status",
                    controller: connection_statusCtrller,
                    myGap: 200,
                  ),

                  LabeledText(
                    label: "Hostname",
                    controller: hostnameCtrller,
                    myGap: 200,
                    onSubmitted: (value) {
                      networkApi.networkInfo['hostname'] = value;
                      networkApi.writeNetworkInfo('hostname');
                      web.window.location.reload();
                    },
                  ),

                  ReadOnlyLabeledText(
                    label: "Interface",
                    controller: interfaceCtrller,
                    myGap: 200,
                  ),
                  ReadOnlyLabeledText(
                    label: "Speed",
                    controller: speedCtrller,
                    myGap: 200,
                  ),
                  ReadOnlyLabeledText(
                    label: "MAC Address",
                    controller: macCtrller,
                    myGap: 200,
                  ),

                  LabeledText(
                    label: "IPv4 Gateway",
                    controller: gatewayCtrller,
                    myGap: 200,
                    onSubmitted: (value) {
                      networkApi.networkInfo['gateway'] = value;
                      networkApi.writeNetworkInfo('gateway');
                      web.window.location.reload();
                    },
                  ),

                  LabeledText(
                    label: "IPv4 Address",
                    controller: ip_addressCtrller,
                    myGap: 200,
                    onSubmitted: (value) {
                      networkApi.networkInfo['ip_address'] = value;
                      networkApi.writeNetworkInfo('ip_address');
                      web.window.location.reload();
                    },
                  ),

                  LabeledText(
                    label: "IPv4 Netmask",
                    controller: netmaskCtrller,
                    myGap: 200,
                    onSubmitted: (value) {
                      networkApi.networkInfo['netmask'] = value;
                      networkApi.writeNetworkInfo('netmask');
                      web.window.location.reload();
                    },
                  ),

                  LabeledText(
                    label: "IPv4 DHCP",
                    controller: dhcpCtrller,
                    myGap: 200,
                    onSubmitted: (value) {
                      networkApi.networkInfo['dhcp'] = value;
                      networkApi.writeNetworkInfo('dhcp');
                      web.window.location.reload();
                    },
                  ),

                  LabeledText(
                    label: "IPv4 DNS Primary",
                    controller: dns1Ctrller,
                    myGap: 200,
                    onSubmitted: (value) {
                      networkApi.networkInfo['dns1'] = value;
                      networkApi.writeNetworkInfo('dns1');
                      web.window.location.reload();
                    },
                  ),

                  LabeledText(
                    label: "IPv4 DNS Secondary",
                    controller: dns2Ctrller,
                    myGap: 200,
                    onSubmitted: (value) {
                      networkApi.networkInfo['dns2'] = value;
                      networkApi.writeNetworkInfo('dns2');
                      web.window.location.reload();
                    },
                  ),

                  LabeledText(
                    label: "IPv4 DNS Ignore Auto",
                    controller: ignore_auto_dnsCtrller,
                    myGap: 200,
                    onSubmitted: (value) {
                      networkApi.networkInfo['ignore_auto_dns'] = value;
                      networkApi.writeNetworkInfo('ignore_auto_dns');
                      web.window.location.reload();
                    },
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _showRestoreDefaultNetworkConfigDialog();
                          //networkApi.resetNetwork();
                        },
                        child: Text('Reset network config'),
                      ),
                      SizedBox(width: 40),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRestoreDefaultNetworkConfigDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<NetworkApi>(
          builder: (context, networkApi, _) {
            return AlertDialog(
              content: Text(
                'Are you sure you want to restore the default network config?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    networkApi.resetNetwork();
                    Navigator.of(context).pop();
                    web.window.location.reload();
                  },
                  child: Text('Restore', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text("Access Control"),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Manage ipv4 network configuration"),
                Text(
                  "Editing a field then pressing enter will submit the change",
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text("Close"),
              ),
            ],
          ),
    );
  }
}
