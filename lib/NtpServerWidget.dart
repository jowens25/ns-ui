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
    List<CardInfo> ntpCards = [
      CardInfo(
        title: 'NTP Server Configuration',
        content: Consumer<NtpServerApi>(
          builder:
              (context, ntp, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoText('Core Version', ntp.version),
                  _infoText('Instance Number', ntp.instanceNumber),
                  _checkboxRow(
                    'NTP Server Enable',
                    ntp.status == 'enabled',
                    (v) =>
                        ntp.update(ntp.statusKey, v ? 'enabled' : 'disabled'),
                  ),

                  _textFieldRow(
                    'MAC Address',
                    ntp.macAddress,
                    (v) => ntp.update(ntp.macAddress, v),
                  ),
                  _vlanRow(ntp),
                  _ipModeRow(ntp),
                  const Divider(thickness: 2),

                  _modeCheckboxRow(ntp),
                  _stratumConfig(ntp),
                  _leapAndUtcConfig(ntp),
                  _statsConfig(ntp),
                  _checkboxRow(
                    'Clear Counters',
                    ntp.clearCountersStatus == 'enabled',
                    (v) => ntp.update(
                      ntp.clearCountersStatusKey,
                      v ? 'enabled' : 'disabled',
                    ),
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
            childAspectRatio: 0.8,
          ),
          itemCount: ntpCards.length,
          itemBuilder: (context, index) {
            final card = ntpCards[index];
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

Widget _infoText(String label, String value) => Text('$label : $value');

Widget _checkboxRow(String label, bool value, ValueChanged<bool> onChanged) {
  return Row(
    children: [
      Text('$label: '),
      Checkbox(value: value, onChanged: (v) => v != null ? onChanged(v) : null),
    ],
  );
}

Widget _textFieldRow(
  String label,
  String value,
  ValueChanged<String> onSubmitted,
) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      SizedBox(
        width: 140,
        child: TextField(
          controller: TextEditingController(text: value),
          onSubmitted: onSubmitted,
          decoration: InputDecoration(labelText: label),
        ),
      ),
    ],
  );
}

Widget _dropdownRow({
  required String label,
  required String? value,
  required List<String> options,
  required ValueChanged<String> onChanged,
}) {
  return SizedBox(
    width: 140,
    child: DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      value: options.contains(value) ? value : null,
      items:
          options
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
      onChanged: (v) => v != null ? onChanged(v) : null,
    ),
  );
}

Widget _vlanRow(NtpServerApi ntp) {
  return Row(
    children: [
      _textFieldRow(
        'VLAN Address',
        ntp.vlanAddress,
        (v) => ntp.update(ntp.vlanAddressKey, v),
      ),
      const SizedBox(width: 8),
      _checkboxRow(
        'VLAN Enable',
        ntp.vlanStatus == 'enabled',
        (v) => ntp.update(ntp.vlanStatusKey, v ? 'enabled' : 'disabled'),
      ),
    ],
  );
}

Widget _ipModeRow(NtpServerApi ntp) {
  return Row(
    children: [
      SizedBox(
        width: 325,
        child: TextField(
          controller: TextEditingController(text: ntp.ipAddress),
          onSubmitted: (v) => ntp.update(ntp.ipAddressKey, v),
          decoration: const InputDecoration(labelText: 'IP Address'),
        ),
      ),
      const SizedBox(width: 8),
      _dropdownRow(
        label: 'IP Mode',
        value: ntp.ipMode,
        options: ['IPv4', 'IPv6'],
        onChanged: (v) async {
          await ntp.update(ntp.ipModeKey, v);
          await ntp.get(ntp.ipAddressKey);
        },
      ),
    ],
  );
}

Widget _modeCheckboxRow(NtpServerApi ntp) {
  return Row(
    children: [
      _checkboxRow(
        'Unicast Mode',
        ntp.unicastMode == 'enabled',
        (v) => ntp.update(ntp.unicastModeKey, v ? 'enabled' : 'disabled'),
      ),
      const SizedBox(width: 12),
      _checkboxRow(
        'Multicast Mode',
        ntp.multicastMode == 'enabled',
        (v) => ntp.update(ntp.multicastModeKey, v ? 'enabled' : 'disabled'),
      ),
      const SizedBox(width: 12),
      _checkboxRow(
        'Broadcast Mode',
        ntp.broadcastMode == 'enabled',
        (v) => ntp.update(ntp.broadcastModeKey, v ? 'enabled' : 'disabled'),
      ),
    ],
  );
}

Widget _stratumConfig(NtpServerApi ntp) {
  const referenceIdOptions = <String>[
    'NTP',
    'NULL',
    'LOCL',
    'CESM',
    'RBDM',
    'PPS',
    'IRIG',
    'ACTS',
    'USNO',
    'PTB',
    'TDF',
    'DCF',
    'MSF',
    'WWV',
    'WWVB',
    'WWVH',
    'CHU',
    'LORC',
    'OMEG',
    'GPS',
  ];
  return Row(
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _textFieldRow(
            'Stratum',
            ntp.stratumValue,
            (v) => ntp.update(ntp.stratumValueKey, v),
          ),
          _textFieldRow(
            'Poll Interval',
            ntp.pollIntervalValue,
            (v) => ntp.update(ntp.pollIntervalValueKey, v),
          ),
          _textFieldRow(
            'Precision',
            ntp.precisionValue,
            (v) => ntp.update(ntp.precisionValueKey, v),
          ),
          const SizedBox(height: 12),

          _dropdownRow(
            label: 'Reference ID',
            value: ntp.referenceId,
            options: referenceIdOptions,
            onChanged: (v) async {
              ntp.update(ntp.referenceIdKey, v);
            },
          ),
        ],
      ),
    ],
  );
}

