import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ApiService.dart'; // Import your provider
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class NtpServerWidget extends StatefulWidget {
  @override
  _NtpServerWidgetState createState() => _NtpServerWidgetState();
}

class _NtpServerWidgetState extends State<NtpServerWidget> {
  //final TextEditingController macController = TextEditingController();
  //final TextEditingController _vlanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Schedule fetches after the first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<NtpServerProvider>(context, listen: false);
      provider.getVersion();
      provider.getInstance();
      provider.getMacAddress();

      provider.getVlanAddress();

      provider.getVlanStatus();

      provider.getIpAddress();
    });
  }

  @override
  void dispose() {
    // macController.dispose();
    // _vlanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = (constraints.maxWidth / constraints.maxWidth * 4)
            .floor()
            .clamp(1, 4);
        return GridView.builder(
          padding: EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.5,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final card = cards[index];
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

class CardInfo {
  final String title;
  final Widget content;

  CardInfo({required this.title, required this.content});
}

List<CardInfo> cards = [
  CardInfo(
    title: 'Server Info',
    content: Consumer<NtpServerProvider>(
      builder:
          (context, ntp, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Version: ${ntp.version}'),
              Text('Instance: ${ntp.instance}'),
            ],
          ),
    ),
  ),
  CardInfo(
    title: 'Network',
    content: Consumer<NtpServerProvider>(
      builder:
          (context, ntp, _) => Column(
            children: [
              TextField(
                controller: TextEditingController(text: ntp.macAddress),
                onSubmitted: (value) {
                  print(ntp.macAddress);
                  ntp.updateMacAddress(value);
                },
                decoration: InputDecoration(labelText: 'Mac Address'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: ntp.vlanAddress),
                      onSubmitted: (value) {
                        ntp.updateVlanAddress(value);
                      },
                      decoration: InputDecoration(labelText: 'Vlan'),
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: Text(
                        "Vlan Enable",
                        style: TextStyle(fontSize: 12.0),
                      ),
                      value: ntp.vlanStatus == 'enabled',
                      onChanged: (bool? value) {
                        if (value != null) {
                          ntp.updateVlanStatus(value ? 'enabled' : 'disabled');
                        }
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: ntp.ipAddress),
                      onSubmitted: (value) {
                        ntp.updateIpAddress(value);
                      },
                      decoration: InputDecoration(labelText: 'IP'),
                    ),
                  ),
                  // Expanded(
                  //   child: DropdownButtonFormField<String>(
                  //     decoration: const InputDecoration(
                  //       labelText: "Vlan Status",
                  //       labelStyle: TextStyle(fontSize: 12.0),
                  //       border: OutlineInputBorder(),
                  //     ),
                  //     value:
                  //         (['IPv4', 'Ipv6'].contains(ntp.vlanStatus))
                  //             ? ntp.vlanStatus
                  //             : null,
                  //     items: const [
                  //       DropdownMenuItem(
                  //         value: 'enabled',
                  //         child: Text('Enabled'),
                  //       ),
                  //       DropdownMenuItem(
                  //         value: 'disabled',
                  //         child: Text('Disabled'),
                  //       ),
                  //       //DropdownMenuItem(value: 'NA', child: Text('NA')),
                  //     ],
                  //     onChanged: (String? newValue) {
                  //       if (newValue != null) {
                  //         ntp.updateVlanStatus(newValue);
                  //       }
                  //     },
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
    ),
  ),
  CardInfo(
    title: 'Actions',
    content: Consumer<NtpServerProvider>(
      builder:
          (context, ntp, _) => Row(
            children: [
              ElevatedButton(
                onPressed: () => ntp.getVersion(),
                child: Text('Read Version'),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => ntp.getMacAddress(),
                child: Text('Read Mac'),
              ),
            ],
          ),
    ),
  ),
  CardInfo(
    title: 'Actions',
    content: Consumer<NtpServerProvider>(
      builder:
          (context, ntp, _) => Row(
            children: [
              ElevatedButton(
                onPressed: () => ntp.getVersion(),
                child: Text('Read Version'),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => ntp.getMacAddress(),
                child: Text('Read Mac'),
              ),
            ],
          ),
    ),
  ),
  CardInfo(
    title: 'Actions',
    content: Consumer<NtpServerProvider>(
      builder:
          (context, ntp, _) => Row(
            children: [
              ElevatedButton(
                onPressed: () => ntp.getVersion(),
                child: Text('Read Version'),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => ntp.getMacAddress(),
                child: Text('Read Mac'),
              ),
            ],
          ),
    ),
  ),
  // Add more cards as needed
];

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<dynamic> get(String endpoint) async {
    final response = await http
        .get(Uri.parse('$baseUrl$endpoint'))
        .timeout(
          const Duration(seconds: 1),
          onTimeout: () {
            print("time out");
            return http.Response('Error', 408);
          },
        );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl$endpoint'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        )
        .timeout(
          const Duration(seconds: 1),
          onTimeout: () {
            print("time out");
            return http.Response('Error', 408);
          },
        );
    ;
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to post data: ${response.statusCode}');
    }
  }
}

