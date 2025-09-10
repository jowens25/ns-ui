import 'dart:convert';
import 'dart:async';
import 'package:nct/api/AuthApi.dart';
import 'BaseApi.dart';

class UserApi extends BaseApi {
  User? currentUser;
  List<User> _users = [];
  List<User> get users => _users;
  List<User> _filteredUsers = [];
  List<User> get filteredUsers => _filteredUsers;

  String _response = "response";
  String get response => _response;

  @override
  String get baseUrl => '$serverHost/api/v1';

  UserApi({required super.serverHost});

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
