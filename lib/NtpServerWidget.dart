import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'NtpServerApi.dart';
import 'CardInfo.dart';

class NtpServerWidget extends StatefulWidget {
  @override
  _NtpServerWidgetState createState() => _NtpServerWidgetState();
}

class _NtpServerWidgetState extends State<NtpServerWidget> {
  @override
  void initState() {
    super.initState();
    final ntpApi = Provider.of<NtpServerApi>(context, listen: false);

    ntpApi.getRequest(ntpApi.statusKey);
    ntpApi.getRequest(ntpApi.instanceNumberKey);
    ntpApi.getRequest(ntpApi.ipModeKey);
    ntpApi.getRequest(ntpApi.ipAddressKey);
    ntpApi.getRequest(ntpApi.macAddressKey);
    ntpApi.getRequest(ntpApi.vlanStatusKey);
    ntpApi.getRequest(ntpApi.vlanAddressKey);
    ntpApi.getRequest(ntpApi.unicastModeKey);
    ntpApi.getRequest(ntpApi.multicastModeKey);
    ntpApi.getRequest(ntpApi.broadcastModeKey);
    ntpApi.getRequest(ntpApi.precisionValueKey);
    ntpApi.getRequest(ntpApi.pollIntervalValueKey);
    ntpApi.getRequest(ntpApi.stratumValueKey);
    ntpApi.getRequest(ntpApi.referenceIdKey);
    ntpApi.getRequest(ntpApi.smearingStatusKey);
    ntpApi.getRequest(ntpApi.leap61ProgressKey);
    ntpApi.getRequest(ntpApi.leap59ProgressKey);
    ntpApi.getRequest(ntpApi.leap61StatusKey);
    ntpApi.getRequest(ntpApi.leap59StatusKey);
    ntpApi.getRequest(ntpApi.utcOffsetStatusKey);
    ntpApi.getRequest(ntpApi.utcOffsetValueKey);
    ntpApi.getRequest(ntpApi.requestsValueKey);
    ntpApi.getRequest(ntpApi.responsesValueKey);
    ntpApi.getRequest(ntpApi.requestsDroppedValueKey);
    ntpApi.getRequest(ntpApi.broadcastsValueKey);
    ntpApi.getRequest(ntpApi.clearCountersStatusKey);
    ntpApi.getRequest(ntpApi.versionKey);
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
              (context, ntp, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text('Core Version : ${ntp.version}'),
                  Text('Instance Number: ${ntp.instanceNumber}'),

                  Row(
                    children: [
                      Text("NTP Server Enable: "),
                      Checkbox(
                        value: ntp.status == 'enabled',
                        onChanged: (bool? value) {
                          if (value != null) {
                            ntp.update(
                              ntp.status,
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
                            text: ntp.macAddress,
                          ),
                          onSubmitted: (value) {
                            ntp.update(ntp.macAddress, value);
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
                            text: ntp.vlanAddress,
                          ),
                          onSubmitted: (value) {
                            ntp.update(ntp.vlanAddressKey, value);
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
                            value: ntp.vlanStatus == 'enabled',
                            onChanged: (bool? value) {
                              if (value != null) {
                                ntp.update(
                                  ntp.vlanStatusKey,
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
                            text: ntp.ipAddress,
                            //text: ntp.get(ntp.ipAddress),
                          ),
                          onSubmitted: (value) {
                            ntp.update(ntp.ipAddressKey, value);
                          },
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
                              (['IPv4', 'IPv6'].contains(ntp.ipMode))
                                  ? ntp.ipMode
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
                          onChanged: (String? newValue) async {
                            if (newValue != null) {
                              //ntp.updateIpMode(newValue);
                              await ntp.update(ntp.ipModeKey, newValue);
                              await ntp.get(ntp.ipAddressKey);
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),
                  Divider(height: 2, thickness: 2, color: Colors.black),
                  SizedBox(height: 12),

                  Row(
                    children: [
                      Row(
                        children: [
                          Text("Unicast Mode: "),
                          Checkbox(
                            value: ntp.unicastMode == 'enabled',
                            onChanged: (bool? value) {
                              if (value != null) {
                                ntp.update(
                                  ntp.unicastModeKey,
                                  value ? 'enabled' : 'disabled',
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(width: 12),
                      Row(
                        children: [
                          Text("Multicast Mode: "),
                          Checkbox(
                            value: ntp.multicastMode == 'enabled',
                            onChanged: (bool? value) {
                              if (value != null) {
                                ntp.update(
                                  ntp.multicastModeKey,
                                  value ? 'enabled' : 'disabled',
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(width: 12),

                      Row(
                        children: [
                          Text("Broadcast Mode: "),
                          Checkbox(
                            value: ntp.broadcastMode == 'enabled',
                            onChanged: (bool? value) {
                              if (value != null) {
                                ntp.update(
                                  ntp.broadcastModeKey,
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
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 140,
                                child: TextField(
                                  controller: TextEditingController(
                                    text: ntp.stratumValue,
                                  ),
                                  onSubmitted: (value) {
                                    ntp.update(ntp.stratumValueKey, value);
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Stratum',
                                  ),
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
                                    text: ntp.pollIntervalValue,
                                  ),
                                  onSubmitted: (value) {
                                    ntp.update(ntp.pollIntervalValueKey, value);
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Poll Interval',
                                  ),
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
                                    text: ntp.precisionValue,
                                  ),
                                  onSubmitted: (value) {
                                    ntp.update(ntp.precisionValueKey, value);
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Precision',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          SizedBox(
                            width: 140,
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Reference ID',
                                border: OutlineInputBorder(),
                              ),
                              value:
                                  (['GPS', 'NTP'].contains(ntp.referenceId))
                                      ? ntp.referenceId
                                      : null,
                              items: const [
                                DropdownMenuItem(
                                  value: 'GPS',
                                  child: Text('GPS'),
                                ),
                                DropdownMenuItem(
                                  value: 'NTP',
                                  child: Text('NTP'),
                                ),
                              ],
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  ntp.update(ntp.referenceIdKey, newValue);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Row(
                            children: [
                              Text("Leap 59:"),
                              SizedBox(width: 100),

                              Checkbox(
                                value: ntp.leap59Status == 'enabled',
                                onChanged: (bool? value) {
                                  if (value != null) {
                                    ntp.update(
                                      ntp.leap59StatusKey,
                                      value ? 'enabled' : 'disabled',
                                    );
                                  }
                                },
                              ),
                              Text("In Progress: "),
                            ],
                          ),
                          Row(
                            children: [
                              Text("Leap 61:"),
                              SizedBox(width: 100),
                              Checkbox(
                                value: ntp.leap61Status == 'enabled',
                                onChanged: (bool? value) {
                                  if (value != null) {
                                    ntp.update(
                                      ntp.leap61StatusKey,
                                      value ? 'enabled' : 'disabled',
                                    );
                                  }
                                },
                              ),
                              Text("In Progress: "),
                            ],
                          ),
                          Row(
                            children: [
                              Text("UTC Smearing Enable:"),
                              SizedBox(width: 12),

                              Checkbox(
                                value: ntp.smearingStatus == 'enabled',
                                onChanged: (bool? value) {
                                  if (value != null) {
                                    ntp.update(
                                      ntp.smearingStatusKey,
                                      value ? 'enabled' : 'disabled',
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text("UTC Offset Enable:"),
                              SizedBox(width: 33),
                              Checkbox(
                                value: ntp.utcOffsetStatus == 'enabled',
                                onChanged: (bool? value) {
                                  if (value != null) {
                                    ntp.update(
                                      ntp.utcOffsetStatusKey,
                                      value ? 'enabled' : 'disabled',
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          SizedBox(
                            width: 100,
                            child: TextField(
                              controller: TextEditingController(
                                text: ntp.utcOffsetValue,
                              ),
                              onSubmitted: (value) {
                                ntp.update(ntp.utcOffsetValueKey, value);
                              },
                              decoration: InputDecoration(
                                labelText: 'UTC Offset: ',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 140,
                                child: TextField(
                                  controller: TextEditingController(
                                    text: ntp.requestsValue,
                                  ),
                                  onSubmitted: (value) {
                                    ntp.get(ntp.requestsValueKey);
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Requests',
                                  ),
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
                                    text: ntp.requestsDroppedValue,
                                  ),
                                  onSubmitted: (value) {
                                    ntp.get(ntp.requestsDroppedValueKey);
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Requests Dropped',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 140,
                                child: TextField(
                                  controller: TextEditingController(
                                    text: ntp.responsesValue,
                                  ),
                                  onSubmitted: (value) {
                                    ntp.get(ntp.responsesValueKey);
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Responses',
                                  ),
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
                                    text: ntp.broadcastsValue,
                                  ),
                                  onSubmitted: (value) {
                                    ntp.get(ntp.broadcastsValueKey);
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Broadcasts',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Text("Clear Counters:"),
                      SizedBox(width: 10),

                      Checkbox(
                        value: ntp.clearCountersStatus == 'enabled',
                        onChanged: (bool? value) {
                          if (value != null) {
                            ntp.update(
                              ntp.clearCountersStatusKey,
                              value ? 'enabled' : 'disabled',
                            );
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