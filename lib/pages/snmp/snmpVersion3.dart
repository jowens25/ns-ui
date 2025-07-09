import 'package:flutter/material.dart';
import 'package:ntsc_ui/pages/basePage.dart';
import 'package:ntsc_ui/api/LoginApi.dart';
import 'package:provider/provider.dart';

class SnmpVersion3Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'SNMP',
      description: 'Snmp Version3 Card:',
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [SnmpVersion3Card()],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SnmpVersion3Card extends StatefulWidget {
  @override
  State<SnmpVersion3Card> createState() => _SnmpVersion3CardState();
}

class _SnmpVersion3CardState extends State<SnmpVersion3Card> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loginApi = context.read<LoginApi>();
      loginApi.getAllSnmpV3Users();
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
                        'SNMP Version 3',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () => addSnmpV3UserDialog(),
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
            child: buildSnmpV3UsersList(),
          ),
        ],
      ),
    );
  }

  Widget buildSnmpV3UsersList() {
    return Consumer<LoginApi>(
      builder: (context, loginApi, _) {
        return SingleChildScrollView(
          child: Card(
            child: Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              children: [
                TableRow(
                  children:
                      SnmpV3User.getHeader()
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
                ...loginApi.snmpV3Users.map((snmpUser) {
                  return TableRow(
                    children: [
                      // Version
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(snmpUser.userName),
                      ),
                      // Group Name
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(snmpUser.authType),
                      ),
                      // Community
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(snmpUser.privType),
                      ),
                      // IP Version
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(snmpUser.groupName),
                      ),

                      // IP Address v4
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

  void addSnmpV3UserDialog() {
    final userNameController = TextEditingController();
    final authPassphraseController = TextEditingController();
    final privPassphraseController = TextEditingController();

    String selectedAuthType = "MD5";
    String selectedPrivType = "AES";
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
                  TextField(
                    controller: userNameController,
                    decoration: InputDecoration(labelText: 'User Name'),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedAuthType,
                    decoration: InputDecoration(labelText: 'Auth Type'),
                    items: [
                      DropdownMenuItem(value: "MD5", child: Text("MD5")),
                      DropdownMenuItem(value: "SHA", child: Text("SHA")),
                    ],
                    onChanged: (String? newValue) {
                      setDialogState(() {
                        selectedAuthType = newValue!;
                      });
                    },
                  ),
                  TextField(
                    controller: authPassphraseController,
                    decoration: InputDecoration(labelText: 'Auth Passphrase'),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedPrivType,
                    decoration: InputDecoration(labelText: 'Priv Type'),
                    items: [
                      DropdownMenuItem(value: "AES", child: Text("AES")),
                      DropdownMenuItem(value: "DES", child: Text("DES")),
                    ],
                    onChanged: (String? newValue) {
                      setDialogState(() {
                        selectedPrivType = newValue!;
                      });
                    },
                  ),
                  TextField(
                    controller: privPassphraseController,
                    decoration: InputDecoration(labelText: 'Priv Passphrase'),
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
                    SnmpV3User snmpV3User = SnmpV3User.fromJson({
                      'user_name': userNameController.text,
                      'auth_type': selectedAuthType,
                      'auth_passphrase': authPassphraseController.text,
                      'priv_type': selectedPrivType,
                      'priv_passphrase': privPassphraseController.text,
                      'group_name': selectedGroup,
                    });
                    loginApi.addSnmpV3User(snmpV3User);

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

  void _showDeleteUserDialog(SnmpV3User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<LoginApi>(
          builder: (context, loginApi, _) {
            return AlertDialog(
              title: Text('Delete User'),
              content: Text('Delete ${user.userName}?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    await loginApi.deleteSnmpV3User(user);
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

  void _showEditUserDialog(SnmpV3User user) {
    final userNameController = TextEditingController();
    final authPassphraseController = TextEditingController();
    final privPassphraseController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<LoginApi>(
          builder: (context, loginApi, _) {
            //
            userNameController.text = user.userName;
            String selectedAuthType = user.authType;
            authPassphraseController.text = user.authPassphase;
            String selectedPrivType = user.privType;
            privPassphraseController.text = user.privPassphase;
            String selectedGroup = user.groupName;

            return AlertDialog(
              title: Text('Add SNMP User'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: userNameController,
                    decoration: InputDecoration(labelText: 'User Name'),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedAuthType,
                    decoration: InputDecoration(labelText: 'Auth Type'),
                    items: [
                      DropdownMenuItem(value: "MD5", child: Text("MD5")),
                      DropdownMenuItem(value: "SHA", child: Text("SHA")),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedAuthType = newValue!;
                      });
                    },
                  ),
                  TextField(
                    controller: authPassphraseController,
                    decoration: InputDecoration(labelText: 'Auth Passphrase'),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedPrivType,
                    decoration: InputDecoration(labelText: 'Priv Type'),
                    items: [
                      DropdownMenuItem(value: "AES", child: Text("AES")),
                      DropdownMenuItem(value: "DES", child: Text("DES")),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPrivType = newValue!;
                      });
                    },
                  ),
                  TextField(
                    controller: privPassphraseController,
                    decoration: InputDecoration(labelText: 'Priv Passphrase'),
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

                    //user.version = selectedSnmpVersion;
                    //user.groupName = selectedGroup;
                    //user.community = communityController.text;
                    //user.ipVersion = selectedIpVersion;
                    //user.ip4Address = ipv4AddressController.text;
                    //user.ip6Address = ipv6AddressController.text;

                    user.userName = userNameController.text;
                    user.authType = selectedAuthType;
                    user.authPassphase = authPassphraseController.text;
                    user.privType = selectedPrivType;
                    user.privPassphase = privPassphraseController.text;
                    user.groupName = selectedGroup;
                    loginApi.updateSnmpV3User(user);

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
