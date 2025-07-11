import 'dart:convert';

import 'dart:async';

import 'LoginApi.dart';

class SnmpApi extends LoginApi {
  List<V1v2cUser> _v1v2cUsers = [];
  List<V1v2cUser> get v1v2cUsers => _v1v2cUsers;

  List<V3User> _v3Users = [];
  List<V3User> get v3Users => _v3Users;

  SysDetails _sysDetails = SysDetails(
    Action: "Action",
    Status: "Status",
    SysObjId: "SysObjId",
    SysDescription: "SysDescription",
    SysLocation: "SysLocation",
    SysContact: "SysContact",
  );
  SysDetails get sysDetails => _sysDetails;

  SnmpApi({required String baseUrl}) : super(baseUrl: '$baseUrl/api/v1/snmp') {
    //getSysDetails();
    //getAllV1V2cUsers();
  } //

  //v1v2c users
  Future<void> getAllV1V2cUsers() async {
    final response = await getRequest("v1v2c_user");

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('failed get v1v2c users: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    print(decoded);
    _v1v2cUsers = V1v2cUser.fromJsonList(decoded['v1v2c_users']);

    notifyListeners();
  }

  // details
  Future<void> getSysDetails() async {
    final response = await getRequest("details");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      _sysDetails = SysDetails.fromJson(decoded['sys_details']);
      //print(decoded['snmp_sys_details']);
      notifyListeners();
    } else {
      throw Exception('Failed to load details');
    }
  }

  Future<void> updateSysDetails(SysDetails details) async {
    final response = await patchRequest("details", details.toJson());

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update sys details: ${response.statusCode}');
    }

    getSysDetails();
    notifyListeners();
  }

  Future<void> addV1v2cUser(V1v2cUser user) async {
    print(user.toJson());

    final response = await postRequest("v1v2c_user", user.toJson());

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add V1V2c User: ${response.statusCode}');
    }

    final decoded = json.decode(response.body);
    _v1v2cUsers.add(V1v2cUser.fromJson(decoded['v1v2c_user']));

    notifyListeners();
  }

  //Future<void> updateSnmpV1V2cUser(V1v2cUser snmpV1V2cUser) async {
  //  // final response = await http
  //  //     .patch(
  //  //       Uri.parse('$baseUrl/api/v1/v1v2c_user/${snmpV1V2cUser.id}'),
  //  //       headers: {
  //  //         'Content-Type': 'application/json',
  //  //         'Authorization': 'Bearer  ${LoginApi.token}',
  //  //       },
  //  //       body: json.encode(snmpV1V2cUser.toJson()),
  //  //     )
  //  //     .timeout(const Duration(seconds: 5));
  //  // if (response.statusCode == 200 || response.statusCode == 201) {
  //  //   notifyListeners();
  //  // } else {
  //  //   throw Exception(
  //  //     'Failed to update snmpv1v2c user: ${response.statusCode}',
  //  //   );
  //  // }
  //}
  //
  //Future<void> deleteSnmpV1V2cUser(V1v2cUser snmpV1V2cUser) async {
  //  //final response = await http
  //  //    .delete(
  //  //      Uri.parse(
  //  //        '$baseUrl/api/v1/v1v2c_user/${snmpV1V2cUser.id}',
  //  //      ), // Note: ID in URL path
  //  //      headers: {
  //  //        'Content-Type': 'application/json',
  //  //        'Authorization': 'Bearer  ${LoginApi.token}',
  //  //      },
  //  //    )
  //  //    .timeout(const Duration(seconds: 5));
  //  //
  //  //if (response.statusCode == 200 || response.statusCode == 201) {
  //  //  //_snmpV1V2cUsers.removeWhere((u) => u.id == snmpV1V2cUser.id);
  //  //  notifyListeners();
  //  //} else if (response.statusCode == 401) {
  //  //  throw Exception('Unauthorized access');
  //  //} else {
  //  //  throw Exception(
  //  //    'Failed to delete addSnmpV1V2User: ${response.statusCode}',
  //  //  );
  //  //}
  //}
  // =============== END SNMP V1 V2c USERS ==============================================
  // =============== SNMP V3 USERS ==============================================

  //Future<void> getAllV3Users() async {
  //  final response = await http
  //      .get(
  //        Uri.parse('$baseUrl/api/v1/v3_user'),
  //        headers: {
  //          'Content-Type': 'application/json',
  //          'Authorization': 'Bearer  ${LoginApi.token}',
  //        },
  //      )
  //      .timeout(const Duration(seconds: 5));
  //
  //  if (response.statusCode == 200) {
  //    final decoded = jsonDecode(response.body);
  //    _snmpV3Users = SnmpV3User.fromJsonList(decoded['v3_users']);
  //    notifyListeners();
  //  } else {
  //    throw Exception('Failed to load users');
  //  }
  //}
  //
  //Future<void> addV3User(SnmpV3User snmpV3User) async {
  //  final response = await http
  //      .post(
  //        Uri.parse('$baseUrl/api/v1/v3_user'), // Note: ID in URL path
  //        headers: {
  //          'Content-Type': 'application/json',
  //          'Authorization': 'Bearer  ${LoginApi.token}',
  //        },
  //        body: json.encode(snmpV3User.toJson()),
  //      )
  //      .timeout(const Duration(seconds: 5));
  //
  //  if (response.statusCode == 200 || response.statusCode == 201) {
  //    final decoded = json.decode(response.body);
  //    if (decoded.containsKey('v3_user_user')) {
  //      _snmpV3Users.add(SnmpV3User.fromJson(decoded['v3_user_user']));
  //    }
  //    notifyListeners();
  //  } else {
  //    throw Exception('Failed to fetch add v3_user: ${response.statusCode}');
  //  }
  //}
  //
  //Future<void> updateV3User(SnmpV3User snmpV3User) async {
  //  final response = await http
  //      .patch(
  //        Uri.parse('$baseUrl/api/v1/v3_user/${snmpV3User.id}'),
  //        headers: {
  //          'Content-Type': 'application/json',
  //          'Authorization': 'Bearer  ${LoginApi.token}',
  //        },
  //        body: json.encode(snmpV3User.toJson()),
  //      )
  //      .timeout(const Duration(seconds: 5));
  //  print(response.body);
  //  if (response.statusCode == 200 || response.statusCode == 201) {
  //    notifyListeners();
  //  } else {
  //    throw Exception('Failed to update v3_user user: ${response.statusCode}');
  //  }
  //}
  //
  //Future<void> deleteV3User(SnmpV3User snmpV3User) async {
  //  final response = await http
  //      .delete(
  //        Uri.parse(
  //          '$baseUrl/api/v1/v3_user/${snmpV3User.id}',
  //        ), // Note: ID in URL path
  //        headers: {
  //          'Content-Type': 'application/json',
  //          'Authorization': 'Bearer  ${LoginApi.token}',
  //        },
  //      )
  //      .timeout(const Duration(seconds: 5));
  //
  //  if (response.statusCode == 200 || response.statusCode == 201) {
  //    _snmpV3Users.removeWhere((u) => u.id == snmpV3User.id);
  //    notifyListeners();
  //  } else if (response.statusCode == 401) {
  //    throw Exception('Unauthorized access');
  //  } else {
  //    throw Exception('Failed to delete v3_user: ${response.statusCode}');
  //  }
  //}

  // =============== END SNMP V3 USERS ==============================================

  Future<void> resetSnmpConfig() async {
    final response = await getRequest("reset_config");
    //final response = await http
    //    .get(
    //      Uri.parse('$baseUrl/reset_config'),
    //      headers: {
    //        'Content-Type': 'application/json',
    //        'Authorization': 'Bearer  ${LoginApi.token}',
    //      },
    //    )
    //    .timeout(const Duration(seconds: 5));
    //
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('failed to reset snmp config: ${response.statusCode}');
    }
    getAllV1V2cUsers();
    notifyListeners();
  }
}

