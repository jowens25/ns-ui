import 'package:flutter/material.dart';
import 'package:nct/api/SnmpApi.dart';
import 'package:provider/provider.dart';
import 'package:nct/custom/custom.dart';

class SnmpStatusCard extends StatefulWidget {
  @override
  SnmpStatusCardState createState() => SnmpStatusCardState();
}

class SnmpStatusCardState extends State<SnmpStatusCard> {
  final sysObjIdController = TextEditingController();
  final contactController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  @override
  void initState() {
    super.initState();
    context.read<SnmpApi>().readSnmpInfo();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //context.read<SnmpApi>().getStatus();
      //context.read<SnmpApi>().getSyssnmpApi.sysDetails();
    });
  }

  @override
  void dispose() {
    sysObjIdController.dispose();
    contactController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SnmpApi>(
      builder: (context, snmpApi, _) {
        sysObjIdController.text = snmpApi.sysDetails.SysObjId;
        contactController.text = snmpApi.sysDetails.SysContact;
        locationController.text = snmpApi.sysDetails.SysLocation;
        descriptionController.text = snmpApi.sysDetails.SysDescription;
        return Card(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Info',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        tooltip: "Info",
                        onPressed: _showInfo,
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  LabeledSwitch(
                    myGap: 120,
                    label: "SNMP Enabled",
                    value: snmpApi.sysDetails.Status == "active",
                    onChanged: (bool value) {
                      setState(() {
                        snmpApi.sysDetails.Action = value ? "start" : "stop";
                        snmpApi.editSnmpInfo(snmpApi.sysDetails);
                      });
                    },
                  ),
                  SizedBox(height: 12),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          "SysObjectID",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        child: TextField(
                          onSubmitted: (value) {
                            snmpApi.sysDetails.SysObjId = value;
                            snmpApi.editSnmpInfo(snmpApi.sysDetails);
                          },
                          controller: sysObjIdController,
                          decoration: InputDecoration(isDense: true),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          "Contact",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        child: TextField(
                          onSubmitted: (value) {
                            snmpApi.sysDetails.SysContact = value;
                            snmpApi.editSnmpInfo(snmpApi.sysDetails);
                          },
                          controller: contactController,
                          decoration: InputDecoration(isDense: true),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          "Location",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        child: TextField(
                          onSubmitted: (value) {
                            snmpApi.sysDetails.SysLocation = value;
                            snmpApi.editSnmpInfo(snmpApi.sysDetails);
                          },
                          controller: locationController,
                          decoration: InputDecoration(isDense: true),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          "Description",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        child: TextField(
                          onSubmitted: (value) {
                            snmpApi.sysDetails.SysDescription = value;
                            snmpApi.editSnmpInfo(snmpApi.sysDetails);
                          },
                          controller: descriptionController,
                          decoration: InputDecoration(isDense: true),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () => {_showRestoreDefaultSNMPConfigDialog()},
                    child: Text('RESTORE DEFAULT CONFIGURATION'),
                  ),
                  //// addd button here
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
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text("Add, edit, remove and review SNMP")],
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

  void _showRestoreDefaultSNMPConfigDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<SnmpApi>(
          builder: (context, snmpApi, _) {
            return AlertDialog(
              content: Text(
                'Are you sure you want to restore the SNMP config?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    await context.read<SnmpApi>().resetSnmpConfig();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(snmpApi.response)));
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
      final snmpApi = context.read<SnmpApi>();
      snmpApi.readV1v2cUsers();
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
        return Consumer<SnmpApi>(
          builder: (context, snmpApi, _) {
            //
            ipv4AddressController.text = user.source;
            //ipv6AddressController.text = user.ip6Address;
            communityController.text = user.community;
            //String selectedIpVersion = user.ipVersion;
            String selectedGroup = user.groupName;
            String selectedSnmpVersion = user.version;

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

class SnmpVersion3Card extends StatefulWidget {
  @override
  State<SnmpVersion3Card> createState() => _SnmpVersion3CardState();
}

class _SnmpVersion3CardState extends State<SnmpVersion3Card> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final snmpApi = context.read<SnmpApi>();
      //snmpApi.getAllSnmpV3Users();
      snmpApi.readV3Users();
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
                        'SNMP V3 Users',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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
    return Consumer<SnmpApi>(
      builder: (context, snmpApi, _) {
        return SingleChildScrollView(
          child: Card(
            child: Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              children: [
                TableRow(
                  children:
                      V3User.getHeader()
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
                ...snmpApi.v3Users.map((snmpUser) {
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
    String selectedGroup = "roprivgroup";

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
                        value: "roprivgroup",
                        child: Text("Read Only"),
                      ),
                      DropdownMenuItem(
                        value: "rwprivgroup",
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
                    final snmpApi = context.read<SnmpApi>();
                    V3User snmpV3User = V3User.fromJson({
                      'ID': 0,
                      'version': 'usm',
                      'user_name': userNameController.text,
                      'auth_type': selectedAuthType,
                      'auth_passphrase': authPassphraseController.text,
                      'priv_type': selectedPrivType,
                      'priv_passphrase': privPassphraseController.text,
                      'group_name': selectedGroup,
                    });
                    snmpApi.writeV3User(snmpV3User);

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

  void _showDeleteUserDialog(V3User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<SnmpApi>(
          builder: (context, snmpApi, _) {
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
                    //await snmpApi.deleteV3User(user);
                    await snmpApi.deleteV3User(user);
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

  void _showEditUserDialog(V3User user) {
    final userNameController = TextEditingController();
    final authPassphraseController = TextEditingController();
    final privPassphraseController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<SnmpApi>(
          builder: (context, snmpApi, _) {
            //
            userNameController.text = user.userName;
            String selectedAuthType = user.authType;
            authPassphraseController.text = user.authPassphase;
            String selectedPrivType = user.privType;
            privPassphraseController.text = user.privPassphase;
            String selectedGroup = user.groupName;

            return AlertDialog(
              title: Text('Edit SNMP User'),
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
                        value: "roprivgroup",
                        child: Text("Read Only"),
                      ),
                      DropdownMenuItem(
                        value: "rwprivgroup",
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
                    final snmpApi = context.read<SnmpApi>();

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

                    snmpApi.editV3User(user);
                    //snmpApi.readV3Users();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('SNMP User added')));
                  },
                  child: Text('Submit Edits'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// Model classes
class SnmpTrapItem {
  String version;
  String user;
  String destinationIpVersion;
  String destinationIp;
  String port;
  String engineId;
  String authType;
  String authPassphrase;
  String privType;
  String privPassphrase;
  bool isEditing;

  SnmpTrapItem({
    required this.version,
    required this.user,
    required this.destinationIpVersion,
    required this.destinationIp,
    required this.port,
    required this.engineId,
    required this.authType,
    required this.authPassphrase,
    required this.privType,
    required this.privPassphrase,
    this.isEditing = true,
  });
}

List<String> headerNames = [
  'Version',
  'User',
  'Destination Ip Version',
  'Destination Ip',
  'Port',
  'Engine Id',
  'Auth Type',
  'Auth Passphrase',
  'Priv Type',
  'Priv Passphrase',
  'Edit',
];

class SnmpTrapsCard extends StatefulWidget {
  const SnmpTrapsCard({super.key});

  @override
  State<SnmpTrapsCard> createState() => _SnmpTrapCardState();
}

class _SnmpTrapCardState extends State<SnmpTrapsCard> {
  List<SnmpTrapItem> items = [];

  void _addItem() {
    setState(() {
      items.add(
        SnmpTrapItem(
          version: 'v1',
          user: '',
          destinationIpVersion: 'IPv4',
          destinationIp: '',
          port: '162',
          engineId: '0x',
          authType: 'MD5',
          authPassphrase: '',
          privType: 'AES',
          privPassphrase: '',
          isEditing: true,
        ),
      );
    });
  }

  void _saveItem(int index) {
    setState(() {
      items[index].isEditing = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Item saved successfully')));
  }

  @override
  Widget build(BuildContext context) {
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
                      'SNMP Traps',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add),
                    tooltip: 'Add SNMP Configuration',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Horizontally scrollable table
              Table(
                defaultColumnWidth: IntrinsicColumnWidth(),
                border: TableBorder.all(color: Colors.grey.shade300),
                children: [
                  // Header row
                  TableRow(
                    children:
                        headerNames
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
                  ...items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              item.isEditing
                                  ? DropdownButton<String>(
                                    value: item.version,
                                    onChanged: (val) {
                                      setState(() => item.version = val!);
                                    },
                                    items:
                                        ['v1', 'v2c', 'v3']
                                            .map(
                                              (e) => DropdownMenuItem(
                                                value: e,
                                                child: Text(e),
                                              ),
                                            )
                                            .toList(),
                                  )
                                  : Text(item.version),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              item.isEditing
                                  ? TextFormField(
                                    initialValue: item.user,
                                    onChanged: (val) => item.user = val,
                                  )
                                  : Text(item.user),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              item.isEditing
                                  ? DropdownButton<String>(
                                    value: item.destinationIpVersion,
                                    onChanged: (val) {
                                      setState(
                                        () => item.destinationIpVersion = val!,
                                      );
                                    },
                                    items:
                                        ['IPv4', 'IPv6']
                                            .map(
                                              (e) => DropdownMenuItem(
                                                value: e,
                                                child: Text(e),
                                              ),
                                            )
                                            .toList(),
                                  )
                                  : Text(item.destinationIpVersion),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              item.isEditing
                                  ? TextFormField(
                                    initialValue: item.destinationIp,
                                    onChanged:
                                        (val) => item.destinationIp = val,
                                  )
                                  : Text(item.destinationIp),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              item.isEditing
                                  ? TextFormField(
                                    initialValue: item.port,
                                    onChanged: (val) => item.port = val,
                                  )
                                  : Text(item.port),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              item.isEditing
                                  ? TextFormField(
                                    initialValue: item.engineId,
                                    onChanged: (val) => item.engineId = val,
                                  )
                                  : Text(item.engineId),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              item.isEditing
                                  ? DropdownButton<String>(
                                    value: item.authType,
                                    onChanged: (val) {
                                      setState(() => item.authType = val!);
                                    },
                                    items:
                                        ['MD5', 'SHA']
                                            .map(
                                              (e) => DropdownMenuItem(
                                                value: e,
                                                child: Text(e),
                                              ),
                                            )
                                            .toList(),
                                  )
                                  : Text(item.authType),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              item.isEditing
                                  ? TextFormField(
                                    initialValue: item.authPassphrase,
                                    onChanged:
                                        (val) => item.authPassphrase = val,
                                  )
                                  : Text(item.authPassphrase),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              item.isEditing
                                  ? DropdownButton<String>(
                                    value: item.privType,
                                    onChanged: (val) {
                                      setState(() => item.privType = val!);
                                    },
                                    items:
                                        ['AES', 'DES']
                                            .map(
                                              (e) => DropdownMenuItem(
                                                value: e,
                                                child: Text(e),
                                              ),
                                            )
                                            .toList(),
                                  )
                                  : Text(item.privType),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              item.isEditing
                                  ? TextFormField(
                                    initialValue: item.privPassphrase,
                                    onChanged:
                                        (val) => item.privPassphrase = val,
                                  )
                                  : Text(item.privPassphrase),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            icon: Icon(
                              item.isEditing ? Icons.check : Icons.edit,
                            ),
                            onPressed: () {
                              if (item.isEditing) {
                                _saveItem(index);
                              } else {
                                setState(() => item.isEditing = true);
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
