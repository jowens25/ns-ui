import 'dart:convert';
import 'dart:async';
import 'BaseApi.dart';

class SecurityApi extends BaseApi {
  SecurityPolicy _securityPolicy = SecurityPolicy(
    MinimumLength: "0",
    RequireUpper: "0",
    RequireLower: "0",
    RequireNumber: "0",
    RequireSpecial: "0",
    RequireNoUser: "0",
    MinimumAge: "0",
    MaximumAge: "0",
    ExpirationWarning: "0",
  );
  SecurityPolicy get securityPolicy => _securityPolicy;

  @override
  String get baseUrl => '$serverHost/api/v1/security';

  SecurityApi({required super.serverHost});

  Future<void> readSecurityPolicy() async {
    final response = await getRequest("policy");
    final decoded = jsonDecode(response.body);
    print(decoded);
    _securityPolicy = SecurityPolicy.fromJson(decoded['policy']);
    notifyListeners();
  }

  Future<void> editSecurityPolicy(SecurityPolicy policy) async {
    final response = await postRequest("policy", securityPolicy.toJson());
    print(response.body);
    readSecurityPolicy();
    notifyListeners();
  }
}

class SecurityPolicy {
  String MinimumLength;
  String RequireUpper;
  String RequireLower;
  String RequireNumber;
  String RequireSpecial;
  String RequireNoUser;
  String MinimumAge;
  String MaximumAge;
  String ExpirationWarning;

  SecurityPolicy({
    required this.MinimumLength,
    required this.RequireUpper,
    required this.RequireLower,
    required this.RequireNumber,
    required this.RequireSpecial,
    required this.RequireNoUser,
    required this.MinimumAge,
    required this.MaximumAge,
    required this.ExpirationWarning,
  });

  factory SecurityPolicy.fromJson(Map<String, dynamic> json) {
    return SecurityPolicy(
      MinimumLength: json['minimum_length'] ?? '',
      RequireUpper: json['require_upper'] ?? '',
      RequireLower: json['require_lower'] ?? '',
      RequireNumber: json['require_number'] ?? '',
      RequireSpecial: json['require_special'] ?? '',
      RequireNoUser: json['require_nouser'] ?? '',
      MinimumAge: json['minimum_age'] ?? '',
      MaximumAge: json['maximum_age'] ?? '',
      ExpirationWarning: json['expiration_warning'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minimum_length': MinimumLength,
      'require_upper': RequireUpper,
      'require_lower': RequireLower,
      'require_number': RequireNumber,
      'require_special': RequireSpecial,
      'require_nouser': RequireNoUser,
      'minimum_age': MinimumAge,
      'maximum_age': MaximumAge,
      'expiration_warning': ExpirationWarning,
    };
  }
}
