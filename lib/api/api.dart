import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class ApiService extends ChangeNotifier {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Map<String, String> get properties;

  Future<void> getRequest(String key) async {
    final url = Uri.parse('$baseUrl$key');
    try {
      final response = await http
          .get(url)
          .timeout(
            const Duration(seconds: 1),
            onTimeout: () => http.Response('{"error":"timeout"}', 408),
          );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        properties[key] = json[key] ?? '';
        notifyListeners();
      } else {
        print(url);

        print(key);

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

    print("key: $key");
    print("value: $value");
    try {
      final response = await http
          .post(url, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(
            const Duration(seconds: 1),
            onTimeout: () {
              http.Response('{"error":"timeout"}', 408);
              print("time out");
              throw Exception("time out");
            },
          );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        properties[key] = json[key] ?? '';
        //notifyListeners();
      } else {
        print(url);
        throw Exception('POST failed: ${response.statusCode}');
      }
    } catch (e) {
      print(url);

      throw Exception('POST error: $e');
    }
  }

  Future<void> update(String key, String value) async {
    await postRequest(key, value);
    await getRequest(key);
  }

  Future<void> get(String key) async {
    print("key: $key");
    print(properties[key]);
    await getRequest(key);
    print(properties[key]);
    notifyListeners();
  }

  void poll() {
    for (var k in properties.keys) {
      getRequest(k);
    }
    Timer.periodic(const Duration(milliseconds: 5000), (timer) {
      print('Polling');

      for (var k in properties.keys) {
        getRequest(k);
      }
      //if (timer.tick == 5) {
      //  // Cancel after 5 iterations
      //  timer.cancel();
      //}
    });
  }
}
