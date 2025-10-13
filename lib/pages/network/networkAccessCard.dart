import 'package:flutter/material.dart';
import 'package:nct/custom/custom.dart';
import 'package:nct/api/NetworkApi.dart';
import 'package:provider/provider.dart';
import 'package:web/web.dart' as web;

class NetworkAccessCard extends StatefulWidget {
  @override
  State<NetworkAccessCard> createState() => _NetworkAccessCard();
}

class _NetworkAccessCard extends State<NetworkAccessCard> {
  @override
  void initState() {
    super.initState();
    context.read<NetworkApi>().readNetworkAccess();
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
                  "Remove these restrictions by running 'ns access unrestrict'",
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
                    web.window.location.reload();
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
                  onPressed: () {
                    networkApi.deleteNetworkAccess(node);
                    Navigator.pop(context);
                    web.window.location.reload();
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
