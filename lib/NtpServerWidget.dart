import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'NtpServer.dart';
import 'ApiService.dart';
import 'CardInfo.dart';

class NtpServerWidget extends StatefulWidget {
  @override
  _NtpServerWidgetState createState() => _NtpServerWidgetState();
}

class _NtpServerWidgetState extends State<NtpServerWidget> {
  @override
  void initState() {
    super.initState();
    final ntpServerProvider = Provider.of<NtpServerApi>(context, listen: false);

    ntpServerProvider.getRequest(ntpServer.status);
    ntpServerProvider.getRequest(ntpServer.instanceNumber);
    ntpServerProvider.getRequest(ntpServer.ipMode);
    ntpServerProvider.getRequest(ntpServer.ipAddress);
    ntpServerProvider.getRequest(ntpServer.macAddress);
    ntpServerProvider.getRequest(ntpServer.vlanStatus);
    ntpServerProvider.getRequest(ntpServer.vlanAddress);
    ntpServerProvider.getRequest(ntpServer.unicastMode);
    ntpServerProvider.getRequest(ntpServer.multicastMode);
    ntpServerProvider.getRequest(ntpServer.broadcastMode);
    ntpServerProvider.getRequest(ntpServer.precisionValue);
    ntpServerProvider.getRequest(ntpServer.pollIntervalValue);
    ntpServerProvider.getRequest(ntpServer.stratumValue);
    ntpServerProvider.getRequest(ntpServer.referenceId);
    ntpServerProvider.getRequest(ntpServer.smearingStatus);
    ntpServerProvider.getRequest(ntpServer.leap61Progress);
    ntpServerProvider.getRequest(ntpServer.leap59Progress);
    ntpServerProvider.getRequest(ntpServer.leap61Status);
    ntpServerProvider.getRequest(ntpServer.leap59Status);
    ntpServerProvider.getRequest(ntpServer.utcOffsetStatus);
    ntpServerProvider.getRequest(ntpServer.utcOffsetValue);
    ntpServerProvider.getRequest(ntpServer.requestsValue);
    ntpServerProvider.getRequest(ntpServer.responsesValue);
    ntpServerProvider.getRequest(ntpServer.requestsDroppedValue);
    ntpServerProvider.getRequest(ntpServer.broadcastsValue);
    ntpServerProvider.getRequest(ntpServer.clearCountersStatus);
    ntpServerProvider.getRequest(ntpServer.version);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<CardInfo> ntpcards = [
      CardInfo(
        title: 'NTP Server Configuration',
        content: Consumer<NtpServerApi>(
          builder:
              (context, api, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text('Core Version : ${api.get(ntpServer.version)}'),
                  Text('Instance Number: ${api.get(ntpServer.instanceNumber)}'),

                  Row(
                    children: [
                      Text("NTP Server Enable: "),
                      Checkbox(
                        value: api.get(ntpServer.status) == 'enabled',
                        onChanged: (bool? value) {
                          if (value != null) {
                            api.update(
                              ntpServer.status,
                              value ? 'enabled' : 'disabled',
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 140,
                        child: TextField(
                          controller: TextEditingController(
                            text: api.get(ntpServer.macAddress),
                          ),
                          onSubmitted: (value) {
                            api.update(ntpServer.macAddress, value);
                            //ntp.updateMacAddress(value);
                          },
                          decoration: InputDecoration(labelText: 'MAC Address'),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,

                    children: [
                      SizedBox(
                        width: 140,
                        child: TextField(
                          controller: TextEditingController(
                            text: api.get(ntpServer.vlanAddress),
                          ),
                          onSubmitted: (value) {
                            api.update(ntpServer.vlanAddress, value);
                          },
                          decoration: InputDecoration(
                            labelText: 'VLAN Address',
                          ),
                        ),
                      ),

                      Row(
                        children: [
                          SizedBox(width: 4),
                          Text("VLAN Enable: "),
                          Checkbox(
                            //value: ntp.vlanStatus == 'enabled',
                            value: api.get(ntpServer.vlanStatus) == 'enabled',
                            onChanged: (bool? value) {
                              if (value != null) {
                                api.update(
                                  ntpServer.vlanStatus,
                                  value ? 'enabled' : 'disabled',
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,

                    children: [
                      SizedBox(
                        width: 325,
                        child: TextField(
                          controller: TextEditingController(
                            text: api.get(ntpServer.ipAddress),
                          ),
                          onSubmitted: (value) {},
                          decoration: InputDecoration(labelText: 'IP Address'),
                        ),
                      ),
                      SizedBox(width: 8),

                      SizedBox(
                        width: 125,
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: "IP Mode",
                            border: OutlineInputBorder(),
                          ),
                          value:
                              ([
                                    'IPv4',
                                    'IPv6',
                                  ].contains(api.get(ntpServer.ipMode)))
                                  ? api.get(ntpServer.ipMode)
                                  : null,
                          items: const [
                            DropdownMenuItem(
                              value: 'IPv4',
                              child: Text('IPv4'),
                            ),
                            DropdownMenuItem(
                              value: 'IPv6',
                              child: Text('IPv6'),
                            ),
                          ],
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              //ntp.updateIpMode(newValue);
                              api.update(ntpServer.ipMode, newValue);
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Text("Clear Counters:"),
                      SizedBox(width: 10),

                      Checkbox(
                        value: false, //ntp.vlanStatus == 'enabled',
                        onChanged: (bool? value) {
                          if (value != null) {
                            //ntp.updateVlanStatus(value ? 'enabled' : 'disabled');
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
        ),
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          padding: EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 800,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: ntpcards.length,
          itemBuilder: (context, index) {
            final card = ntpcards[index];
            return Card(
              elevation: 4,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    Expanded(child: card.content),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

Widget labeledCheckbox(
  String label,
  bool value,
  ValueChanged<bool?> onChanged,
) {
  return Row(
    children: [Text(label), Checkbox(value: value, onChanged: onChanged)],
  );
}

Widget labeledTextField({
  required String label,
  required String value,
  required ValueChanged<String> onSubmitted,
  double width = 140,
}) {
  final controller = TextEditingController(text: value);
  return SizedBox(
    width: width,
    child: TextField(
      controller: controller,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(labelText: label),
    ),
  );
}

Widget labeledDropdown({
  required String label,
  required String? value,
  required List<String> items,
  required ValueChanged<String?> onChanged,
  double width = 140,
}) {
  return SizedBox(
    width: width,
    child: DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      value: value,
      items:
          items.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
      onChanged: onChanged,
    ),
  );
}




                  //      SizedBox(height: 12),
                  //      Divider(height: 2, thickness: 2, color: Colors.black),
                  //      SizedBox(height: 12),
                  //
                  //      Row(
                  //        children: [
                  //          Row(
                  //            children: [
                  //              Text("Unicast Mode: "),
                  //              Checkbox(
                  //                value: ntp.vlanStatus == 'enabled',
                  //                onChanged: (bool? value) {
                  //                  if (value != null) {
                  //                    //ntp.updateVlanStatus(value ? 'enabled' : 'disabled');
                  //                  }
                  //                },
                  //              ),
                  //            ],
                  //          ),
                  //          SizedBox(width: 12),
                  //          Row(
                  //            children: [
                  //              Text("Multicast Mode: "),
                  //              Checkbox(
                  //                value: ntp.vlanStatus == 'enabled',
                  //                onChanged: (bool? value) {
                  //                  if (value != null) {
                  //                    //ntp.updateVlanStatus(value ? 'enabled' : 'disabled');
                  //                  }
                  //                },
                  //              ),
                  //            ],
                  //          ),
                  //          SizedBox(width: 12),
                  //
                  //          Row(
                  //            children: [
                  //              Text("Broadcast Mode: "),
                  //              Checkbox(
                  //                value: ntp.vlanStatus == 'enabled',
                  //                onChanged: (bool? value) {
                  //                  if (value != null) {
                  //                    //ntp.updateVlanStatus(value ? 'enabled' : 'disabled');
                  //                  }
                  //                },
                  //              ),
                  //            ],
                  //          ),
                  //        ],
                  //      ),
                  //      Row(
                  //        children: [
                  //          Column(
                  //            crossAxisAlignment: CrossAxisAlignment.start,
                  //
                  //            children: [
                  //              Row(
                  //                crossAxisAlignment: CrossAxisAlignment.end,
                  //                children: [
                  //                  SizedBox(
                  //                    width: 140,
                  //                    child: TextField(
                  //                      controller: TextEditingController(
                  //                        text: ntp.macAddress,
                  //                      ),
                  //                      onSubmitted: (value) {
                  //                        ntp.updateMacAddress(value);
                  //                      },
                  //                      decoration: InputDecoration(labelText: 'Stratum'),
                  //                    ),
                  //                  ),
                  //                ],
                  //              ),
                  //
                  //              Row(
                  //                crossAxisAlignment: CrossAxisAlignment.end,
                  //                children: [
                  //                  SizedBox(
                  //                    width: 140,
                  //                    child: TextField(
                  //                      controller: TextEditingController(
                  //                        text: ntp.macAddress,
                  //                      ),
                  //                      onSubmitted: (value) {
                  //                        ntp.updateMacAddress(value);
                  //                      },
                  //                      decoration: InputDecoration(
                  //                        labelText: 'Poll Interval',
                  //                      ),
                  //                    ),
                  //                  ),
                  //                ],
                  //              ),
                  //              Row(
                  //                crossAxisAlignment: CrossAxisAlignment.end,
                  //                children: [
                  //                  SizedBox(
                  //                    width: 140,
                  //                    child: TextField(
                  //                      controller: TextEditingController(
                  //                        text: ntp.macAddress,
                  //                      ),
                  //                      onSubmitted: (value) {
                  //                        ntp.updateMacAddress(value);
                  //                      },
                  //                      decoration: InputDecoration(
                  //                        labelText: 'Precision',
                  //                      ),
                  //                    ),
                  //                  ),
                  //                ],
                  //              ),
                  //              SizedBox(height: 12),
                  //              SizedBox(
                  //                width: 140,
                  //                child: DropdownButtonFormField<String>(
                  //                  decoration: const InputDecoration(
                  //                    labelText: 'Reference ID',
                  //                    border: OutlineInputBorder(),
                  //                  ),
                  //                  value:
                  //                      (['IPv4', 'IPv6'].contains(ntp.ipMode))
                  //                          ? ntp.ipMode
                  //                          : null,
                  //                  items: const [
                  //                    DropdownMenuItem(
                  //                      value: 'IPv4',
                  //                      child: Text('IPv4'),
                  //                    ),
                  //                    DropdownMenuItem(
                  //                      value: 'IPv6',
                  //                      child: Text('IPv6'),
                  //                    ),
                  //                  ],
                  //                  onChanged: (String? newValue) {
                  //                    if (newValue != null) {
                  //                      ntp.updateIpMode(newValue);
                  //                    }
                  //                  },
                  //                ),
                  //              ),
                  //            ],
                  //          ),
                  //          SizedBox(width: 12),
                  //          Column(
                  //            crossAxisAlignment: CrossAxisAlignment.start,
                  //
                  //            children: [
                  //              Row(
                  //                children: [
                  //                  Text("Leap 59:"),
                  //                  SizedBox(width: 100),
                  //
                  //                  Checkbox(
                  //                    value: ntp.vlanStatus == 'enabled',
                  //                    onChanged: (bool? value) {
                  //                      if (value != null) {
                  //                        //ntp.updateVlanStatus(value ? 'enabled' : 'disabled');
                  //                      }
                  //                    },
                  //                  ),
                  //                  Text("In Progress: "),
                  //                ],
                  //              ),
                  //              Row(
                  //                children: [
                  //                  Text("Leap 61:"),
                  //                  SizedBox(width: 100),
                  //                  Checkbox(
                  //                    value: ntp.vlanStatus == 'enabled',
                  //                    onChanged: (bool? value) {
                  //                      if (value != null) {
                  //                        //ntp.updateVlanStatus(value ? 'enabled' : 'disabled');
                  //                      }
                  //                    },
                  //                  ),
                  //                  Text("In Progress: "),
                  //                ],
                  //              ),
                  //              Row(
                  //                children: [
                  //                  Text("UTC Smearing Enable:"),
                  //                  SizedBox(width: 12),
                  //
                  //                 Checkbox(
                  //                   value: ntp.vlanStatus == 'enabled',
                  //                   onChanged: (bool? value) {
                  //                     if (value != null) {
                  //                       //ntp.updateVlanStatus(value ? 'enabled' : 'disabled');
                  //                     }
                  //                   },
                  //                 ),
                  //               ],
                  //             ),
                  //             Row(
                  //               children: [
                  //                 Text("UTC Offset Enable:"),
                  //                 SizedBox(width: 33),
                  //                 Checkbox(
                  //                   value: ntp.vlanStatus == 'enabled',
                  //                   onChanged: (bool? value) {
                  //                     if (value != null) {
                  //                       //ntp.updateVlanStatus(value ? 'enabled' : 'disabled');
                  //                     }
                  //                   },
                  //                 ),
                  //               ],
                  //             ),
                  //             SizedBox(height: 12),
                  //             SizedBox(
                  //               width: 100,
                  //               child: TextField(
                  //                 controller: TextEditingController(
                  //                   text: ntp.vlanAddress,
                  //                 ),
                  //                 onSubmitted: (value) {
                  //                   ntp.updateVlanAddress(value);
                  //                 },
                  //                 decoration: InputDecoration(
                  //                   labelText: 'UTC Offset: ',
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ],
                  //     ),
                  //     SizedBox(height: 12),
                  //     Row(
                  //       children: [
                  //         Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //
                  //           children: [
                  //             Row(
                  //               crossAxisAlignment: CrossAxisAlignment.end,
                  //               children: [
                  //                 SizedBox(
                  //                   width: 140,
                  //                   child: TextField(
                  //                     controller: TextEditingController(
                  //                       text: ntp.macAddress,
                  //                     ),
                  //                     onSubmitted: (value) {
                  //                       ntp.updateMacAddress(value);
                  //                     },
                  //                     decoration: InputDecoration(
                  //                       labelText: 'Requests',
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //
                  //             Row(
                  //               crossAxisAlignment: CrossAxisAlignment.end,
                  //               children: [
                  //                 SizedBox(
                  //                   width: 140,
                  //                   child: TextField(
                  //                     controller: TextEditingController(
                  //                       text: ntp.macAddress,
                  //                     ),
                  //                     onSubmitted: (value) {
                  //                       ntp.updateMacAddress(value);
                  //                     },
                  //                     decoration: InputDecoration(
                  //                       labelText: 'Requests Dropped',
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           ],
                  //         ),
                  //         SizedBox(width: 12),
                  //         Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //
                  //           children: [
                  //             Row(
                  //               crossAxisAlignment: CrossAxisAlignment.end,
                  //               children: [
                  //                 SizedBox(
                  //                   width: 140,
                  //                   child: TextField(
                  //                     controller: TextEditingController(
                  //                       text: ntp.getProperty("mac-address")
                  //                       ntp.macAddress,
                  //                     ),
                  //                     onSubmitted: (value) {
                  //                       ntp.g
                  //                       ntp.updateMacAddress(value);
                  //                     },
                  //                     decoration: InputDecoration(
                  //                       labelText: 'Responses',
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //
                  //             Row(
                  //               crossAxisAlignment: CrossAxisAlignment.end,
                  //               children: [
                  //                 SizedBox(
                  //                   width: 140,
                  //                   child: TextField(
                  //                     controller: TextEditingController(
                  //                       text: ntp.macAddress,
                  //                     ),
                  //                     onSubmitted: (value) {
                  //                       ntp.updateMacAddress(value);
                  //                     },
                  //                     decoration: InputDecoration(
                  //                       labelText: 'Broadcasts',
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           ],
                  //         ),
                  //       ],
                  //     ),