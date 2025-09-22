import 'package:flutter/material.dart';
import 'package:nct/custom/custom.dart';
import 'package:nct/api/NetworkApi.dart';
import 'package:provider/provider.dart';

class NetworkSettingsCard extends StatefulWidget {
  const NetworkSettingsCard({super.key});

  @override
  State<NetworkSettingsCard> createState() => _NetworkCardState();
}

class _NetworkCardState extends State<NetworkSettingsCard> {
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'DNS Settings:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  LabeledText(
                    label: "DNS Primary",
                    controller: TextEditingController(),
                    myGap: 250,
                    onSubmitted: (value) {
                      //ntpApi.ntp['mac'] = value;
                      //ntpApi.writeProperty('mac');
                    },
                  ),
                  LabeledText(
                    label: "DNS Secondary",
                    controller: TextEditingController(),
                    myGap: 250,
                    onSubmitted: (value) {
                      //ntpApi.ntp['mac'] = value;
                      //ntpApi.writeProperty('mac');
                    },
                  ),

                  LabeledText(
                    label: "Ignore Auto DNS",
                    controller: TextEditingController(),
                    myGap: 250,
                    onSubmitted: (value) {
                      //ntpApi.ntp['mac'] = value;
                      //ntpApi.writeProperty('mac');
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

class NetworkProtcolCard extends StatefulWidget {
  const NetworkProtcolCard({super.key});

  @override
  State<NetworkProtcolCard> createState() => _NetworkProtcolCard();
}

class _NetworkProtcolCard extends State<NetworkProtcolCard> {
  final port_statusCtrller = TextEditingController();
  final hostnameCtrller = TextEditingController();
  final gatewayCtrller = TextEditingController();
  final interfaceCtrller = TextEditingController();
  final speedCtrller = TextEditingController();
  final macCtrller = TextEditingController();
  final ip_addressCtrller = TextEditingController();
  final dhcpCtrller = TextEditingController();
  final dns1Ctrller = TextEditingController();
  final dns2Ctrller = TextEditingController();
  final ignore_auto_dnsCtrller = TextEditingController();
  final connection_statusCtrller = TextEditingController();

  @override
  void initState() {
    super.initState();
    //context.read<NetworkApi>().readFtpInfo();
    context.read<NetworkApi>().readTelnetInfo();
    context.read<NetworkApi>().readSshInfo();
    context.read<NetworkApi>().readHttpInfo();
    context.read<NetworkApi>().readNetworkInfo();
    //context.read<NetworkApi>().readNetworkInfo

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //context.read<NetworkApi>().getStatus();
      //context.read<NetworkApi>().getSysDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkApi>(
      builder: (context, networkApi, _) {
        port_statusCtrller.text = networkApi.networkInfo['port_status'];
        hostnameCtrller.text = networkApi.networkInfo['hostname'];
        gatewayCtrller.text = networkApi.networkInfo['gateway'];
        interfaceCtrller.text = networkApi.networkInfo['interface'];
        speedCtrller.text = networkApi.networkInfo['speed'];
        macCtrller.text = networkApi.networkInfo['mac'];
        ip_addressCtrller.text = networkApi.networkInfo['ip_address'];
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
                  LabeledSwitch(
                    myGap: 250,
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
                    myGap: 250,
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
                    myGap: 250,
                    label: "SSH + SFTP",
                    value: networkApi.ssh.Status == "active",
                    onChanged: (bool value) {
                      setState(() {
                        networkApi.ssh.Action = value ? "start" : "stop";
                        networkApi.editSshInfo(networkApi.ssh);
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

class NetworkAccessCard extends StatefulWidget {
  @override
  State<NetworkAccessCard> createState() => _NetworkAccessCard();
}

class _NetworkAccessCard extends State<NetworkAccessCard> {
  @override
  void initState() {
    super.initState();

    context.read<NetworkApi>().readNetworkAccess();

    //WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Access Control',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () => addNetworkAccessDialog(),
                      icon: const Icon(Icons.add),
                      tooltip: 'Add Access',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 200,
            padding: EdgeInsets.all(16),
            child: buildAllowedNodesList(),
          ),
        ],
      ),
    );
  }

  Widget buildAllowedNodesList() {
    return Consumer<NetworkApi>(
      builder: (context, networkApi, _) {
        return ListView.builder(
          itemCount: networkApi.allowedNodes.length,
          itemBuilder: (context, index) {
            final node = networkApi.allowedNodes[index];
            return Card(
              margin: EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(node.address),

                trailing: IconButton(
                  onPressed: () {
                    _showDeleteAllowedNodeDialog(node);
                  },
                  icon: Icon(Icons.delete),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void addNetworkAccessDialog() {
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Add an allowed CIDR IP'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(labelText: 'Address'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final networkApi = context.read<NetworkApi>();
                    AllowedNode node = AllowedNode.fromJson({
                      'ID': 0,
                      'address': addressController.text,
                    });
                    networkApi.writeNetworkAccess(node);

                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Node added')));
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteAllowedNodeDialog(AllowedNode node) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<NetworkApi>(
          builder: (context, networkApi, _) {
            return AlertDialog(
              title: Text('Delete Node'),
              content: Text('Delete ${node.address}?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    await networkApi.deleteNetworkAccess(node);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Node removed")));
                  },
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

//
//class NetworkAccessCard extends StatefulWidget {
//  @override
//  State<NetworkAccessCard> createState() => _NetworkAccessCard();
//}
//
//class _NetworkAccessCard extends State<NetworkAccessCard> {
//  @override
//  void initState() {
//    super.initState();
//
//    context.read<NetworkApi>().readNetworkAccess();
//
//    //WidgetsBinding.instance.addPostFrameCallback((_) {});
//  }
//

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final networkApi = context.read<NetworkApi>();
      //ntpApi.readAll();
      networkApi.readNetworkInfo();
    });
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
                  ReadOnlyLabeledText(
                    label: "Hostname",
                    controller: hostnameCtrller,
                    myGap: 200,
                  ),
                  ReadOnlyLabeledText(
                    label: "Gateway",
                    controller: gatewayCtrller,
                    myGap: 200,
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
                  ReadOnlyLabeledText(
                    label: "IP Address",
                    controller: ip_addressCtrller,
                    myGap: 200,
                  ),
                  ReadOnlyLabeledText(
                    label: "Netmask",
                    controller: netmaskCtrller,
                    myGap: 200,
                  ),
                  ReadOnlyLabeledText(
                    label: "DHCP",
                    controller: dhcpCtrller,
                    myGap: 200,
                  ),
                  ReadOnlyLabeledText(
                    label: "Primary DNS",
                    controller: dns1Ctrller,
                    myGap: 200,
                  ),
                  ReadOnlyLabeledText(
                    label: "Secondary DNS",
                    controller: dns2Ctrller,
                    myGap: 200,
                  ),
                  ReadOnlyLabeledText(
                    label: "Ignore Auto DNS",
                    controller: ignore_auto_dnsCtrller,
                    myGap: 200,
                  ),
                  ReadOnlyLabeledText(
                    label: "Connection Status",
                    controller: connection_statusCtrller,
                    myGap: 200,
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
