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
                  ElevatedButton(
                    onPressed: () {
                      // Action to perform when the button is pressed
                      print('Button pressed!');
                      networkApi.readNetworkAccess();
                    },
                    child: const Text('Submit'),
                  ),
                  LabeledText(
                    label: "Access Network",
                    controller: TextEditingController(),
                    myGap: 300,
                    onSubmitted: (value) {
                      //ntpApi.ntp['mac'] = value;
                      //ntpApi.writeProperty('mac');
                      AllowedNode node = AllowedNode.fromJson({
                        'ID': 0,
                        'address': value,
                      });
                      networkApi.writeNetworkAccess(node);
                    },
                  ),
                  LabeledText(
                    label: "Remove Access Network",
                    controller: TextEditingController(),
                    myGap: 300,
                    onSubmitted: (value) {
                      //ntpApi.ntp['mac'] = value;
                      //ntpApi.writeProperty('mac');
                      AllowedNode node = AllowedNode.fromJson({
                        'ID': 0,
                        'address': value,
                      });
                      networkApi.deleteNetworkAccess(node);
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
