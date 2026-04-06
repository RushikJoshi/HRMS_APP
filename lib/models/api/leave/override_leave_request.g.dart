// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'override_leave_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OverrideLeaveRequest _$OverrideLeaveRequestFromJson(
  Map<String, dynamic> json,
) => OverrideLeaveRequest(
  employeeId: json['employeeId'] as String,
  leaveType: json['leaveType'] as String,
  startDate: json['fromDate'] as String,
  endDate: json['toDate'] as String,
  status: json['status'] as String,
  remark: json['remark'] as String,
);

Map<String, dynamic> _$OverrideLeaveRequestToJson(
  OverrideLeaveRequest instance,
) => <String, dynamic>{
  'employeeId': instance.employeeId,
  'leaveType': instance.leaveType,
  'fromDate': instance.startDate,
  'toDate': instance.endDate,
  'status': instance.status,
  'remark': instance.remark,
};
