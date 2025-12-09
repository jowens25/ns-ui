import 'package:json_annotation/json_annotation.dart';
part 'models.g.dart';

//part 'service_status.g.dart';
//part 'allowed_node.g.dart';
//part 'network_info.g.dart';

@JsonSerializable()
class ServiceStatus {
  @JsonKey(name: "action")
  final String action;

  @JsonKey(name: "status")
  final String status;

  ServiceStatus({required this.action, required this.status});

  factory ServiceStatus.fromJson(Map<String, dynamic> json) =>
      _$ServiceStatusFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceStatusToJson(this);

  factory ServiceStatus.empty() => ServiceStatus(action: "", status: "");
}

// Type aliases
typedef Telnet = ServiceStatus;
typedef Ssh = ServiceStatus;
typedef HttpInfo = ServiceStatus;
typedef Ftp = ServiceStatus;

@JsonSerializable()
class AllowedNode {
  @JsonKey(name: "ID")
  final int? id;

  final String address;

  AllowedNode({this.id, required this.address});

  factory AllowedNode.fromJson(Map<String, dynamic> json) =>
      _$AllowedNodeFromJson(json);

  Map<String, dynamic> toJson() => _$AllowedNodeToJson(this);
}

@JsonSerializable()
class NetworkInfo {
  final String portStatus;
  final String hostname;
  final String gateway;
  final String interfaceName;
  final String speed;
  final String mac;
  final String ip;
  final String netmask;
  final String dhcp;
  final String dns1;
  final String dns2;
  final String ignoreAutoDns;
  final String connectionStatus;

  NetworkInfo({
    required this.portStatus,
    required this.hostname,
    required this.gateway,
    required this.interfaceName,
    required this.speed,
    required this.mac,
    required this.ip,
    required this.netmask,
    required this.dhcp,
    required this.dns1,
    required this.dns2,
    required this.ignoreAutoDns,
    required this.connectionStatus,
  });

  factory NetworkInfo.fromJson(Map<String, dynamic> json) =>
      _$NetworkInfoFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkInfoToJson(this);

  factory NetworkInfo.empty() => NetworkInfo(
    portStatus: "",
    hostname: "",
    gateway: "",
    interfaceName: "",
    speed: "",
    mac: "",
    ip: "",
    netmask: "",
    dhcp: "",
    dns1: "",
    dns2: "",
    ignoreAutoDns: "",
    connectionStatus: "",
  );

  NetworkInfo copyWith({
    String? portStatus,
    String? hostname,
    String? gateway,
    String? interfaceName,
    String? speed,
    String? mac,
    String? ip,
    String? netmask,
    String? dhcp,
    String? dns1,
    String? dns2,
    String? ignoreAutoDns,
    String? connectionStatus,
  }) {
    return NetworkInfo(
      portStatus: portStatus ?? this.portStatus,
      hostname: hostname ?? this.hostname,
      gateway: gateway ?? this.gateway,
      interfaceName: interfaceName ?? this.interfaceName,
      speed: speed ?? this.speed,
      mac: mac ?? this.mac,
      ip: ip ?? this.ip,
      netmask: netmask ?? this.netmask,
      dhcp: dhcp ?? this.dhcp,
      dns1: dns1 ?? this.dns1,
      dns2: dns2 ?? this.dns2,
      ignoreAutoDns: ignoreAutoDns ?? this.ignoreAutoDns,
      connectionStatus: connectionStatus ?? this.connectionStatus,
    );
  }
}

class RoleManager {
  static final Map<UserRole, List<Permission>> rolePermissions = {
    UserRole.admin: [
      Permission.manageUsers,
      Permission.manageRoles,
      Permission.viewAllData,
      Permission.editAllData,
      Permission.deleteAllData,
      Permission.viewPatients,
      Permission.editPatients,
    ],
    UserRole.doctor: [
      Permission.viewPatients,
      Permission.editPatients,
      //Permission.createAppointments,
      //Permission.viewMedicalRecords,
      //Permission.editMedicalRecords,
    ],
    UserRole.nurse: [
      Permission.viewPatients,
      //Permission.createAppointments,
      //Permission.viewMedicalRecords,
    ],
  };
  static bool hasPermission(UserRole role, Permission permission) {
    return rolePermissions[role]?.contains(permission) ?? false;
  }

  static List<Permission> getPermissionsForRole(UserRole role) {
    return rolePermissions[role] ?? [];
  }
}

enum Permission {
  manageUsers,
  manageRoles,
  viewAllData,
  editAllData,
  deleteAllData,
  viewPatients,
  editPatients,
}

enum UserRole { admin, doctor, nurse }
