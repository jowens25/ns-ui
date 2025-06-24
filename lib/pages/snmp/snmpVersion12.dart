import 'package:flutter/material.dart';
import 'package:ntsc_ui/pages/basePage.dart';

// Model classes
class SnmpV12Item {
  String version;
  String groupName;
  String community;
  String ipVersion;
  String ipAddress4;
  String ipAddress6;
  bool isEditing;

  SnmpV12Item({
    required this.version,
    required this.groupName,
    required this.community,
    required this.ipVersion,
    required this.ipAddress4,
    required this.ipAddress6,
    this.isEditing = true,
  });
}

List<String> headerNames = [
  'Version',
  'Group Name',
  'Community',
  'IP Version',
  'IP Address v4',
  'IP Address v6',
  'Edit',
];

class SnmpVersion12Card extends StatefulWidget {
  const SnmpVersion12Card({super.key});

  @override
  State<SnmpVersion12Card> createState() => _SnmpVersion12CardState();
}

class _SnmpVersion12CardState extends State<SnmpVersion12Card> {
  List<SnmpV12Item> items = [];

  void _addItem() {
    setState(() {
      items.add(
        SnmpV12Item(
          version: 'v1',
          groupName: 'Read Only',
          community: '',
          ipVersion: 'IPv4',
          ipAddress4: '',
          ipAddress6: '',
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
                      'SNMP Version 1/2',
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
                        // Version
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
                                        ['v1', 'v2c']
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
                        // Group Name
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              item.isEditing
                                  ? DropdownButton<String>(
                                    value: item.groupName,
                                    onChanged: (val) {
                                      setState(() => item.groupName = val!);
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
                                  : Text(item.groupName),
                        ),
                        // Community
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              item.isEditing
                                  ? TextFormField(
                                    initialValue: item.community,
                                    onChanged: (val) => item.community = val,
                                  )
                                  : Text(item.community),
                        ),
                        // IP Version
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              item.isEditing
                                  ? DropdownButton<String>(
                                    value: item.ipVersion,
                                    onChanged: (val) {
                                      setState(() => item.ipVersion = val!);
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
                                  : Text(item.ipVersion),
                        ),
                        // IP Address v4
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              item.isEditing
                                  ? TextFormField(
                                    initialValue: item.ipAddress4,
                                    onChanged: (val) => item.ipAddress4 = val,
                                  )
                                  : Text(item.ipAddress4),
                        ),
                        // IP Address v6
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              item.isEditing
                                  ? TextFormField(
                                    initialValue: item.ipAddress6,
                                    onChanged: (val) => item.ipAddress6 = val,
                                  )
                                  : Text(item.ipAddress6),
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

class SnmpVersion12Page extends StatelessWidget {
  const SnmpVersion12Page({super.key});

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
