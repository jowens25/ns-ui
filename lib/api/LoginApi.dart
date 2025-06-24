import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web/web.dart';
import 'dart:async';

class LoginApi extends ChangeNotifier {
  List<User> _users = [];
  List<User> _filteredUsers = [];
  final String baseUrl;
  bool _loggedIn = false;
  String _token = '';
  Timer? _sessionTimer;

  List<User> get users => _users;
  List<User> get filteredUsers => _filteredUsers;
  String get token => _token;
  bool get isLoggedIn => _loggedIn;

  LoginApi({required this.baseUrl}) {
    getTokenCookie();
    if (_token.isNotEmpty && !isTokenExpired(_token)) {
      _loggedIn = true;
    }
    _startSessionTimer();
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _checkSessionValidity();
    });
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
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
      setTokenCookie(_token);
      notifyListeners();
      return body;
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
    deleteTokenCookie();
    notifyListeners();
  }

  void _checkSessionValidity() {
    if (!_loggedIn) return;
    getTokenCookie();
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

  void setTokenCookie(String token) {
    document.cookie = 'token=$token; path=/; max-age=3600; samesite=lax';
  }

  void getTokenCookie() {
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

  void deleteTokenCookie() {
    document.cookie = 'token=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT';
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  // User Management
  Future<void> getAllUsers() async {
    notifyListeners();

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

  Future<void> addUser(String name, String email) async {
    notifyListeners();

    final newUserData = {'username': name, 'email': email};

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/v1/users'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(newUserData),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);

        // If the API returns the created user, add it to the list
        if (decoded.containsKey('user')) {
          final createdUser = User.fromJson(decoded['user']);
          _users.add(createdUser);
        } else if (decoded.containsKey('users')) {
          // If the API returns all users, replace the entire list
          _users =
              (decoded['users'] as List)
                  .map((userJson) => User.fromJson(userJson))
                  .toList();
        } else {
          // If no user data is returned, create a temporary user
          // You should refresh the user list after this
          final tempUser = User(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            email: email,
          );
          _users.add(tempUser);

          // Optionally refresh the entire user list to get the actual data
          // await getAllUsers();
        }

        _updateFiltered();
        notifyListeners();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again');
      } else if (response.statusCode == 400) {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'Bad Request: ${errorBody['message'] ?? 'Invalid user data'}',
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
    _users.removeWhere((u) => u.id == user.id);
    _updateFiltered();
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
}

class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['username'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': name, 'email': email};
  }
}
