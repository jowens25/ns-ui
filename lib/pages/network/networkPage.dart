import 'package:flutter/material.dart';
import 'package:nct/custom/custom.dart';
import 'package:nct/api/NetworkApi.dart';
import 'package:provider/provider.dart';
import 'package:web/web.dart' as web;
import 'package:nct/models.dart';

class NetworkPage extends StatefulWidget {
  @override
  State<NetworkPage> createState() => _NetworkInfoCardState();
}

class _NetworkInfoCardState extends State<NetworkPage> {
  final hostnameCtrller = TextEditingController();
  final gatewayCtrller = TextEditingController();
  final interfaceCtrller = TextEditingController();
  final speedCtrller = TextEditingController();
  final macCtrller = TextEditingController();
  final ipCtrller = TextEditingController();
  final netmaskCtrller = TextEditingController();
  final dhcpCtrller = TextEditingController();
  final dns1Ctrller = TextEditingController();
  final dns2Ctrller = TextEditingController();
  final ignoreAutoDnsCtrller = TextEditingController();
  final connectionStatusCtrller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final networkApi = context.read<NetworkApi>();
    networkApi.readNetworkInfo().then((info) {
      if (info != null) _updateControllers(info);
    });
  }

  void _updateControllers(NetworkInfo info) {
    hostnameCtrller.text = info.hostname;
    gatewayCtrller.text = info.gateway;
    interfaceCtrller.text = info.interfaceName;
    speedCtrller.text = info.speed;
    macCtrller.text = info.mac;
    ipCtrller.text = info.ip;
    netmaskCtrller.text = info.netmask;
    dhcpCtrller.text = info.dhcp;
    dns1Ctrller.text = info.dns1;
    dns2Ctrller.text = info.dns2;
    ignoreAutoDnsCtrller.text = info.ignoreAutoDns;
    connectionStatusCtrller.text = info.connectionStatus;
  }

  @override
  void dispose() {
    hostnameCtrller.dispose();
    gatewayCtrller.dispose();
    interfaceCtrller.dispose();
    speedCtrller.dispose();
    macCtrller.dispose();
    ipCtrller.dispose();
    netmaskCtrller.dispose();
    dhcpCtrller.dispose();
    dns1Ctrller.dispose();
    dns2Ctrller.dispose();
    ignoreAutoDnsCtrller.dispose();
    connectionStatusCtrller.dispose();
    super.dispose();
  }

  Future<void> _submitField(
    NetworkApi api,
    String field,
    TextEditingController ctrl,
  ) async {
    final value = ctrl.text;
    await api.writeNetworkField(field, value);
    web.window.location.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkApi>(
      builder: (context, networkApi, _) {
        _updateControllers(networkApi.networkInfo);

        return Container(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //NetworkProtocolsCard(),
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
                    controller: connectionStatusCtrller,
                    myGap: 200,
                  ),
                  LabeledText(
                    label: "Hostname",
                    controller: hostnameCtrller,
                    myGap: 200,
                    onSubmitted: (value) =>
                        _submitField(networkApi, 'hostname', hostnameCtrller),
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
                    onSubmitted: (value) =>
                        _submitField(networkApi, 'gateway', gatewayCtrller),
                  ),
                  LabeledText(
                    label: "IPv4 Address",
                    controller: ipCtrller,
                    myGap: 200,
                    onSubmitted: (value) =>
                        _submitField(networkApi, 'ip_address', ipCtrller),
                  ),
                  LabeledText(
                    label: "IPv4 Netmask",
                    controller: netmaskCtrller,
                    myGap: 200,
                    onSubmitted: (value) =>
                        _submitField(networkApi, 'netmask', netmaskCtrller),
                  ),
                  LabeledText(
                    label: "IPv4 DHCP",
                    controller: dhcpCtrller,
                    myGap: 200,
                    onSubmitted: (value) =>
                        _submitField(networkApi, 'dhcp', dhcpCtrller),
                  ),
                  LabeledText(
                    label: "IPv4 DNS Primary",
                    controller: dns1Ctrller,
                    myGap: 200,
                    onSubmitted: (value) =>
                        _submitField(networkApi, 'dns1', dns1Ctrller),
                  ),
                  LabeledText(
                    label: "IPv4 DNS Secondary",
                    controller: dns2Ctrller,
                    myGap: 200,
                    onSubmitted: (value) =>
                        _submitField(networkApi, 'dns2', dns2Ctrller),
                  ),
                  LabeledText(
                    label: "IPv4 DNS Ignore Auto",
                    controller: ignoreAutoDnsCtrller,
                    myGap: 200,
                    onSubmitted: (value) => _submitField(
                      networkApi,
                      'ignore_auto_dns',
                      ignoreAutoDnsCtrller,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _showRestoreDefaultNetworkConfigDialog,
                        child: Text('Reset network config'),
                      ),
                      SizedBox(width: 40),
                    ],
                  ),

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
                        icon: Icon(Icons.info_outline),
                        onPressed: showProtocolInfo,
                      ),
                    ],
                  ),

                  LabeledSwitch(
                    myGap: 250,
                    label: "Telnet",
                    value: networkApi.telnet.status == "active",
                    onChanged: (bool value) async {
                      final updated = ServiceStatus(
                        status: networkApi.telnet.status,
                        action: value ? "start" : "stop",
                      );
                      await networkApi.editTelnetInfo(updated);
                    },
                  ),

                  LabeledSwitch(
                    myGap: 250,
                    label: "SSH SCP",
                    value: networkApi.ssh.status == "active",
                    onChanged: (bool value) async {
                      final updated = ServiceStatus(
                        status: networkApi.ssh.status,
                        action: value ? "start" : "stop",
                      );
                      await networkApi.editSshInfo(updated);
                    },
                  ),
                  LabeledSwitch(
                    myGap: 250,
                    label: "FTP",
                    value: networkApi.ftp.status == "active",
                    onChanged: (bool value) async {
                      final updated = ServiceStatus(
                        status: networkApi.ftp.status,
                        action: value ? "start" : "stop",
                      );
                      await networkApi.editSshInfo(updated);
                    },
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Access Control:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _showAddDialog,
                        icon: Icon(Icons.add, size: 20),
                        tooltip: 'Add Access',
                      ),
                      IconButton(
                        icon: Icon(Icons.info_outline, size: 20),
                        tooltip: "Info",
                        onPressed: _showAccessInfo,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  SizedBox(height: 200, child: _buildAllowedNodesList()),
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
                    //await networkApi.resetNetwork();
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
      builder: (dialogContext) => AlertDialog(
        title: Text("Access Control"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Manage IPv4 network configuration"),
            Text("Editing a field then pressing enter will submit the change"),
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

  void showProtocolInfo() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Protocols"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text("Enable or disable insecure protocols")],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildAllowedNodesList() {
    return Consumer<NetworkApi>(
      builder: (context, networkApi, _) {
        if (networkApi.allowedNodes.isEmpty) {
          return Center(
            child: Text(
              'All IP addresses allowed\nAdd nodes to restrict access',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: networkApi.allowedNodes.length,
          itemBuilder: (context, index) {
            final node = networkApi.allowedNodes[index];
            return Card(
              margin: EdgeInsets.only(bottom: 6),
              child: ListTile(
                dense: true,
                title: Text(node.address, style: TextStyle(fontSize: 13)),
                trailing: IconButton(
                  icon: Icon(Icons.delete, size: 18, color: Colors.red),
                  onPressed: () => _showDeleteDialog(node),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAccessInfo() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Access Control"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "By default all IP addresses are allowed to access the system.",
            ),
            SizedBox(height: 8),
            Text("Access may be restricted by adding allowed nodes:"),
            SizedBox(height: 4),
            Text("• '10.1.10.1/24' allows any IP on that subnet"),
            Text("• '10.1.10.201/32' allows only 10.1.10.201"),
            SizedBox(height: 8),
            Text("Remove restrictions: 'ns access unrestrict'"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Add Allowed CIDR IP'),
        content: TextField(
          controller: addressController,
          decoration: InputDecoration(
            labelText: 'Address',
            hintText: '10.1.10.1/24',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (addressController.text.isEmpty) return;

              final networkApi = context.read<NetworkApi>();
              final node = AllowedNode.fromJson({
                'ID': 0,
                'address': addressController.text,
              });

              final success = await networkApi.writeNetworkAccess(node);

              if (mounted) {
                Navigator.pop(dialogContext);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Node added successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(networkApi.responseMessage),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(AllowedNode node) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete Node'),
        content: Text('Delete ${node.address}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final networkApi = context.read<NetworkApi>();
              final success = await networkApi.deleteNetworkAccess(node);

              if (mounted) {
                Navigator.pop(dialogContext);

                if (success) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Node deleted')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(networkApi.responseMessage),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