Widget _leapAndUtcConfig(NtpServerApi ntp) {
  return Row(
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _checkboxRow(
            'Leap 59 In Progress',
            ntp.leap59Status == 'enabled',
            (v) => ntp.update(ntp.leap59StatusKey, v ? 'enabled' : 'disabled'),
          ),
          _checkboxRow(
            'Leap 61 In Progress',
            ntp.leap61Status == 'enabled',
            (v) => ntp.update(ntp.leap61StatusKey, v ? 'enabled' : 'disabled'),
          ),
          _checkboxRow(
            'UTC Smearing Enable',
            ntp.smearingStatus == 'enabled',
            (v) =>
                ntp.update(ntp.smearingStatusKey, v ? 'enabled' : 'disabled'),
          ),
          _checkboxRow(
            'UTC Offset Enable',
            ntp.utcOffsetStatus == 'enabled',
            (v) =>
                ntp.update(ntp.utcOffsetStatusKey, v ? 'enabled' : 'disabled'),
          ),
          _textFieldRow(
            'UTC Offset',
            ntp.utcOffsetValue,
            (v) => ntp.update(ntp.utcOffsetValueKey, v),
          ),
        ],
      ),
    ],
  );
}

Widget _statsConfig(NtpServerApi ntp) {
  return Row(
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _textFieldRow(
            'Requests',
            ntp.requestsValue,
            (v) => ntp.get(ntp.requestsValueKey),
          ),
          _textFieldRow(
            'Requests Dropped',
            ntp.requestsDroppedValue,
            (v) => ntp.get(ntp.requestsDroppedValueKey),
          ),
        ],
      ),
      const SizedBox(width: 12),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _textFieldRow(
            'Responses',
            ntp.responsesValue,
            (v) => ntp.get(ntp.responsesValueKey),
          ),
          _textFieldRow(
            'Broadcasts',
            ntp.broadcastsValue,
            (v) => ntp.get(ntp.broadcastsValueKey),
          ),
        ],
      ),
    ],
  );
}
