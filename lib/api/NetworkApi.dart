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

  @override
  String get baseUrl => '$serverHost/api/v1/network';

  NetworkApi({required super.serverHost});

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

  resetNetworkConfig() {}
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
