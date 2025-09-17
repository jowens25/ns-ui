import 'package:flutter/material.dart';
import 'package:nct/pages/basePage.dart';
import 'package:nct/custom/custom.dart';
import 'package:provider/provider.dart';
import 'package:nct/api/DeviceApi.dart';

class DeviceConfigCard extends StatefulWidget {
  @override
  State<DeviceConfigCard> createState() => _DeviceConfigCardState();
}

class _DeviceConfigCardState extends State<DeviceConfigCard> {
  final deviceCtrl = TextEditingController();
  final inputPriorityCtrl = TextEditingController();
  final faultCtrlA = TextEditingController();
  final faultCtrlB = TextEditingController();
  final lowInp0Ctrl = TextEditingController();
  final lowInp1Ctrl = TextEditingController();

  //final pollIntervalController = TextEditingController();
  //final precisionController = TextEditingController();
  //final referenceIdController = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deviceApi = context.read<DeviceApi>();
      //deviceApi.readAll();
      deviceApi.readProperty("baudrate");
      deviceApi.readProperty("input_priority");
      deviceApi.readProperty("fault_threshold");
      deviceApi.readProperty('fault_threshold_a');
      deviceApi.readProperty('fault_threshold_b');
      deviceApi.readProperty('input_low_threshold_0');
      deviceApi.readProperty('input_low_threshold_1');

      //deviceApi.readProperty("poll_interval");
      //deviceApi.readProperty("precision");
      //deviceApi.readProperty("reference_id");
    });
  }

  @override
  void dispose() {
    deviceCtrl.dispose();
    inputPriorityCtrl.dispose();
    faultCtrlA.dispose();
    faultCtrlB.dispose();
    lowInp0Ctrl.dispose();
    lowInp1Ctrl.dispose();
    //pollIntervalController.dispose();
    //precisionController.dispose();
    //referenceIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceApi>(
      builder: (context, deviceApi, _) {
        deviceCtrl.text = deviceApi.device["baudrate"];
        inputPriorityCtrl.text = deviceApi.device["input_priority"];
        faultCtrlA.text = deviceApi.device['fault_threshold_a'];
        faultCtrlB.text = deviceApi.device['fault_threshold_b'];
        lowInp0Ctrl.text = deviceApi.device['input_low_threshold_0'];
        lowInp1Ctrl.text = deviceApi.device['input_low_threshold_1'];

        //pollIntervalController.text = deviceApi.device['poll_interval'];
        //precisionController.text = deviceApi.device['precision'];

        return Card(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LabeledText(
                    label: "Rear Panel Baudrate",
                    controller: deviceCtrl,
                    myGap: 300,
                    onSubmitted: (value) {
                      //deviceApi.device['baudrate'] = value;
                      //deviceApi.writeProperty('stratum');
                    },
                  ),

                  LabeledText(
                    label: "Input Priority",
                    controller: inputPriorityCtrl,
                    myGap: 300,
                    onSubmitted: (value) {
                      //deviceApi.device['baudrate'] = value;
                      //deviceApi.writeProperty('stratum');
                    },
                  ),
                  LabeledText(
                    label: "Fault Threshold A",
                    controller: faultCtrlA,
                    myGap: 300,
                    onSubmitted: (value) {
                      //deviceApi.device['baudrate'] = value;
                      //deviceApi.writeProperty('stratum');
                    },
                  ),
                  LabeledText(
                    label: "Fault Threshold B",
                    controller: faultCtrlA,
                    myGap: 300,
                    onSubmitted: (value) {
                      //deviceApi.device['baudrate'] = value;
                      //deviceApi.writeProperty('stratum');
                    },
                  ),
                  LabeledText(
                    label: "Low Input 0",
                    controller: lowInp0Ctrl,
                    myGap: 300,
                    onSubmitted: (value) {
                      //deviceApi.device['baudrate'] = value;
                      //deviceApi.writeProperty('stratum');
                    },
                  ),
                  LabeledText(
                    label: "Low Input 1",
                    controller: lowInp1Ctrl,
                    myGap: 300,
                    onSubmitted: (value) {
                      //deviceApi.device['baudrate'] = value;
                      //deviceApi.writeProperty('stratum');
                    },
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      deviceApi.writeProperty('save_flash');
                    },
                    child: Text('Save flash'),
                  ),
                  SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: () {
                      deviceApi.writeProperty('reset_flash');
                    },
                    child: Text('Reset flash'),
                  ),
                  // LabeledText(
                  //   label: "Poll Interval",
                  //   controller: pollIntervalController,
                  //   myGap: 150,
                  //   onSubmitted: (value) {
                  //     deviceApi.device['poll_interval'] = value;
                  //     deviceApi.writeProperty('poll_interval');
                  //   },
                  // ),
                  // LabeledText(
                  //   label: "Precision",
                  //   controller: precisionController,
                  //   myGap: 150,
                  //   onSubmitted: (value) {
                  //     deviceApi.device['precision'] = value;
                  //     deviceApi.writeProperty('precision');
                  //   },
                  // ),
                  // LabeledDropdown<String>(
                  //   myGap: 150,
                  //   label: 'Reference ID:',
                  //   value: deviceApi.device['reference_id'],
                  //   items: [
                  //     "NTP",
                  //     "NULL",
                  //     "LOCL",
                  //     "CESM",
                  //     "RBDM",
                  //     "PPS",
                  //     "IRIG",
                  //     "ACTS",
                  //     "USNO",
                  //     "PTB",
                  //     "TDF",
                  //     "DCF",
                  //     "MSF",
                  //     "WWV",
                  //     "WWVB",
                  //     "WWVH",
                  //     "CHU",
                  //     "LORC",
                  //     "OMEG",
                  //     "GPS",
                  //     "NA",
                  //   ],
                  //   onChanged: (newValue) {
                  //     setState(() {
                  //       deviceApi.device['reference_id'] = newValue;
                  //       deviceApi.writeProperty('reference_id');
                  //     });
                  //   },
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class DeviceConfigPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'NTP',
      description: 'NTP Server ServerConfig Info:',
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Actions
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [DeviceConfigCard()],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
