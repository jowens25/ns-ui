import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ntsc_ui/api/LoginApi.dart';

class UserApi extends ChangeNotifier {
  final String baseUrl;

  UserApi({required this.baseUrl});

  //Map<String, String> get properties;
}
