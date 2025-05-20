import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService extends ChangeNotifier {
  final String baseUrl;
  final Map<String, String> _properties = {};

  ApiService({required this.baseUrl});

  String get(String key) => _properties[key] ?? '';

  Future<void> getRequest(String key) async {
    final url = Uri.parse('$baseUrl$key');
    try {
      final response = await http
          .get(url)
          .timeout(
            const Duration(seconds: 2),
            onTimeout: () => http.Response('{"error":"timeout"}', 408),
          );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        _properties[key] = json[key] ?? '';
        notifyListeners();
      } else {
        throw Exception('GET failed: ${response.statusCode}');
      }
    } catch (e) {
      print(key);
      throw Exception('GET error: $e');
    }
  }

  Future<void> postRequest(String key, String value) async {
    final url = Uri.parse('$baseUrl$key');
    final body = jsonEncode({key: value});
    try {
      final response = await http
          .post(url, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(
            const Duration(seconds: 2),
            onTimeout: () => http.Response('{"error":"timeout"}', 408),
          );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        _properties[key] = json[key] ?? '';
        //notifyListeners();
      } else {
        throw Exception('POST failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('POST error: $e');
    }
  }

  Future<void> update(String key, String value) async {
    await postRequest(key, value);
    await getRequest(key);
  }
}

class NtpServerApi extends ApiService {
  NtpServerApi({required String baseUrl})
    : super(baseUrl: '$baseUrl/ntp-server/');
}

class PtpOcApi extends ApiService {
  PtpOcApi({required String baseUrl}) : super(baseUrl: '$baseUrl/ptp-oc/');
}
