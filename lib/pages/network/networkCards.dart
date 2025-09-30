import 'package:flutter/material.dart';
import 'package:nct/custom/custom.dart';
import 'package:nct/api/NetworkApi.dart';
import 'package:provider/provider.dart';

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
    context.read<NetworkApi>().readFtpInfo();

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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Protocols:',
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
                  LabeledSwitch(
                    myGap: 250,
                    label: "FTP",
                    value: networkApi.ftp.Status == "active",
                    onChanged: (bool value) {
                      setState(() {
                        networkApi.ftp.Action = value ? "start" : "stop";
                        networkApi.editFtpInfo(networkApi.ftp);
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

  void _showInfo() {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text("Access Control"),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text("Enable or disable insecure protocols")],
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
                        'Access Control:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => addNetworkAccessDialog(),
                      icon: const Icon(Icons.add),
                      tooltip: 'Add Access',
                    ),

                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      tooltip: "Info",
                      onPressed: _showInfo,
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
                Text(
                  "By default all ip address are allowed to access the system",
                ),
                Text("Access may be restricted by adding an allowed node"),
                Text("Adding '10.1.10.1/24' will allow any ip on that subnet"),
                Text("Adding '10.1.10.201/32' will only allow 10.1.10.201"),
                Text(
                  "Remove these restrictions by running 'ns network unrestrict' via cli",
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
                    },
                  ),

                  LabeledText(
                    label: "IPv4 Address",
                    controller: ip_addressCtrller,
                    myGap: 200,
                    onSubmitted: (value) {
                      networkApi.networkInfo['ip_address'] = value;
                      networkApi.writeNetworkInfo('ip_address');
                    },
                  ),

                  LabeledText(
                    label: "IPv4 Netmask",
                    controller: netmaskCtrller,
                    myGap: 200,
                    onSubmitted: (value) {
                      networkApi.networkInfo['netmask'] = value;
                      networkApi.writeNetworkInfo('netmask');
                    },
                  ),

                  LabeledText(
                    label: "IPv4 DHCP",
                    controller: dhcpCtrller,
                    myGap: 200,
                    onSubmitted: (value) {
                      networkApi.networkInfo['dhcp'] = value;
                      networkApi.writeNetworkInfo('dhcp');
                    },
                  ),

                  LabeledText(
                    label: "IPv4 DNS Primary",
                    controller: dns1Ctrller,
                    myGap: 200,
                    onSubmitted: (value) {
                      networkApi.networkInfo['dns1'] = value;
                      networkApi.writeNetworkInfo('dns1');
                    },
                  ),

                  LabeledText(
                    label: "IPv4 DNS Secondary",
                    controller: dns2Ctrller,
                    myGap: 200,
                    onSubmitted: (value) {
                      networkApi.networkInfo['dns2'] = value;
                      networkApi.writeNetworkInfo('dns2');
                    },
                  ),

                  LabeledText(
                    label: "IPv4 DNS Ignore Auto",
                    controller: ignore_auto_dnsCtrller,
                    myGap: 200,
                    onSubmitted: (value) {
                      networkApi.networkInfo['ignore_auto_dns'] = value;
                      networkApi.writeNetworkInfo('ignore_auto_dns');
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
