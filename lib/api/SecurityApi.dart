import 'dart:convert';
import 'dart:async';
import 'BaseApi.dart';

class SecurityApi extends BaseApi {
  String? _response;
  String? get response => _response;

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
    final response = await postRequest("policy", policy.toJson());
    print("post response ${response.body}");
    readSecurityPolicy();
    notifyListeners();
  }

  Future<void> editCurrentUserPassword(
    String old,
    String new1,
    String new2,
  ) async {
    Password pw = Password.fromJson({"old": old, "new1": new1, "new2": new2});
    _response = null;

    if (new1 != new2) {
      _response = "new passwords do not match";
    }
    final response = await postRequest("chpw", pw.toJson());
    //print("post response ${response.body}");
    //readSecurityPolicy();
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

class Password {
  String Old;
  String New1;
  String New2;

  Password({required this.Old, required this.New1, required this.New2});

  factory Password.fromJson(Map<String, dynamic> json) {
    return Password(
      Old: json['old'] ?? '',
      New1: json['new1'] ?? '',
      New2: json['new2'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'old': Old, 'new1': New1, 'new2': New2};
  }
}