class NtpServerProvider extends ChangeNotifier {
  NtpServerProvider({required this.api});
  final ApiService api;

  String _version = '';
  String _instance = '';
  String _macAddress = '';
  String _vlanAddress = '';
  String _vlanStatus = '';
  String _ipAddress = '';

  bool isLoading = false;
  String? error;

  String get version => _version;
  String get instance => _instance;
  String get macAddress => _macAddress;
  String get vlanAddress => _vlanAddress;
  String get vlanStatus => _vlanStatus;
  String get ipAddress => _ipAddress;

  // == version
  Future<void> getVersion() async {
    _setLoading(true);
    try {
      final data = await api.get('/ntp-server/version');
      _version = data['version'] ?? '';
      error = null;
    } catch (e) {
      error = e.toString();
    }
    _setLoading(false);
  }

  // === instance
  Future<void> getInstance() async {
    _setLoading(true);
    try {
      final data = await api.get('/ntp-server/instance');
      _instance = data['instance'] ?? '';
      error = null;
    } catch (e) {
      error = e.toString();
    }
    _setLoading(false);
  }

  // === mac address
  Future<void> getMacAddress() async {
    _setLoading(true);
    try {
      final data = await api.get('/ntp-server/mac-address');
      _macAddress = data['mac-address'] ?? '';
      error = null;
    } catch (e) {
      error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> postMacAddress(Map<String, dynamic> newMac) async {
    try {
      await api.post('/ntp-server/mac-address', newMac);
      _macAddress = newMac['mac-address'] ?? '';
      error = null;
    } catch (e) {
      error = e.toString();
    }
  }

  void updateMacAddress(String macAddress) async {
    await postMacAddress({'mac-address': macAddress});
    await getMacAddress();
  }
  // ===

  // vlan address
  Future<void> getVlanAddress() async {
    _setLoading(true);
    try {
      final data = await api.get('/ntp-server/vlan/address');
      _vlanAddress = data['vlan-address'] ?? 'API ERROR?';
      error = null;
    } catch (e) {
      error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> postVlanAddress(Map<String, dynamic> newVlanAddress) async {
    try {
      await api.post('/ntp-server/vlan/address', newVlanAddress);
      _vlanAddress = newVlanAddress['vlan-address'] ?? '';
      error = null;
    } catch (e) {
      error = e.toString();
    }
  }

  void updateVlanAddress(String vlanAddr) async {
    await postVlanAddress({'vlan-address': vlanAddr});
    await getVlanAddress();
  }
  // ===

  // === vlan status
  Future<void> postVlanStatus(Map<String, dynamic> newVlanStatus) async {
    try {
      await api.post('/ntp-server/vlan/status', newVlanStatus);
      _vlanStatus = newVlanStatus['vlan-status'] ?? '';
      error = null;
    } catch (e) {
      error = e.toString();
    }
  }

  Future<void> getVlanStatus() async {
    _setLoading(true);
    try {
      final data = await api.get('/ntp-server/vlan/status');
      _vlanStatus = data['vlan-status'] ?? 'API ERROR?';
      error = null;
    } catch (e) {
      error = e.toString();
    }
    _setLoading(false);
  }

  void updateVlanStatus(String status) async {
    await postVlanStatus({'vlan-status': status});
    await getVlanStatus();
  }
  // ===

  // ip address
  Future<void> getIpAddress() async {
    _setLoading(true);
    try {
      final data = await api.get('/ntp-server/ip/address');
      _ipAddress = data['ip-address'] ?? 'API ERROR?';
      error = null;
    } catch (e) {
      error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> postIpAddress(Map<String, dynamic> newVlanAddress) async {
    try {
      await api.post('/ntp-server/ip/address', newVlanAddress);
      _ipAddress = newVlanAddress['ip-address'] ?? '';
      error = null;
    } catch (e) {
      error = e.toString();
    }
  }

  void updateIpAddress(String vlanAddr) async {
    await postIpAddress({'ip-address': vlanAddr});
    await getIpAddress();
  }

  // ===
  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
