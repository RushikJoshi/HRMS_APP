// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      success: json['success'] == null
          ? false
          : LoginResponse._boolFromJson(json['success']),
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : LoginData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

LoginData _$LoginDataFromJson(Map<String, dynamic> json) => LoginData(
  token: json['token'] as String?,
  employee: json['employee'] == null
      ? null
      : EmployeeData.fromJson(json['employee'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LoginDataToJson(LoginData instance) => <String, dynamic>{
  'token': instance.token,
  'employee': instance.employee,
};

EmployeeData _$EmployeeDataFromJson(Map<String, dynamic> json) => EmployeeData(
  id: json['id'] as String?,
  name: json['name'] as String?,
  email: json['email'] as String?,
  employeeId: json['employeeId'] as String?,
  companyCode: json['companyCode'] as String?,
  designation: json['designation'] as String?,
  department: json['department'] as String?,
);

Map<String, dynamic> _$EmployeeDataToJson(EmployeeData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'employeeId': instance.employeeId,
      'companyCode': instance.companyCode,
      'designation': instance.designation,
      'department': instance.department,
    };
