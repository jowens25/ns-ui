import 'package:flutter/material.dart';
import 'package:ntsc_ui/pages/basePage.dart';

// Model classes
class SnmpV3Item {
  String userName;
  String authType;
  String authPassphrase;
  String privType;
  String privPassphrase;
  String permissions;
  bool isEditing;

  SnmpV3Item({
    required this.userName,
    required this.authType,
    required this.authPassphrase,
    required this.privType,
    required this.privPassphrase,
    required this.permissions,
    this.isEditing = true,
  });
}

List<String> headerNames = [
  'User Name',
  'Auth Type',
  'Auth Passphrase',
  'Priv Type',
  'Priv Passphrase',
  'Permissions',
  'Edit',
];

class SnmpVersion3Card extends StatefulWidget {
  const SnmpVersion3Card({super.key});

  @override
  State<SnmpVersion3Card> createState() => _SnmpVersion3CardState();
}

class _SnmpVersion3CardState extends State<SnmpVersion3Card> {
  List<SnmpV3Item> items = [];

  void _addItem() {
    setState(() {
      items.add(
        SnmpV3Item(
          userName: ' ',
          authType: 'MD5',
          authPassphrase: ' ',
          privType: 'AES',
          privPassphrase: ' ',
          permissions: 'Read Only',
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
                      'SNMP Version 3',
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
                                  ? TextFormField(
                                    initialValue: item.userName,
                                    onChanged: (val) => item.userName = val,
                                  )
                                  : Text(item.userName),
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
                          child:
                              item.isEditing
                                  ? DropdownButton<String>(
                                    value: item.permissions,
                                    onChanged: (val) {
                                      setState(() => item.permissions = val!);
                                    },
                                    items:
                                        ['Read Only', 'Read/Write']
                                            .map(
                                              (e) => DropdownMenuItem(
                                                value: e,
                                                child: Text(e),
                                              ),
                                            )
                                            .toList(),
                                  )
                                  : Text(item.permissions),
                        ),
                        // Edit/Save button
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

class SnmpVersion3Page extends StatelessWidget {
  const SnmpVersion3Page({super.key});

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
