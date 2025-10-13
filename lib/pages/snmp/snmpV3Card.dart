import 'package:flutter/material.dart';
import 'package:nct/api/SnmpApi.dart';
import 'package:provider/provider.dart';

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

    String? authPasswordError;
    String? privPasswordError;

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

                    decoration: InputDecoration(
                      labelText: 'Auth Passphrase',
                      errorText: authPasswordError,
                    ),
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

                    decoration: InputDecoration(
                      labelText: 'Priv Passphrase',
                      errorText: privPasswordError,
                    ),
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
                    bool valid = true;
                    setDialogState(() {
                      authPasswordError =
                          authPassphraseController.text.length < 8
                              ? 'must be at least 8 characters'
                              : null;
                      privPasswordError =
                          privPassphraseController.text.length < 8
                              ? 'must be at least 8 characters'
                              : null;
                      valid =
                          authPasswordError == null &&
                          privPasswordError == null;
                    });
                    if (!valid) return;

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

    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<SnmpApi>(
          builder: (context, snmpApi, _) {
            userNameController.text = user.userName;
            String selectedAuthType = user.authType;
            authPassphraseController.text = user.authPassphase;
            String selectedPrivType = user.privType;
            privPassphraseController.text = user.privPassphase;
            String selectedGroup = user.groupName;

            return AlertDialog(
              title: Text('Edit SNMP User'),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: userNameController,
                      readOnly: true,
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
                    TextFormField(
                      controller: authPassphraseController,
                      obscureText: true,
                      decoration: InputDecoration(labelText: 'Auth Passphrase'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'please enter a passphrase';
                        }
                        if (value.length < 8) {
                          return 'must be at least 8 characters';
                        }
                        return null;
                      },
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
                    TextFormField(
                      controller: privPassphraseController,
                      obscureText: true,

                      decoration: InputDecoration(labelText: 'Priv Passphrase'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'please enter a passphrase';
                        }
                        if (value.length < 8) {
                          return 'must be at least 8 characters';
                        }
                        return null;
                      },
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
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      user.userName = userNameController.text;
                      user.authType = selectedAuthType;
                      user.authPassphase = authPassphraseController.text;
                      user.privType = selectedPrivType;
                      user.privPassphase = privPassphraseController.text;
                      user.groupName = selectedGroup;
                      snmpApi.editV3User(user);
                      Navigator.pop(context);
                    }
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
