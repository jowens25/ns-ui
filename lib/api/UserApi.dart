import 'dart:convert';
import 'dart:async';

import 'BaseApi.dart';

import 'dart:convert';

import 'package:nct/api/BaseApi.dart';
import 'package:provider/provider.dart';
import 'package:web/web.dart';
import 'dart:async';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class UserApi extends BaseApi {
  @override
  String get baseUrl => '$serverHost/api/v1';

  String? _authResponse;
  String? get authResponse => _authResponse;

  User? currentUser;
  List<User> _users = [];
  List<User> get users => _users;
  List<User> _filteredUsers = [];
  List<User> get filteredUsers => _filteredUsers;

  String _response = "response";
  String get response => _response;

  bool _loggedIn = false;
  bool get isLoggedIn => _loggedIn;

  Timer? _sessionTimer;

  UserApi({required super.serverHost}) {
    isTokenValid();
    _startSessionTimer();
  }

  Future<void> login(User user) async {
    final response = await postRequest("login", user.toJson());
    final decoded = json.decode(response.body);
    //_loggedIn = true;
    print('decoded: $decoded');

    if (decoded['error'] != null) {
      _authResponse = decoded['error'];
    }

    setToken(decoded['token']);
    isTokenValid();
    notifyListeners();
  }

  void logout() {
    deleteToken();
    _authResponse = null;
    _loggedIn = false;
    notifyListeners();
  }

  static String getToken() {
    final cookies = document.cookie.split(';');
    for (var cookie in cookies) {
      cookie = cookie.trim();
      if (cookie.startsWith('token=')) {
        return cookie.substring('token='.length);
      }
    }
    return '';
  }

  void setToken(String tok) {
    document.cookie = 'token=$tok; path=/; max-age=3600; samesite=lax';
  }

  void deleteToken() {
    document.cookie = 'token=; path=/; max-age=0';
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      isTokenValid();
      notifyListeners();
    });
  }

  void isTokenValid() {
    try {
      JWT.verify(getToken(), SecretKey("your-secret-key"));
      _loggedIn = true;
      //final userApi = Provider.of<UserApi>(context, listen: false);
      //userApi.getCurrentUserFromToken(getToken());
    } on JWTExpiredException {
      print('JWT expired');
      _loggedIn = false;
    } on JWTException catch (ex) {
      print('Signature invalid: ${ex.message}');
      _loggedIn = false;
    }
    notifyListeners();
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

  void getCurrentUserFromToken(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return;
    final payload = json.decode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    );
    print(payload);

    currentUser = User(
      id: payload['sub'] ?? payload['userId'] ?? payload['id'],
      name: payload['name'] ?? payload['username'] ?? '',
      email: payload['email'] ?? '',
      role: payload['role'] ?? '',
      password: '',
    );

    notifyListeners();
  }

  void clearUser() {
    currentUser = null;
  }

  // gets , sets, reads wriites all thsat

  Future<void> readUsers() async {
    final response = await getRequest("users");
    final decoded = jsonDecode(response.body);
    print(decoded);
    _users =
        (decoded['system_users'] as List)
            .map((userJson) => User.fromJson(userJson))
            .toList();
    _filteredUsers = List.from(_users);
    notifyListeners();
  }

  Future<void> writeUser(User user) async {
    final response = await postRequest("users", user.toJson());
    final decoded = json.decode(response.body);
    _response = decoded["password"] ?? "User added";
    print(_response);

    print(decoded);
    readUsers();
    notifyListeners();
  }

  Future<void> deleteUser(User user) async {
    final response = await deleteRequest("users/${user.id}", user.toJson());
    //print(response.body);
    final decoded = json.decode(response.body);

    _response = decoded["error"] ?? "User deleted";
    //print(decoded);
    readUsers();
    notifyListeners();
  }

  Future<void> editUser(User user) async {
    print(user.toJson());
    final response = await patchRequest("users/${user.id}", user.toJson());

    final decoded = json.decode(response.body);
    print(decoded);
    readUsers();
    notifyListeners();
  }
}

/// =================== MODELS ===================

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
      id: json['ID'],
      role: json['role'] ?? '',
      name: json['username'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'role': role,
      'username': name,
      'email': email,
      'password': password,
    };
  }
}
