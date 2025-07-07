import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web/web.dart';
import 'dart:async';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class LoginApi extends ChangeNotifier {
  // app users
  User? currentUser;
  List<User> _users = [];
  List<User> get users => _users;
  List<User> _filteredUsers = [];
  List<User> get filteredUsers => _filteredUsers;

  // snmp users
  List<SnmpV12cUser> _snmpV1V2cUsers = [];
  List<SnmpV12cUser> get snmpV1V2cUsers => _snmpV1V2cUsers;

  // auth
  bool _loggedIn = false;
  bool get isLoggedIn => _loggedIn;

  String _token = '';
  String get token => _token;

  // api
  final String baseUrl;

  // snmp
  bool _snmpStatus = false;
  bool get snmpStatus => _snmpStatus;

  // error
  String _messageError = '';
  String get messageError => _messageError;

  Timer? _sessionTimer;

  LoginApi({required this.baseUrl}) {
    getToken();
    if (_token.isNotEmpty && !isTokenExpired(_token)) {
      _loggedIn = true;
      getCurrentUserFromToken();
    }

    //getSnmpStatus();
    _startSessionTimer();
  }

  void verifyJwt(String token, String secretOrPublicKey) {
    try {
      // For HMAC (HS256, shared secret)
      final jwt = JWT.verify(token, SecretKey(secretOrPublicKey));
      print('Payload: ${jwt.payload}');
    } on JWTExpiredException {
      print('JWT expired');
    } on JWTException catch (ex) {
      print('Signature invalid: ${ex.message}');
    }
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _checkSessionValidity();
    });
  }

  void getCurrentUserFromToken() {
    if (_token.isEmpty) return;

    try {
      final parts = _token.split('.');
      if (parts.length != 3) return;

      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );

      currentUser = User(
        id: payload['sub'] ?? payload['userId'] ?? payload['id'] ?? '',
        name: payload['name'] ?? payload['username'] ?? '',
        email: payload['email'] ?? '',
        role: payload['role'] ?? '',
        password: '',
      );

      notifyListeners();
    } catch (e) {
      print('Could not decode user info from token: $e');
      // Fallback: try API call if token decoding fails
    }
  }

  Future<void> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'Username': username, 'Password': password}),
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);

      _loggedIn = true;
      _token = body['token'];
      setToken(_token);
      getCurrentUserFromToken();
      notifyListeners();
    } else if (response.statusCode == 401) {
      throw Exception('Invalid username or password');
    } else {
      throw Exception('Login failed');
    }
  }

  void logout() {
    _loggedIn = false;
    _token = '';
    _users.clear();
    _filteredUsers.clear();
    currentUser = null;
    deleteToken();
    notifyListeners();
  }

  void _checkSessionValidity() {
    if (!_loggedIn) return;
    getToken();
    if (_token.isEmpty || isTokenExpired(_token)) {
      _loggedIn = false;
      _token = '';
      notifyListeners();
    }
  }

  bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final expiry = payload['exp'] as int;
      final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
      return now >= expiry;
    } catch (e) {
      return true;
    }
  }

  void setToken(String token) {
    document.cookie = 'token=$token; path=/; max-age=3600; samesite=lax';
  }

  void getToken() {
    final cookies = document.cookie.split(';');
    for (var cookie in cookies) {
      cookie = cookie.trim();
      if (cookie.startsWith('token=')) {
        _token = cookie.substring(6);
        return;
      }
    }
    _token = '';
  }

  void deleteToken() {
    document.cookie = 'token=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT';
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  Future<void> setSnmpStatus(bool value) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/v1/snmp/status'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({'status': value ? "start" : "stop"}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);

        print(decoded['status']);
        getSnmpStatus();
        notifyListeners();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again');
      } else if (response.statusCode == 400) {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'Bad Request: ${errorBody['error'] ?? 'Invalid user data'}',
        );
      } else {
        throw Exception('Failed to add user: ${response.statusCode}');
      }
    } catch (e) {
      if (e is TimeoutException) {
        throw Exception('Request timed out. Please try again.');
      } else {
        throw Exception('Error adding user: $e');
      }
    } finally {
      notifyListeners();
    }
  }

  Future<void> getSnmpStatus() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/v1/snmp/status'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded['status'] == "active") {
          _snmpStatus = true;
        }

        if (decoded['status'] == "inactive") {
          _snmpStatus = false;
        }

        notifyListeners();
      } else {
        throw Exception('Failed to load snmp status');
      }
    } catch (e) {
      throw Exception('Error loading snmp status: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> getAllUsers() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/v1/users'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        _users =
            (decoded['users'] as List)
                .map((userJson) => User.fromJson(userJson))
                .toList();
        _filteredUsers = List.from(_users);
        notifyListeners();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Error loading users: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<User> getUser(int id) async {
    final response = await http
        .get(
          Uri.parse('$baseUrl/api/v1/users/$id'), // Note: ID in URL path
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final Map<String, dynamic> userData = json.decode(response.body);
      print(json.decode(response.body));
      return User.fromJson(userData); // Create User object here
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized access');
    } else {
      throw Exception('Failed to fetch user: ${response.statusCode}');
    }
  }

  Future<void> addUser(User user) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/v1/users'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(user.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);

        print(decoded);

        if (decoded.containsKey('user')) {
          final createdUser = User.fromJson(decoded['user']);
          _users.add(createdUser);
        }

        _updateFiltered();
        notifyListeners();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again');
      } else if (response.statusCode == 400) {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'Bad Request: ${errorBody['error'] ?? 'Invalid user data'}',
        );
      } else {
        throw Exception('Failed to add user: ${response.statusCode}');
      }
    } catch (e) {
      if (e is TimeoutException) {
        throw Exception('Request timed out. Please try again.');
      } else {
        throw Exception('Error adding user: $e');
      }
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteUser(User user) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/api/v1/users/${user.id}'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 5));
      //
      if (response.statusCode == 200 || response.statusCode == 201) {
        _users.removeWhere((u) => u.id == user.id);
        _updateFiltered();
        notifyListeners();
      } else if (response.statusCode == 422) {
        _messageError = jsonDecode(response.body)['error'] ?? 'error';

        notifyListeners();
      } else {
        throw Exception('Failed to delete user');
      }
    } catch (e) {
      throw Exception('Error deleting users: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateUser(User user) async {
    final newUserData = {
      'role': user.role,
      'username': user.name,
      'email': user.email,
      'password': user.password,
    };

    try {
      final response = await http
          .patch(
            Uri.parse('$baseUrl/api/v1/users/${user.id}'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(newUserData),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);

        print("decoded: $decoded");

        //if (decoded.containsKey('user')) {
        // final createdUser = User.fromJson(decoded['user']);
        //  _users.add(createdUser);
        //}

        _updateFiltered();
        notifyListeners();
      } else if (response.statusCode == 204) {
        print("no new content???");
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again');
      } else if (response.statusCode == 400) {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'Bad Request: ${errorBody['error'] ?? 'Invalid user data'}',
        );
      } else {
        throw Exception('Failed to add user: ${response.statusCode}');
      }
    } catch (e) {
      if (e is TimeoutException) {
        throw Exception('Request timed out. Please try again.');
      } else {
        throw Exception('Error updating user: $e');
      }
    } finally {
      notifyListeners();
    }
  }

  void searchUsers(String query) {
    if (query.isEmpty) {
      _filteredUsers = List.from(_users);
    } else {
      final lowerQuery = query.toLowerCase();
      _filteredUsers =
          _users.where((user) {
            return user.name.toLowerCase().contains(lowerQuery) ||
                user.email.toLowerCase().contains(lowerQuery);
          }).toList();
    }
    notifyListeners();
  }

  void _updateFiltered() {
    _filteredUsers = List.from(_users);
    notifyListeners();
  }

  Future<void> getAllSnmpV1V2cUsers() async {
    final response = await http
        .get(
          Uri.parse('$baseUrl/api/v1/snmp_v1v2c'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      _snmpV1V2cUsers =
          (decoded['snmp_v1v2c_users'] as List)
              .map((userJson) => SnmpV12cUser.fromJson(userJson))
              .toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> addSnmpV1V2User(SnmpV12cUser snmpV1V2cUser) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/v1/snmp_v1v2c'), // Note: ID in URL path
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(snmpV1V2cUser.toJson()),
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = json.decode(response.body);
      if (decoded.containsKey('snmp_v1_v2c')) {
        _snmpV1V2cUsers.add(SnmpV12cUser.fromJson(decoded['snmp_v1_v2c']));
      }
      notifyListeners();
      //return SnmpV12cUser.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to fetch addSnmpV1V2User: ${response.statusCode}',
      );
    }
  }

  Future<void> deleteSnmpV1V2cUser(SnmpV12cUser snmpV1V2cUser) async {
    final response = await http
        .delete(
          Uri.parse(
            '$baseUrl/api/v1/snmp_v1v2c/${snmpV1V2cUser.id}',
          ), // Note: ID in URL path
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200 || response.statusCode == 201) {
      _snmpV1V2cUsers.removeWhere((u) => u.id == snmpV1V2cUser.id);
      notifyListeners();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized access');
    } else {
      throw Exception(
        'Failed to delete addSnmpV1V2User: ${response.statusCode}',
      );
    }
  }

  Future<void> updateSnmpV1V2cUser(SnmpV12cUser snmpV1V2cUser) async {
    print(snmpV1V2cUser.toJson());
    final response = await http
        .patch(
          Uri.parse('$baseUrl/api/v1/snmp_v1v2c/${snmpV1V2cUser.id}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(snmpV1V2cUser.toJson()),
        )
        .timeout(const Duration(seconds: 10));
    print(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      notifyListeners();
    } else {
      throw Exception(
        'Failed to update snmpv1v2c user: ${response.statusCode}',
      );
    }
  }
}

