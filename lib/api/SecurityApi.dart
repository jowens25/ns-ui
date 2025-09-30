import 'dart:convert';
import 'dart:async';
//import 'dart:ffi';
import 'BaseApi.dart';

class SecurityApi extends BaseApi {
  String _response = '';
  String get response => _response;

  List<String>? _validationErrors;
  List<String>? get validationError => _validationErrors;

  SecurityPolicy? _securityPolicy;
  SecurityPolicy? get securityPolicy => _securityPolicy;

  @override
  String get baseUrl => '$serverHost/api/v1/security';

  SecurityApi({required super.serverHost});

  Future<void> readSecurityPolicy() async {
    final response = await getRequest("policy");
    final decoded = jsonDecode(response.body);
    _securityPolicy = SecurityPolicy.fromJson(decoded['policy']);
    notifyListeners();
  }

  Future<void> editSecurityPolicy(SecurityPolicy policy) async {
    final response = await postRequest("policy", policy.toJson());

    if (response.statusCode == 403) {
      _response = jsonDecode(response.body)['error'];
    }
    if (response.statusCode == 200) {
      _response = "policy updated";
    }

    readSecurityPolicy();
    notifyListeners();
  }

  bool validatePassword(
    String password,
    String username,
    SecurityPolicy policy,
  ) {
    List<String> errors = [];

    if (password.length < policy.MinimumLength) {
      errors.add(
        "Password must be at least ${policy.MinimumLength} characters long",
      );
    }

    if (policy.RequireUpper && !password.contains(RegExp(r'[A-Z]'))) {
      errors.add("Password must contain at least one uppercase letter");
    }

    if (policy.RequireLower && !password.contains(RegExp(r'[a-z]'))) {
      errors.add("Password must contain at least one lowercase letter");
    }

    if (policy.RequireNumber && !password.contains(RegExp(r'[0-9]'))) {
      errors.add("Password must contain at least one number");
    }

    if (policy.RequireSpecial &&
        !password.contains(RegExp(r'[!@#$%^&*(),.?\":{}|<>]'))) {
      errors.add("Password must contain at least one special character");
    }

    if (policy.RequireNoUser &&
        username.isNotEmpty &&
        password.toLowerCase().contains(username.toLowerCase())) {
      errors.add("Password cannot contain the username");
    }

    _validationErrors = errors;
    if (errors.isNotEmpty) {
      _response = errors.join('\n');
      return false;
    }

    return true;
  }
}

class SecurityPolicy {
  int MinimumLength;
  bool RequireUpper;
  bool RequireLower;
  bool RequireNumber;
  bool RequireSpecial;
  bool RequireNoUser;
  int MinimumAge;
  int MaximumAge;
  int ExpirationWarning;

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
      MinimumLength: json['minimum_length'] ?? 0,
      RequireUpper: json['require_upper'] ?? false,
      RequireLower: json['require_lower'] ?? false,
      RequireNumber: json['require_number'] ?? false,
      RequireSpecial: json['require_special'] ?? false,
      RequireNoUser: json['require_nouser'] ?? false,
      MinimumAge: json['minimum_age'] ?? 0,
      MaximumAge: json['maximum_age'] ?? 0,
      ExpirationWarning: json['expiration_warning'] ?? 0,
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
