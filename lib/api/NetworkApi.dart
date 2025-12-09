import 'package:flutter/material.dart';
import 'BaseApi2.dart';
import 'package:nct/models.dart';

class NetworkApi extends ChangeNotifier {
  final BaseApi2 api;

  // Service states
  ServiceStatus telnet = ServiceStatus.empty();
  ServiceStatus ssh = ServiceStatus.empty();
  ServiceStatus httpInfo = ServiceStatus.empty();
  ServiceStatus ftp = ServiceStatus.empty();

  // Network info
  NetworkInfo networkInfo = NetworkInfo.empty();

  // Allowed nodes
  List<AllowedNode> allowedNodes = [];

  // Last message
  String responseMessage = "";

  NetworkApi({required this.api});

  // -------------------------------
  // Telnet
  // -------------------------------

  Future<ServiceStatus?> readTelnetInfo() async {
    final result = await api.getRequest("telnet");

    if (result.isSuccess && result.data?['info'] != null) {
      telnet = ServiceStatus.fromJson(result.data!['info']);
      notifyListeners();
      return telnet;
    }

    responseMessage = result.error ?? "Failed to load telnet info";
    notifyListeners();
    return null;
  }

  Future<bool> editTelnetInfo(ServiceStatus newStatus) async {
    final result = await api.patchRequest("telnet", newStatus.toJson());

    responseMessage = result.isSuccess
        ? "Telnet updated"
        : result.error ?? "Error updating telnet";

    await readTelnetInfo();
    return result.isSuccess;
  }

  // -------------------------------
  // SSH
  // -------------------------------

  Future<ServiceStatus?> readSshInfo() async {
    final result = await api.getRequest("ssh");

    if (result.isSuccess && result.data?['info'] != null) {
      ssh = ServiceStatus.fromJson(result.data!['info']);
      notifyListeners();
      return ssh;
    }

    responseMessage = result.error ?? "Failed to load SSH info";
    notifyListeners();
    return null;
  }

  Future<bool> editSshInfo(ServiceStatus newStatus) async {
    final result = await api.patchRequest("ssh", newStatus.toJson());

    responseMessage = result.isSuccess
        ? "SSH updated"
        : result.error ?? "Error updating ssh";

    await readSshInfo();
    return result.isSuccess;
  }

  // -------------------------------
  // HTTP
  // -------------------------------

  Future<ServiceStatus?> readHttpInfo() async {
    final result = await api.getRequest("http");

    if (result.isSuccess && result.data?['info'] != null) {
      httpInfo = ServiceStatus.fromJson(result.data!['info']);
      notifyListeners();
      return httpInfo;
    }

    responseMessage = result.error ?? "Failed to load HTTP info";
    notifyListeners();
    return null;
  }

  Future<bool> editHttpInfo(ServiceStatus newStatus) async {
    final result = await api.patchRequest("http", newStatus.toJson());

    responseMessage = result.isSuccess
        ? "HTTP updated"
        : result.error ?? "Error updating HTTP";

    await readHttpInfo();
    return result.isSuccess;
  }

  // -------------------------------
  // FTP
  // -------------------------------

  Future<ServiceStatus?> readFtpInfo() async {
    final result = await api.getRequest("ftp");

    if (result.isSuccess && result.data?['info'] != null) {
      ftp = ServiceStatus.fromJson(result.data!['info']);
      notifyListeners();
      return ftp;
    }

    responseMessage = result.error ?? "Failed to load FTP info";
    notifyListeners();
    return null;
  }

  Future<bool> editFtpInfo(ServiceStatus newStatus) async {
    final result = await api.patchRequest("ftp", newStatus.toJson());

    responseMessage = result.isSuccess
        ? "FTP updated"
        : result.error ?? "Error updating FTP";

    await readFtpInfo();
    return result.isSuccess;
  }

  // -------------------------------
  // NETWORK INFO
  // -------------------------------

  Future<NetworkInfo?> readNetworkInfo() async {
    final result = await api.getRequest("info");

    if (result.isSuccess && result.data?['info'] != null) {
      networkInfo = NetworkInfo.fromJson(result.data!['info']);
      notifyListeners();
      return networkInfo;
    }

    responseMessage = result.error ?? "Error loading network info";
    notifyListeners();
    return null;
  }

  Future<bool> writeNetworkField(String fieldName, String value) async {
    // Create a new NetworkInfo object with the updated field
    NetworkInfo updatedInfo = networkInfo.copyWith(
      hostname: fieldName == 'hostname' ? value : null,
      gateway: fieldName == 'gateway' ? value : null,
      ip: fieldName == 'ip_address' ? value : null,
      netmask: fieldName == 'netmask' ? value : null,
      dhcp: fieldName == 'dhcp' ? value : null,
      dns1: fieldName == 'dns1' ? value : null,
      dns2: fieldName == 'dns2' ? value : null,
      ignoreAutoDns: fieldName == 'ignore_auto_dns' ? value : null,
    );

    final jsonBody = {fieldName: value};

    final result = await api.postRequest("info/$fieldName", jsonBody);

    if (result.isSuccess) {
      networkInfo = updatedInfo; // assign updated object
    }

    responseMessage = result.isSuccess
        ? "Network updated"
        : result.error ?? "Error updating network";

    notifyListeners();
    return result.isSuccess;
  }

  // -------------------------------
  // ALLOWED NODES
  // -------------------------------

  Future<List<AllowedNode>?> readNetworkAccess() async {
    final result = await api.getRequest("access");

    if (result.isSuccess) {
      final list = result.data?['allowed_nodes'] as List? ?? [];
      allowedNodes = list.map((e) => AllowedNode.fromJson(e)).toList();
      notifyListeners();
      return allowedNodes;
    }

    responseMessage = result.error ?? "Failed to load access list";
    notifyListeners();
    return null;
  }

  Future<bool> writeNetworkAccess(AllowedNode node) async {
    final result = await api.postRequest("access", node.toJson());

    responseMessage = result.isSuccess
        ? "Node added"
        : result.error ?? "Error adding node";

    await readNetworkAccess();
    return result.isSuccess;
  }

  Future<bool> deleteNetworkAccess(AllowedNode node) async {
    final result = await api.deleteRequest("access/${node.id}");

    responseMessage = result.isSuccess
        ? "Node deleted"
        : result.error ?? "Error deleting node";

    await readNetworkAccess();
    return result.isSuccess;
  }
}