class User {
  int? id;
  String role;
  String name;
  String email;
  String password;

  User({
    this.id,
    required this.role,
    required this.name,
    required this.email,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      role: json['role'] ?? '',
      name: json['username'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'role': role, 'username': name, 'email': email};
  }
}

class SnmpV12cUser {
  int? id;
  String version;
  String groupName;
  String community;
  String ipVersion;
  String ip4Address;
  String ip6Address;

  SnmpV12cUser({
    this.id,
    required this.version,
    required this.groupName,
    required this.community,
    required this.ipVersion,
    required this.ip4Address,
    required this.ip6Address,
  });

  factory SnmpV12cUser.fromJson(Map<String, dynamic> json) {
    return SnmpV12cUser(
      id: json['id'],
      version: json['version'] ?? '',
      groupName: json['group_name'] ?? '',
      community: json['community'] ?? '',
      ipVersion: json['ip_version'] ?? '',
      ip4Address: json['ip4_address'] ?? '',
      ip6Address: json['ip6_address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': version,
      'group_name': groupName,
      'community': community,
      'ip_version': ipVersion,
      'ip4_address': ip4Address,
      'ip6_address': ip6Address,
    };
  }

  static List<String> getHeader() {
    return [
      'Version',
      'Group Name',
      'Community',
      'IP Version',
      'IPv4 Address',
      'IPv6 Address',
      'Edit',
    ];
  }
}

class SnmpV3User {
  String id;
  String userName;
  String authType;
  String authPassphase;
  String privType;
  String privPassphase;
  String permissions;

  SnmpV3User({
    required this.id,
    required this.userName,
    required this.authType,
    required this.authPassphase,
    required this.privType,
    required this.privPassphase,
    required this.permissions,
  });

  factory SnmpV3User.fromJson(Map<String, dynamic> json) {
    return SnmpV3User(
      id: json['id'].toString(),
      userName: json['user_name'] ?? '',
      authType: json['auth_type'] ?? '',
      authPassphase: json['auth_passphase'] ?? '',
      privType: json['priv_type'] ?? '',
      privPassphase: json['priv_passphase'] ?? '',
      permissions: json['permissions'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'auth_type': authType,
      'auth_passphase': authPassphase,
      'priv_type': privType,
      'priv_passphase': privPassphase,
      'permissions': permissions,
    };
  }
}
