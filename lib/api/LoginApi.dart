import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web/web.dart';
import 'dart:async';

class LoginApi extends ChangeNotifier {
  User? currentUser; // Add this line to track current user
  List<User> _users = [];
  List<User> _filteredUsers = [];
  final String baseUrl;
  bool _loggedIn = false;
  String _token = '';

  String _messageError = '';
  String get messageError => _messageError;

  Timer? _sessionTimer;

  List<User> get users => _users;
  List<User> get filteredUsers => _filteredUsers;
  String get token => _token;
  bool get isLoggedIn => _loggedIn;
  LoginApi({required this.baseUrl}) {
    getTokenCookie();
    if (_token.isNotEmpty && !isTokenExpired(_token)) {
      _loggedIn = true;
      _getCurrentUserFromToken();
    }
    _startSessionTimer();
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _checkSessionValidity();
    });
  }

  void _getCurrentUserFromToken() {
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
      setTokenCookie(_token);
      _getCurrentUserFromToken();
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

  Future<void> addUser(
    String role,
    String name,
    String email,
    String password,
  ) async {
    final newUserData = {
      'role': role,
      'username': name,
      'email': email,
      'password': password,
    };

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
}

class User {
  String id;
  String role;
  String name;
  String email;
  String password;

  User({
    required this.id,
    required this.role,
    required this.name,
    required this.email,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      role: json['role'] ?? '',
      name: json['username'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      password: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'role': role, 'username': name, 'email': email};
  }
}
