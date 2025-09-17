import 'dart:convert';
import 'dart:async';

import 'BaseApi.dart';

class DeviceApi extends BaseApi {
  @override
  String get baseUrl => '$serverHost/api/v1/device';

  DeviceApi({required super.serverHost});

  Map<String, dynamic> device = {
    'baudrate': '',
    'input_priority': '',
    'fault_threshold_a': '',
    'fault_threshold_b': '',
    'input_low_threshold_0': '',
    'input_low_threshold_1': '',

    //'instance': '',
    //'mac': '',
    //'vlan_address': '',
    //'vlan_status': '',
    //'ip_mode': 'IPv4',
    //'ip_address': '',
    //'unicast_mode': '',
    //'multicast_mode': '',
    //'broadcast_mode': '',
    //'status': '',
    //'stratum': '',
    //'poll_interval': '',
    //'precision': '',
    //'reference_id': 'NULL',
    //'leap59': '',
    //'leap59_inprogress': '',
    //'leap61': '',
    //'leap61_inprogress': '',
    //'utc_smearing': '',
    //'utc_offset_status': '',
    //'utc_offset_value': '',
    //'requests': '',
    //'responses': '',
    //'requests_dropped': '',
    //'broadcasts': '',
    //'clear_counters': '',
  };

  Future<void> readProperty(String endpoint) async {
    final response = await getRequest(endpoint);
    final decoded = jsonDecode(response.body);
    device[endpoint] = decoded[endpoint];
    notifyListeners();
  }

  Future<void> readAll() async {
    for (var endpoint in device.keys) {
      final response = await getRequest(endpoint);
      final decoded = jsonDecode(response.body);
      device[endpoint] = decoded[endpoint];
    }
    notifyListeners();

    print(device);
  }

  Future<void> writeProperty(String endpoint) async {
    final response = await postRequest(endpoint, {endpoint: device[endpoint]});
    final decoded = json.decode(response.body);
    print(decoded);
    notifyListeners();
  }
}
