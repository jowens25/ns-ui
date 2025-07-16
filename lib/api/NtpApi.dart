import 'dart:convert';
import 'dart:async';

import 'BaseApi.dart';

class NtpApi extends BaseApi {
  @override
  String get baseUrl => 'http://$serverHost:$serverPort/api/v1/ntp';

  NtpApi({required super.serverHost, required super.serverPort});

  Map<String, dynamic> ntp = {
    'version': '',
    'instance': '',
    'mac': '',
    'vlan_address': '',
    'vlan_status': '',
    'ip_mode': 'IPv4',
    'ip_address': '',
    'unicast_mode': '',
    'multicast_mode': '',
    'broadcast_mode': '',
    'status': '',
    'stratum': '',
    'poll_interval': '',
    'precision': '',
    'reference_id': 'LOCL',
    'leap59': '',
    'leap59_inprogress': '',
    'leap61': '',
    'leap61_inprogress': '',
    'utc_smearing': '',
    'utc_offset_status': '',
    'utc_offset_value': '',
    'requests': '',
    'responses': '',
    'requests_dropped': '',
    'broadcasts': '',
    'clear_counters': '',
  };

  Future<void> readProperty(String endpoint) async {
    final response = await getRequest(endpoint);
    final decoded = jsonDecode(response.body);
    ntp[endpoint] = decoded[endpoint];
    notifyListeners();
  }

  Future<void> readAll() async {
    for (var endpoint in ntp.keys) {
      final response = await getRequest(endpoint);
      final decoded = jsonDecode(response.body);
      ntp[endpoint] = decoded[endpoint];
    }
    notifyListeners();

    print(ntp);
  }

  Future<void> writeProperty(String endpoint) async {
    final response = await postRequest(endpoint, {endpoint: ntp[endpoint]});
    final decoded = json.decode(response.body);
    print(decoded);
    notifyListeners();
  }
}
