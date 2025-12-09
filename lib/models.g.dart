// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceStatus _$ServiceStatusFromJson(Map<String, dynamic> json) =>
    ServiceStatus(
      action: json['action'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$ServiceStatusToJson(ServiceStatus instance) =>
    <String, dynamic>{'action': instance.action, 'status': instance.status};

AllowedNode _$AllowedNodeFromJson(Map<String, dynamic> json) => AllowedNode(
  id: (json['ID'] as num?)?.toInt(),
  address: json['address'] as String,
);

Map<String, dynamic> _$AllowedNodeToJson(AllowedNode instance) =>
    <String, dynamic>{'ID': instance.id, 'address': instance.address};

NetworkInfo _$NetworkInfoFromJson(Map<String, dynamic> json) => NetworkInfo(
  portStatus: json['port_status'] as String,
  hostname: json['hostname'] as String,
  gateway: json['gateway'] as String,
  interfaceName: json['interface'] as String,
  speed: json['speed'] as String,
  mac: json['mac'] as String,
  ip: json['ip_address'] as String,
  netmask: json['netmask'] as String,
  dhcp: json['dhcp'] as String,
  dns1: json['dns1'] as String,
  dns2: json['dns2'] as String,
  ignoreAutoDns: json['ignore_auto_dns'] as String,
  connectionStatus: json['connection_status'] as String,
);

Map<String, dynamic> _$NetworkInfoToJson(NetworkInfo instance) =>
    <String, dynamic>{
      'portStatus': instance.portStatus,
      'hostname': instance.hostname,
      'gateway': instance.gateway,
      'interfaceName': instance.interfaceName,
      'speed': instance.speed,
      'mac': instance.mac,
      'ip': instance.ip,
      'netmask': instance.netmask,
      'dhcp': instance.dhcp,
      'dns1': instance.dns1,
      'dns2': instance.dns2,
      'ignoreAutoDns': instance.ignoreAutoDns,
      'connectionStatus': instance.connectionStatus,
    };
