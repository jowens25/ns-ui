import 'dart:convert';
import 'package:http/http.dart' as http;
import 'PublicApi.dart';

// Unified success/error wrapper
class ApiResult<T> {
  final T? data;
  final String? error;
  final int statusCode;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  ApiResult.success(this.data, this.statusCode) : error = null;
  ApiResult.error(this.error, this.statusCode) : data = null;
}

class BaseApi2 {
  final String serverHost;

  String get baseUrl => serverHost;

  BaseApi2({required this.serverHost});

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${PublicApi.getToken()}',
  };

  Future<ApiResult<Map<String, dynamic>>> getRequest(String endpoint) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/$endpoint'), headers: _headers)
          .timeout(const Duration(seconds: 5));

      final decoded = _safeDecode(response);

      return ApiResult.success(decoded, response.statusCode);
    } catch (e) {
      return ApiResult.error(e.toString(), 500);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> postRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/$endpoint'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 5));

      final decoded = _safeDecode(response);
      return ApiResult.success(decoded, response.statusCode);
    } catch (e) {
      return ApiResult.error(e.toString(), 500);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> patchRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http
          .patch(
            Uri.parse('$baseUrl/$endpoint'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 5));

      final decoded = _safeDecode(response);
      return ApiResult.success(decoded, response.statusCode);
    } catch (e) {
      return ApiResult.error(e.toString(), 500);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> deleteRequest(String endpoint) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/$endpoint'), headers: _headers)
          .timeout(const Duration(seconds: 5));

      final decoded = _safeDecode(response);
      return ApiResult.success(decoded, response.statusCode);
    } catch (e) {
      return ApiResult.error(e.toString(), 500);
    }
  }

  // graceful fallback for empty responses
  Map<String, dynamic> _safeDecode(http.Response response) {
    if (response.body.isEmpty) return {};
    try {
      return jsonDecode(response.body);
    } catch (e) {
      return {};
    }
  }
}
