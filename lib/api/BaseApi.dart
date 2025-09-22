import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'UserApi.dart';

class BaseApi extends ChangeNotifier {
  final String serverHost;
  bool _invalid = true;
  bool get invalid => _invalid;

  String get baseUrl => serverHost; // base implementation

  BaseApi({required this.serverHost});

  Future<http.Response> getRequest(String endpoint) async {
    _invalid = false;
    final response = await http
        .get(
          Uri.parse('$baseUrl/$endpoint'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${UserApi.getToken()}',
          },
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 404) {
      _invalid = true;
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      print('Failed to get $baseUrl/$endpoint: ${response.statusCode}');
    }
    return response;
  }

  Future<http.Response> patchRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http
        .patch(
          Uri.parse('$baseUrl/$endpoint'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${UserApi.getToken()}',
          },
          body: json.encode(body),
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200 && response.statusCode != 201) {
      print('Failed to patch $body to $endpoint: ${response.statusCode}');
    }
    return response;
  }

  Future<http.Response> postRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/$endpoint'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${UserApi.getToken()}',
          },
          body: json.encode(body),
        )
        .timeout(const Duration(seconds: 5));
    if (response.statusCode != 200 && response.statusCode != 201) {
      print('Failed to post $body to $endpoint: ${response.statusCode}');
    }
    return response;
  }

  Future<http.Response> deleteRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http
        .delete(
          Uri.parse('$baseUrl/$endpoint'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${UserApi.getToken()}',
          },
          body: json.encode(body),
        )
        .timeout(const Duration(seconds: 5));
    if (response.statusCode != 200 && response.statusCode != 201) {
      print('Failed to delete $body from $endpoint: ${response.statusCode}');
    }
    return response;
  }
}
