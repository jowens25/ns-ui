import 'package:flutter/material.dart';
import 'package:nct/api/SnmpApi.dart';
import 'package:provider/provider.dart';

class SnmpVersion2Card extends StatefulWidget {
  @override
  State<SnmpVersion2Card> createState() => _SnmpVersion2CardState();
}

class _SnmpVersion2CardState extends State<SnmpVersion2Card> {
  @override
  void initState() {
    super.initState();
    context.read<SnmpApi>().readV1v2cUsers();
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => addSnmpV1V2UserDialog(),
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
            child: buildSnmpV1V2UsersList(),
          ),
        ],
      ),
    );
  }

  Widget buildSnmpV1V2UsersList() {
    return Consumer<SnmpApi>(
      builder: (context, snmpApi, _) {
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
                ...snmpApi.v1v2cUsers.map((snmpUser) {
                  return TableRow(
                    children: [
                      // Version
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(snmpUser.version),
                      ),
                      // Group Name
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(snmpUser.groupName),
                      ),
                      // Community
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(snmpUser.community),
                      ),
                      // IP Version
                      // Padding(
                      //   padding: const EdgeInsets.all(2.0),
                      //   child: Text(snmpUser.ipVersion),
                      // ),
                      // IP Address v4
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(snmpUser.source),
                      ),
                      // IP Address v6
                      // Padding(
                      //   padding: const EdgeInsets.all(2.0),
                      //   child: Text(snmpUser.ip6Address),
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
                                _showDeleteUserDialog(snmpUser);
                              }
                              if (value == 'edit') {
                                _showEditUserDialog(snmpUser);
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

  void addSnmpV1V2UserDialog() {
    final ipv4AddressController = TextEditingController();
    //final ipv6AddressController = TextEditingController();
    final communityController = TextEditingController();

    // String selectedIpVersion = "ipv4";
    String selectedSnmpVersion = "v1";
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
                    value: selectedSnmpVersion,
                    decoration: InputDecoration(labelText: 'Version'),
                    items: [
                      DropdownMenuItem(value: "v1", child: Text("v1")),
                      DropdownMenuItem(value: "v2c", child: Text("v2c")),
                    ],
                    onChanged: (String? newValue) {
                      setDialogState(() {
                        selectedSnmpVersion = newValue!;
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
                    final snmpApi = context.read<SnmpApi>();
                    V1v2cUser snmpV1V2User = V1v2cUser.fromJson({
                      'ID': 0,
                      'version': selectedSnmpVersion,
                      'group_name': selectedGroup,
                      'community': communityController.text,
                      //'source': selectedIpVersion,
                      'source': ipv4AddressController.text,
                      //'ip6_address': ipv6AddressController.text,
                    });
                    snmpApi.writeV1v2cUser(snmpV1V2User);

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

  void _showDeleteUserDialog(V1v2cUser user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<SnmpApi>(
          builder: (context, snmpApi, _) {
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
                    await snmpApi.deleteV1v2cUser(user);
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

  void _showEditUserDialog(V1v2cUser user) {
    final ipv4AddressController = TextEditingController();
    //final ipv6AddressController = TextEditingController();
    final communityController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<SnmpApi>(
          builder: (context, snmpApi, _) {
            //
            ipv4AddressController.text = user.source;
            //ipv6AddressController.text = user.ip6Address;
            communityController.text = user.community;

            String selectedGroup = user.groupName;
            String selectedSnmpVersion = user.version;

            return AlertDialog(
              title: Text('Edit SNMP User'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //DropdownButtonFormField<String>(
                  TextField(
                    controller: ipv4AddressController,
                    decoration: InputDecoration(labelText: 'IP Address'),
                  ),

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
                    value: selectedSnmpVersion,
                    decoration: InputDecoration(labelText: 'Version'),
                    items: [
                      DropdownMenuItem(value: "v1", child: Text("v1")),
                      DropdownMenuItem(value: "v2c", child: Text("v2c")),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSnmpVersion = newValue!;
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
                    final snmpApi = context.read<SnmpApi>();

                    user.version = selectedSnmpVersion;
                    user.groupName = selectedGroup;
                    user.community = communityController.text;
                    //user.ipVersion = selectedIpVersion;
                    user.source = ipv4AddressController.text;
                    //user.ip6Address = ipv6AddressController.text;

                    snmpApi.editV1v2cUser(user);

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
}
