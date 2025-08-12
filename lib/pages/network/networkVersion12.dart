import 'package:flutter/material.dart';
import 'package:ntsc_ui/pages/basePage.dart';
//import 'package:ntsc_ui/api/LoginApi.dart';
import 'package:provider/provider.dart';
import 'package:ntsc_ui/api/NetworkApi.dart';

class NetworkVersion12Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'SNMP',
      description: 'Network Version12 Card:',
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [NetworkVersion12Card()],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class NetworkVersion12Card extends StatefulWidget {
  @override
  State<NetworkVersion12Card> createState() => _NetworkVersion12CardState();
}

class _NetworkVersion12CardState extends State<NetworkVersion12Card> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final networkApi = context.read<NetworkApi>();
      networkApi.readV1v2cUsers();
    });
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
                        'SNMP V1/V2c Users',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () => addNetworkV1V2UserDialog(),
                      icon: const Icon(Icons.add),
                      tooltip: 'Add SNMP Configuration',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 200,
            padding: EdgeInsets.all(16),
            child: buildNetworkV1V2UsersList(),
          ),
        ],
      ),
    );
  }

  Widget buildNetworkV1V2UsersList() {
    return Consumer<NetworkApi>(
      builder: (context, networkApi, _) {
        return SingleChildScrollView(
          child: Card(
            child: Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              children: [
                TableRow(
                  children:
                      V1v2cUser.getHeader()
                          .map(
                            (name) => Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
                // Data rows
                ...networkApi.v1v2cUsers.map((networkUser) {
                  return TableRow(
                    children: [
                      // Version
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(networkUser.version),
                      ),
                      // Group Name
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(networkUser.groupName),
                      ),
                      // Community
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(networkUser.community),
                      ),
                      // IP Version
                      // Padding(
                      //   padding: const EdgeInsets.all(2.0),
                      //   child: Text(networkUser.ipVersion),
                      // ),
                      // IP Address v4
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(networkUser.source),
                      ),
                      // IP Address v6
                      // Padding(
                      //   padding: const EdgeInsets.all(2.0),
                      //   child: Text(networkUser.ip6Address),
                      // ),
                      // Edit button
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,

                        child: SizedBox(
                          height: 36,
                          child: PopupMenuButton<String>(
                            icon: Icon(Icons.settings, size: 18),

                            onSelected: (value) {
                              if (value == 'delete') {
                                _showDeleteUserDialog(networkUser);
                              }
                              if (value == 'edit') {
                                _showEditUserDialog(networkUser);
                              }
                            },
                            itemBuilder:
                                (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 16),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          size: 16,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  void addNetworkV1V2UserDialog() {
    final ipv4AddressController = TextEditingController();
    //final ipv6AddressController = TextEditingController();
    final communityController = TextEditingController();

    // String selectedIpVersion = "ipv4";
    String selectedNetworkVersion = "v1";
    String selectedGroup = "ronoauthgroup";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Add SNMP User'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //DropdownButtonFormField<String>(
                  //  value: selectedIpVersion,
                  //  decoration: InputDecoration(labelText: 'IP Version'),
                  //  items: [
                  //    DropdownMenuItem(value: "ipv4", child: Text("IPv4")),
                  //    DropdownMenuItem(value: "ipv6", child: Text("IPv6")),
                  //  ],
                  //  onChanged: (String? newValue) {
                  //    setDialogState(() {
                  //      selectedIpVersion = newValue!;
                  //    });
                  //  },
                  //),
                  TextField(
                    controller: ipv4AddressController,
                    decoration: InputDecoration(labelText: 'IP Address'),
                  ),
                  //TextField(
                  //  controller: ipv6AddressController,
                  //  decoration: InputDecoration(labelText: 'IPv6 Address'),
                  //),
                  TextField(
                    controller: communityController,
                    decoration: InputDecoration(labelText: 'Community'),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedGroup,
                    decoration: InputDecoration(labelText: 'Permissions'),
                    items: [
                      DropdownMenuItem(
                        value: "ronoauthgroup",
                        child: Text("Read Only"),
                      ),
                      DropdownMenuItem(
                        value: "rwnoauthgroup",
                        child: Text("Read/Write"),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      setDialogState(() {
                        selectedGroup = newValue!;
                      });
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedNetworkVersion,
                    decoration: InputDecoration(labelText: 'Version'),
                    items: [
                      DropdownMenuItem(value: "v1", child: Text("v1")),
                      DropdownMenuItem(value: "v2c", child: Text("v2c")),
                    ],
                    onChanged: (String? newValue) {
                      setDialogState(() {
                        selectedNetworkVersion = newValue!;
                      });
                    },
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
                    V1v2cUser networkV1V2User = V1v2cUser.fromJson({
                      'ID': 0,
                      'version': selectedNetworkVersion,
                      'group_name': selectedGroup,
                      'community': communityController.text,
                      //'source': selectedIpVersion,
                      'source': ipv4AddressController.text,
                      //'ip6_address': ipv6AddressController.text,
                    });
                    networkApi.writeV1v2cUser(networkV1V2User);

                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('SNMP User added')));
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

  void _showDeleteUserDialog(V1v2cUser user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<NetworkApi>(
          builder: (context, networkApi, _) {
            return AlertDialog(
              title: Text('Delete User'),
              content: Text('Delete ${user.community}?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    await networkApi.deleteV1v2cUser(user);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("deleted i think")));
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

  void _showEditUserDialog(V1v2cUser user) {
    final ipv4AddressController = TextEditingController();
    //final ipv6AddressController = TextEditingController();
    final communityController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<NetworkApi>(
          builder: (context, networkApi, _) {
            //
            ipv4AddressController.text = user.source;
            //ipv6AddressController.text = user.ip6Address;
            communityController.text = user.community;
            //String selectedIpVersion = user.ipVersion;
            String selectedGroup = user.groupName;
            String selectedNetworkVersion = user.version;

            return AlertDialog(
              title: Text('Edit SNMP User'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //DropdownButtonFormField<String>(
                  //  value: selectedIpVersion,
                  //  decoration: InputDecoration(labelText: 'IP Version'),
                  //  items: [
                  //    DropdownMenuItem(value: "ipv4", child: Text("IPv4")),
                  //    DropdownMenuItem(value: "ipv6", child: Text("IPv6")),
                  //  ],
                  //  onChanged: (String? newValue) {
                  //    setState(() {
                  //      selectedIpVersion = newValue!;
                  //    });
                  //  },
                  //),
                  TextField(
                    controller: ipv4AddressController,
                    decoration: InputDecoration(labelText: 'IP Address'),
                  ),
                  //TextField(
                  //  controller: ipv6AddressController,
                  //  decoration: InputDecoration(labelText: 'IPv6 Address'),
                  //),
                  TextField(
                    controller: communityController,
                    decoration: InputDecoration(labelText: 'Community'),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedGroup,
                    decoration: InputDecoration(labelText: 'Permissions'),
                    items: [
                      DropdownMenuItem(
                        value: "ronoauthgroup",
                        child: Text("Read Only"),
                      ),
                      DropdownMenuItem(
                        value: "rwnoauthgroup",
                        child: Text("Read/Write"),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedGroup = newValue!;
                      });
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedNetworkVersion,
                    decoration: InputDecoration(labelText: 'Version'),
                    items: [
                      DropdownMenuItem(value: "v1", child: Text("v1")),
                      DropdownMenuItem(value: "v2c", child: Text("v2c")),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedNetworkVersion = newValue!;
                      });
                    },
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

                    user.version = selectedNetworkVersion;
                    user.groupName = selectedGroup;
                    user.community = communityController.text;
                    //user.ipVersion = selectedIpVersion;
                    user.source = ipv4AddressController.text;
                    //user.ip6Address = ipv6AddressController.text;

                    networkApi.editV1v2cUser(user);

                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('SNMP User added')));
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
}
