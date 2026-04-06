// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaveListResponse _$LeaveListResponseFromJson(Map<String, dynamic> json) =>
    LeaveListResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => LeaveDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LeaveListResponseToJson(LeaveListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };
