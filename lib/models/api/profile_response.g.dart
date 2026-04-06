// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileResponse _$ProfileResponseFromJson(Map<String, dynamic> json) =>
    ProfileResponse(
      success: json['success'] == null
          ? false
          : ProfileResponse._boolFromJson(json['success']),
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : ProfileData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProfileResponseToJson(ProfileResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

LeavePolicy _$LeavePolicyFromJson(Map<String, dynamic> json) => LeavePolicy(
  id: json['_id'] as String?,
  name: json['name'] as String?,
  rules: (json['rules'] as List<dynamic>?)
      ?.map((e) => LeaveRule.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LeavePolicyToJson(LeavePolicy instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'rules': instance.rules,
    };

LeaveRule _$LeaveRuleFromJson(Map<String, dynamic> json) => LeaveRule(
  leaveType: json['leaveType'] as String?,
  totalPerYear: (json['totalPerYear'] as num?)?.toDouble(),
  color: json['color'] as String?,
);

Map<String, dynamic> _$LeaveRuleToJson(LeaveRule instance) => <String, dynamic>{
  'leaveType': instance.leaveType,
  'totalPerYear': instance.totalPerYear,
  'color': instance.color,
};

Education _$EducationFromJson(Map<String, dynamic> json) => Education(
  type: json['type'] as String?,
  class10Marksheet: json['class10Marksheet'] as String?,
  diplomaCertificate: json['diplomaCertificate'] as String?,
  bachelorDegree: json['bachelorDegree'] as String?,
);

Map<String, dynamic> _$EducationToJson(Education instance) => <String, dynamic>{
  'type': instance.type,
  'class10Marksheet': instance.class10Marksheet,
  'diplomaCertificate': instance.diplomaCertificate,
  'bachelorDegree': instance.bachelorDegree,
};

Documents _$DocumentsFromJson(Map<String, dynamic> json) => Documents(
  aadharFront: json['aadharFront'] as String?,
  aadharBack: json['aadharBack'] as String?,
  panCard: json['panCard'] as String?,
);

Map<String, dynamic> _$DocumentsToJson(Documents instance) => <String, dynamic>{
  'aadharFront': instance.aadharFront,
  'aadharBack': instance.aadharBack,
  'panCard': instance.panCard,
};

TempAddress _$TempAddressFromJson(Map<String, dynamic> json) => TempAddress(
  line1: json['line1'] as String?,
  line2: json['line2'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  pinCode: json['pinCode'] as String?,
  country: json['country'] as String?,
);

Map<String, dynamic> _$TempAddressToJson(TempAddress instance) =>
    <String, dynamic>{
      'line1': instance.line1,
      'line2': instance.line2,
      'city': instance.city,
      'state': instance.state,
      'pinCode': instance.pinCode,
      'country': instance.country,
    };

PermAddress _$PermAddressFromJson(Map<String, dynamic> json) => PermAddress(
  line1: json['line1'] as String?,
  line2: json['line2'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  pinCode: json['pinCode'] as String?,
  country: json['country'] as String?,
);

Map<String, dynamic> _$PermAddressToJson(PermAddress instance) =>
    <String, dynamic>{
      'line1': instance.line1,
      'line2': instance.line2,
      'city': instance.city,
      'state': instance.state,
      'pinCode': instance.pinCode,
      'country': instance.country,
    };

BankDetails _$BankDetailsFromJson(Map<String, dynamic> json) => BankDetails(
  bankName: json['bankName'] as String?,
  accountNumber: json['accountNumber'] as String?,
  ifsc: json['ifsc'] as String?,
  branchName: json['branchName'] as String?,
);

Map<String, dynamic> _$BankDetailsToJson(BankDetails instance) =>
    <String, dynamic>{
      'bankName': instance.bankName,
      'accountNumber': instance.accountNumber,
      'ifsc': instance.ifsc,
      'branchName': instance.branchName,
    };

DepartmentId _$DepartmentIdFromJson(Map<String, dynamic> json) =>
    DepartmentId(id: json['_id'] as String?, name: json['name'] as String?);

Map<String, dynamic> _$DepartmentIdToJson(DepartmentId instance) =>
    <String, dynamic>{'_id': instance.id, 'name': instance.name};
