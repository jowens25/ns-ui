import 'dart:convert';
import 'dart:async';
import 'BaseApi.dart';

class NetworkApi extends BaseApi {
  Telnet _telnet = Telnet(Action: "Action", Status: "Status");
  Telnet get telnet => _telnet;

  Ssh _ssh = Ssh(Action: "Action", Status: "Status");
  Ssh get ssh => _ssh;

  Http _http = Http(Action: "Action", Status: "Status");
  Http get http => _http;

  Ftp _ftp = Ftp(Action: "Action", Status: "Status");
  Ftp get ftp => _ftp;

  late Timer _pingTimer;

  bool _invalid = true;
  bool get invalid => _invalid;

  Map<String, dynamic> networkInfo = {
    'port_status': '',
    'hostname': '',
    'gateway': '',
    'interface': '',
    'speed': '',
    'mac': '',
    'ip_address': '',
    'netmask': '',
    'dhcp': '',
    'dns1': '',
    'dns2': '',

    'ignore_auto_dns': '',
    'connection_status': '',
  };

  List<AllowedNode> _allowedNodes = [];
  List<AllowedNode> get allowedNodes => _allowedNodes;

  @override
  String get baseUrl => '$serverHost/api/v1/network';

  @override
  void dispose() {
    _pingTimer.cancel();
    super.dispose();
  }

  NetworkApi({required super.serverHost}) {
    _startPinging();
  }

  Future<void> readTelnetInfo() async {
    final response = await getRequest("telnet");
    if (response.statusCode == 200) {
      _telnet = Telnet.fromJson(jsonDecode(response.body)['info']);
      notifyListeners();
    } else {
      throw Exception('Failed to load info');
    }
  }

  Future<void> editTelnetInfo(Telnet telnet) async {
    await patchRequest("telnet", telnet.toJson());
    readTelnetInfo();
    notifyListeners();
  }

  Future<void> readSshInfo() async {
    final response = await getRequest("ssh");
    if (response.statusCode == 200) {
      _ssh = Ssh.fromJson(jsonDecode(response.body)['info']);
      notifyListeners();
    } else {
      throw Exception('Failed to load info');
    }
  }

  Future<void> editSshInfo(Ssh ssh) async {
    await patchRequest("ssh", ssh.toJson());
    readSshInfo();
    notifyListeners();
  }

  Future<void> readHttpInfo() async {
    final response = await getRequest("http");
    if (response.statusCode == 200) {
      _http = Http.fromJson(jsonDecode(response.body)['info']);
      notifyListeners();
    } else {
      throw Exception('Failed to load info');
    }
  }

  Future<void> editHttpInfo(Http http) async {
    await patchRequest("http", http.toJson());
    readHttpInfo();
    notifyListeners();
  }

  Future<void> readFtpInfo() async {
    final response = await getRequest("ftp");
    if (response.statusCode == 200) {
      _ftp = Ftp.fromJson(jsonDecode(response.body)['info']);
      notifyListeners();
    } else {
      throw Exception('Failed to load info');
    }
  }

  Future<void> editFtpInfo(Ftp ftp) async {
    await patchRequest("ftp", ftp.toJson());
    readFtpInfo();
    notifyListeners();
  }

  Future<void> readNetworkInfo() async {
    final response = await getRequest("info");
    if (response.statusCode == 200) {
      networkInfo = jsonDecode(response.body)['info'];
      notifyListeners();
    } else {
      throw Exception('Failed to load info');
    }
  }

  Future<void> writeNetworkInfo(String endpoint) async {
    final response = await postRequest("info/$endpoint", {
      endpoint: networkInfo[endpoint],
    });
    final decoded = json.decode(response.body);
    print(decoded);
    notifyListeners();
  }

  Future<void> resetNetwork() async {
    final response = await postRequest("reset", {});
    notifyListeners();
  }

  Future<void> readNetworkAccess() async {
    final response = await getRequest("access");
    final decoded = jsonDecode(response.body);
    if (decoded['allowed_nodes'] != null) {
      _allowedNodes =
          (decoded['allowed_nodes'] as List)
              .map((userJson) => AllowedNode.fromJson(userJson))
              .toList();
    }

    notifyListeners();
  }

  Future<void> writeNetworkAccess(AllowedNode node) async {
    final response = await postRequest("access", node.toJson());
    final decoded = json.decode(response.body);
    readNetworkAccess();
    notifyListeners();
  }

  Future<void> deleteNetworkAccess(AllowedNode node) async {
    final response = await deleteRequest("access/${node.id}", node.toJson());
    final decoded = json.decode(response.body);
    _allowedNodes.remove(node);
    readNetworkAccess();
    notifyListeners();
  }

  void _startPinging() {
    _pingTimer = Timer.periodic(Duration(seconds: 1), (_) async {
      try {
        final response = await getRequest("health");
        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          print("Health check: $decoded");

          if (_invalid) {
            _invalid = false;
            notifyListeners(); // Only notify if state actually changed
          }
        } else {
          // Non-200 means something went wrong
          if (!_invalid) {
            _invalid = true;
            notifyListeners();
          }
        }
      } catch (e) {
        print("Health check failed: $e");
        if (!_invalid) {
          _invalid = true;
          notifyListeners();
        }
      }
    });
  }
}

class Telnet {
  String Action;
  String Status;

  Telnet({required this.Action, required this.Status});

  factory Telnet.fromJson(Map<String, dynamic> json) {
    return Telnet(Action: json['action'] ?? '', Status: json['status'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'action': Action, 'status': Status};
  }
}

class Ssh {
  String Action;
  String Status;

  Ssh({required this.Action, required this.Status});

  factory Ssh.fromJson(Map<String, dynamic> json) {
    return Ssh(Action: json['action'] ?? '', Status: json['status'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'action': Action, 'status': Status};
  }
}

class Http {
  String Action;
  String Status;

  Http({required this.Action, required this.Status});

  factory Http.fromJson(Map<String, dynamic> json) {
    return Http(Action: json['action'] ?? '', Status: json['status'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'action': Action, 'status': Status};
  }
}

class Ftp {
  String Action;
  String Status;

  Ftp({required this.Action, required this.Status});

  factory Ftp.fromJson(Map<String, dynamic> json) {
    return Ftp(Action: json['action'] ?? '', Status: json['status'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'action': Action, 'status': Status};
  }
}

class AllowedNode {
  int? id;
  String address;

  AllowedNode({this.id, required this.address});

  factory AllowedNode.fromJson(Map<String, dynamic> json) {
    return AllowedNode(id: json['ID'], address: json['address'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'ID': id, 'address': address};
  }

  static List<String> getHeader() {
    return ['Address', 'Remove'];
  }
}
