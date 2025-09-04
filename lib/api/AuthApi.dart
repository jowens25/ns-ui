import 'dart:convert';

import 'package:nct/api/BaseApi.dart';
import 'package:web/web.dart';
import 'dart:async';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:nct/api/UserApi.dart';

class AuthApi extends BaseApi {
  @override
  String get baseUrl => '$serverHost/api/v1/auth';

  AuthApi({required super.serverHost}) {
    isTokenValid();
    _startSessionTimer();
  }

  bool _loggedIn = false;
  bool get isLoggedIn => _loggedIn;

  Timer? _sessionTimer;

  void isTokenValid() {
    try {
      JWT.verify(getToken(), SecretKey("your-secret-key"));
      _loggedIn = true;
    } on JWTExpiredException {
      print('JWT expired');
      _loggedIn = false;
    } on JWTException catch (ex) {
      print('Signature invalid: ${ex.message}');
      _loggedIn = false;
    }
    notifyListeners();
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      isTokenValid();
      notifyListeners();
    });
  }

  Future<void> login(User user) async {
    final response = await postRequest("login", user.toJson());
    final decoded = json.decode(response.body);
    //_loggedIn = true;
    print('decoded: $decoded');
    setToken(decoded['token']);
    isTokenValid();
    notifyListeners();
  }

  void logout() {
    deleteToken();
    _loggedIn = false;
    notifyListeners();
  }

  void setToken(String tok) {
    document.cookie = 'token=$tok; path=/; max-age=3600; samesite=lax';
  }

  //
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

  void deleteToken() {
    document.cookie = 'token=; path=/; max-age=0';
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }
}
