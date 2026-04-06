import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  @JsonKey(
    name: 'success',
    defaultValue: false,
    fromJson: _boolFromJson,
  )
  final bool success;
  final String? message;
  final LoginData? data;

  LoginResponse({
    this.success = false,
    this.message,
    this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Handle specific API case where data is flat (token/user at root)
    if (!json.containsKey('data') && json.containsKey('token')) {
      final modifiedJson = Map<String, dynamic>.from(json);
      
      // Move token and user/employee to 'data' object
      modifiedJson['data'] = {
        'token': json['token'],
        'employee': json['user'] ?? json['employee'],
      };
      
      // Ensure success flag is present
      if (!modifiedJson.containsKey('success')) {
        modifiedJson['success'] = true; 
      }
      
      return _$LoginResponseFromJson(modifiedJson);
    }

    return _$LoginResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);

  static bool _boolFromJson(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value != 0;
    return false;
  }
}

@JsonSerializable()
class LoginData {
  final String? token;
  final EmployeeData? employee;

  LoginData({
    this.token,
    this.employee,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) =>
      _$LoginDataFromJson(json);

  Map<String, dynamic> toJson() => _$LoginDataToJson(this);
}

@JsonSerializable()
class EmployeeData {
  final String? id;
  final String? name;
  final String? email;
  final String? employeeId;
  final String? companyCode;
  final String? designation;
  final String? department;

  EmployeeData({
    this.id,
    this.name,
    this.email,
    this.employeeId,
    this.companyCode,
    this.designation,
    this.department,
  });

  factory EmployeeData.fromJson(Map<String, dynamic> json) =>
      _$EmployeeDataFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeDataToJson(this);
}
