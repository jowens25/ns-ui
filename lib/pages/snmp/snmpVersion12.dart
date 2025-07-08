import 'package:flutter/material.dart';
import 'package:ntsc_ui/pages/basePage.dart';
import 'package:ntsc_ui/api/LoginApi.dart';
import 'package:provider/provider.dart';

class SnmpVersion12Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'SNMP',
      description: 'Snmp Version12 Card:',
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [SnmpVersion12Card()],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SnmpVersion12Card extends StatefulWidget {
  @override
  State<SnmpVersion12Card> createState() => _SnmpVersion12CardState();
}

class _SnmpVersion12CardState extends State<SnmpVersion12Card> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loginApi = context.read<LoginApi>();
      loginApi.getAllSnmpV1V2cUsers();
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
                        'SNMP Version 1 - Version 2c',
                        style: TextStyle(fontWeight: FontWeight.bold),
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
            height: 400,
            padding: EdgeInsets.all(16),
            child: buildSnmpV1V2UsersList(),
          ),
        ],
      ),
    );
  }

  Widget buildSnmpV1V2UsersList() {
    return Consumer<LoginApi>(
      builder: (context, loginApi, _) {
        return SingleChildScrollView(
          child: Card(
            child: Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              children: [
                TableRow(
                  children:
                      SnmpV1V2cUser.getHeader()
                          .map(
                            (name) => Padding(
                              padding: const EdgeInsets.all(8.0),
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
                ...loginApi.snmpV1V2cUsers.map((snmpUser) {
                  return TableRow(
                    children: [
                      // Version
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(snmpUser.version),
                      ),
                      // Group Name
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(snmpUser.groupName),
                      ),
                      // Community
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(snmpUser.community),
                      ),
                      // IP Version
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(snmpUser.ipVersion),
                      ),
                      // IP Address v4
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(snmpUser.ip4Address),
                      ),
                      // IP Address v6
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(snmpUser.ip6Address),
                      ),
                      // Edit button
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: PopupMenuButton<String>(
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
    final ipv6AddressController = TextEditingController();
    final communityController = TextEditingController();

    String selectedIpVersion = "ipv4";
    String selectedSnmpVersion = "v1";
    String selectedGroup = "read_only";

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
                  DropdownButtonFormField<String>(
                    value: selectedIpVersion,
                    decoration: InputDecoration(labelText: 'IP Version'),
                    items: [
                      DropdownMenuItem(value: "ipv4", child: Text("IPv4")),
                      DropdownMenuItem(value: "ipv6", child: Text("IPv6")),
                    ],
                    onChanged: (String? newValue) {
                      setDialogState(() {
                        selectedIpVersion = newValue!;
                      });
                    },
                  ),
                  TextField(
                    controller: ipv4AddressController,
                    decoration: InputDecoration(labelText: 'IPv4 Address'),
                  ),
                  TextField(
                    controller: ipv6AddressController,
                    decoration: InputDecoration(labelText: 'IPv6 Address'),
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
                        value: "read_only",
                        child: Text("Read Only"),
                      ),
                      DropdownMenuItem(
                        value: "read_write",
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
                    final loginApi = context.read<LoginApi>();
                    SnmpV1V2cUser snmpV1V2User = SnmpV1V2cUser.fromJson({
                      'version': selectedSnmpVersion,
                      'group_name': selectedGroup,
                      'community': communityController.text,
                      'ip_version': selectedIpVersion,
                      'ip4_address': ipv4AddressController.text,
                      'ip6_address': ipv6AddressController.text,
                    });
                    loginApi.addSnmpV1V2User(snmpV1V2User);

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

  void _showDeleteUserDialog(SnmpV1V2cUser user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<LoginApi>(
          builder: (context, loginApi, _) {
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
                    await loginApi.deleteSnmpV1V2cUser(user);
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

  void _showEditUserDialog(SnmpV1V2cUser user) {
    final ipv4AddressController = TextEditingController();
    final ipv6AddressController = TextEditingController();
    final communityController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<LoginApi>(
          builder: (context, loginApi, _) {
            //
            ipv4AddressController.text = user.ip4Address;
            ipv6AddressController.text = user.ip6Address;
            communityController.text = user.community;
            String selectedIpVersion = user.ipVersion;
            String selectedGroup = user.groupName;
            String selectedSnmpVersion = user.version;

            return AlertDialog(
              title: Text('Edit SNMP User'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedIpVersion,
                    decoration: InputDecoration(labelText: 'IP Version'),
                    items: [
                      DropdownMenuItem(value: "ipv4", child: Text("IPv4")),
                      DropdownMenuItem(value: "ipv6", child: Text("IPv6")),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedIpVersion = newValue!;
                      });
                    },
                  ),
                  TextField(
                    controller: ipv4AddressController,
                    decoration: InputDecoration(labelText: 'IPv4 Address'),
                  ),
                  TextField(
                    controller: ipv6AddressController,
                    decoration: InputDecoration(labelText: 'IPv6 Address'),
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
                        value: "read_only",
                        child: Text("Read Only"),
                      ),
                      DropdownMenuItem(
                        value: "read_write",
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
                    final loginApi = context.read<LoginApi>();

                    user.version = selectedSnmpVersion;
                    user.groupName = selectedGroup;
                    user.community = communityController.text;
                    user.ipVersion = selectedIpVersion;
                    user.ip4Address = ipv4AddressController.text;
                    user.ip6Address = ipv6AddressController.text;

                    loginApi.updateSnmpV1V2cUser(user);

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
