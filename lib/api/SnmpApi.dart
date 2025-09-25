import 'dart:convert';
import 'dart:async';
import 'BaseApi.dart';

class SnmpApi extends BaseApi {
  List<V1v2cUser> _v1v2cUsers = [];
  List<V1v2cUser> get v1v2cUsers => _v1v2cUsers;

  List<V3User> _v3Users = [];
  List<V3User> get v3Users => _v3Users;

  String _response = "response";
  String get response => _response;

  SysDetails _sysDetails = SysDetails(
    Action: "Action",
    Status: "Status",
    SysObjId: "SysObjId",
    SysDescription: "SysDescription",
    SysLocation: "SysLocation",
    SysContact: "SysContact",
  );
  SysDetails get sysDetails => _sysDetails;

  @override
  String get baseUrl => '$serverHost/api/v1/snmp';

  SnmpApi({required super.serverHost});

  Future<void> readSnmpInfo() async {
    final response = await getRequest("info");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      _sysDetails = SysDetails.fromJson(decoded['info']);
      notifyListeners();
    } else {
      throw Exception('Failed to load info');
    }
  }

  Future<void> editSnmpInfo(SysDetails details) async {
    final response = await patchRequest("info", details.toJson());
    print(response.body);
    readSnmpInfo();
    notifyListeners();
  }

  Future<void> readV1v2cUsers() async {
    final response = await getRequest("v1v2c_user");
    final decoded = jsonDecode(response.body);
    print(decoded);
    _v1v2cUsers = V1v2cUser.fromJsonList(decoded['v1v2c_users']);
    notifyListeners();
  }

  Future<void> writeV1v2cUser(V1v2cUser user) async {
    final response = await postRequest("v1v2c_user", user.toJson());
    final decoded = json.decode(response.body);
    //_v1v2cUsers.add(V1v2cUser.fromJson(decoded['v1v2c_user']));
    print(decoded);

    readV1v2cUsers();
    notifyListeners();
  }

  Future<void> deleteV1v2cUser(V1v2cUser user) async {
    print(user.toJson());

    final response = await deleteRequest(
      "v1v2c_user/${user.id}",
      user.toJson(),
    );
    final decoded = json.decode(response.body);
    print(decoded);
    //_v1v2cUsers.remove(user);
    readV1v2cUsers();

    notifyListeners();
  }

  Future<void> editV1v2cUser(V1v2cUser user) async {
    print(user.toJson());
    final response = await patchRequest("v1v2c_user/${user.id}", user.toJson());
    final decoded = json.decode(response.body);
    print(decoded);
    readV1v2cUsers();

    notifyListeners();
  }

  // v3 users

  Future<void> readV3Users() async {
    final response = await getRequest("v3_user");
    final decoded = jsonDecode(response.body);
    _v3Users = V3User.fromJsonList(decoded['v3_users']);
    notifyListeners();
  }

  Future<void> writeV3User(V3User user) async {
    print(user.toJson());
    final response = await postRequest("v3_user", user.toJson());
    final decoded = json.decode(response.body);
    print(decoded['v3_user']);
    try {
      _v3Users.add(V3User.fromJson(decoded['v3_user']));
    } catch (e) {}
    notifyListeners();
  }

  Future<void> deleteV3User(V3User user) async {
    print(user.toJson());

    final response = await deleteRequest("v3_user/${user.id}", user.toJson());
    final decoded = json.decode(response.body);
    print(decoded);
    _v3Users.remove(user);

    notifyListeners();
  }

  Future<void> editV3User(V3User user) async {
    print(user.toJson());
    final response = await patchRequest("v3_user/${user.id}", user.toJson());
    final decoded = json.decode(response.body);
    print(decoded);
    notifyListeners();
  }

  Future<void> resetSnmpConfig() async {
    final response = await getRequest("reset_config");
    print(response.body);
    _response = response.body;
    readSnmpInfo();
    readV1v2cUsers();
    readV3Users();
    notifyListeners();
  }
}

class V1v2cUser {
  int id;
  String version;
  String groupName;
  String community;
  String source;
  String secName;
  //String ipVersion;
  //String ip4Address;
  //String ip6Address;

  V1v2cUser({
    required this.id,
    required this.version,
    required this.groupName,
    required this.community,
    required this.source,
    required this.secName,
    //required this.ipVersion,
    //required this.ip4Address,
    //required this.ip6Address,
  });

  factory V1v2cUser.fromJson(Map<String, dynamic> json) {
    return V1v2cUser(
      id: json['ID'],
      version: json['version'] ?? '',
      groupName: json['group_name'] ?? '',
      community: json['community'] ?? '',
      //ipVersion: json['ip_version'] ?? '',
      source: json['source'] ?? '',
      secName: json['sec_name'] ?? '',
      //ip6Address: json['ip6_address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'version': version,
      'group_name': groupName,
      'community': community,
      'source': source,
      'sec_name': secName,
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
  int id;
  String version;
  String userName;
  String authType;
  String authPassphase;
  String privType;
  String privPassphase;
  String groupName;

  V3User({
    required this.id,
    required this.version,
    required this.userName,
    required this.authType,
    required this.authPassphase,
    required this.privType,
    required this.privPassphase,
    required this.groupName,
  });

  factory V3User.fromJson(Map<String, dynamic> json) {
    return V3User(
      id: json['ID'],
      version: json['version'] ?? '',
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
      'ID': id,
      'version': version,
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
