// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apply_leave_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApplyLeaveRequest _$ApplyLeaveRequestFromJson(Map<String, dynamic> json) =>
    ApplyLeaveRequest(
      leaveType: json['leaveType'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      reason: json['reason'] as String,
      isHalfDay: json['halfDay'] as bool?,
      halfDayTarget: json['halfDayTarget'] as String?,
      halfDaySession: json['halfDaySession'] as String?,
      employeeId: json['employeeId'] as String?,
    );

Map<String, dynamic> _$ApplyLeaveRequestToJson(ApplyLeaveRequest instance) =>
    <String, dynamic>{
      'leaveType': instance.leaveType,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'reason': instance.reason,
      'halfDay': instance.isHalfDay,
      'halfDayTarget': instance.halfDayTarget,
      'halfDaySession': instance.halfDaySession,
      'employeeId': instance.employeeId,
    };
