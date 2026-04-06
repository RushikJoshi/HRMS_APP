import 'package:json_annotation/json_annotation.dart';
import 'leave_dto.dart';

part 'leave_list_response.g.dart';

@JsonSerializable()
class LeaveListResponse {
  final bool? success;
  final String? message;
  final List<LeaveDto>? data;

  LeaveListResponse({this.success, this.message, this.data});

  factory LeaveListResponse.fromJson(Map<String, dynamic> json) => _$LeaveListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LeaveListResponseToJson(this);
}