class V1v2cUser {
  //int? id;
  String version;
  String groupName;
  String community;
  String source;
  //String ipVersion;
  //String ip4Address;
  //String ip6Address;

  V1v2cUser({
    //this.id,
    required this.version,
    required this.groupName,
    required this.community,
    required this.source,
    //required this.ipVersion,
    //required this.ip4Address,
    //required this.ip6Address,
  });

  factory V1v2cUser.fromJson(Map<String, dynamic> json) {
    return V1v2cUser(
      // id: json['id'],
      version: json['version'] ?? '',
      groupName: json['group_name'] ?? '',
      community: json['community'] ?? '',
      //ipVersion: json['ip_version'] ?? '',
      source: json['source'] ?? '',
      //ip6Address: json['ip6_address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'version': version,
      'group_name': groupName,
      'community': community,
      'source': source,
      //'ip_version': ipVersion,
      //'ip4_address': ip4Address,
      //'ip6_address': ip6Address,
    };
  }

  static List<String> getHeader() {
    return [
      'Version',
      'Group Name',
      'Community',
      //'IP Version',
      'Source',
      //'IPv6 Address',
      'Edit',
    ];
  }

  static List<V1v2cUser> fromJsonList(dynamic json) {
    if (json is! List) return [];
    return json.map((userJson) => V1v2cUser.fromJson(userJson)).toList();
  }
}

class V3User {
  int? id;
  String userName;
  String authType;
  String authPassphase;
  String privType;
  String privPassphase;
  String groupName;

  V3User({
    this.id,
    required this.userName,
    required this.authType,
    required this.authPassphase,
    required this.privType,
    required this.privPassphase,
    required this.groupName,
  });

  factory V3User.fromJson(Map<String, dynamic> json) {
    return V3User(
      id: json['id'],
      userName: json['user_name'] ?? '',
      authType: json['auth_type'] ?? '',
      authPassphase: json['auth_passphrase'] ?? '',
      privType: json['priv_type'] ?? '',
      privPassphase: json['priv_passphrase'] ?? '',
      groupName: json['group_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'auth_type': authType,
      'auth_passphrase': authPassphase,
      'priv_type': privType,
      'priv_passphrase': privPassphase,
      'group_name': groupName,
    };
  }

  static List<String> getHeader() {
    return ['User Name', 'Auth Type', 'Priv Type', 'Group Name', 'Edit'];
  }

  static List<V3User> fromJsonList(dynamic json) {
    if (json is! List) return [];
    return json.map((userJson) => V3User.fromJson(userJson)).toList();
  }
}

class SysDetails {
  String Action;
  String Status;
  String SysObjId;
  String SysDescription;
  String SysLocation;
  String SysContact;

  SysDetails({
    required this.Action,
    required this.Status,
    required this.SysObjId,
    required this.SysDescription,
    required this.SysLocation,
    required this.SysContact,
  });

  factory SysDetails.fromJson(Map<String, dynamic> json) {
    return SysDetails(
      Action: json['action'] ?? '',
      Status: json['status'] ?? '',
      SysObjId: json['sys_obj_id'] ?? '',
      SysDescription: json['sys_description'] ?? '',
      SysLocation: json['sys_location'] ?? '',
      SysContact: json['sys_contact'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': Action,
      'status': Status,
      'sys_obj_id': SysObjId,
      'sys_description': SysDescription,
      'sys_location': SysLocation,
      'sys_contact': SysContact,
    };
  }
}
