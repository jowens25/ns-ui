import 'package:flutter/material.dart';
import 'package:ntsc_ui/pages/basePage.dart';

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

class SnmpTrapsPage extends StatelessWidget {
  const SnmpTrapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'SNMP',
      description: 'Snmp Version 3 Card:',
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [SnmpTrapsCard()],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
