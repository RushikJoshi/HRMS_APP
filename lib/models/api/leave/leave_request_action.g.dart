// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_request_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaveRequestAction _$LeaveRequestActionFromJson(Map<String, dynamic> json) =>
    LeaveRequestAction(
      status: json['status'] as String?,
      remark: json['remark'] as String,
    );

Map<String, dynamic> _$LeaveRequestActionToJson(LeaveRequestAction instance) =>
    <String, dynamic>{'status': instance.status, 'remark': instance.remark};
