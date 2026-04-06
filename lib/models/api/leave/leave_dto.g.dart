// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaveDto _$LeaveDtoFromJson(Map<String, dynamic> json) => LeaveDto(
  id: json['_id'] as String?,
  leaveType: json['leaveType'] as String?,
  startDate: json['startDate'] as String?,
  endDate: json['endDate'] as String?,
  reason: json['reason'] as String?,
  status: json['status'] as String?,
  appliedDate: json['appliedDate'] as String?,
  employee: LeaveDto._employeeFromJson(json['employee']),
);

Map<String, dynamic> _$LeaveDtoToJson(LeaveDto instance) => <String, dynamic>{
  '_id': instance.id,
  'leaveType': instance.leaveType,
  'startDate': instance.startDate,
  'endDate': instance.endDate,
  'reason': instance.reason,
  'status': instance.status,
  'appliedDate': instance.appliedDate,
  'employee': instance.employee,
};
