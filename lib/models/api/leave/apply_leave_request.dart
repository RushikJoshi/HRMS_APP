import 'package:json_annotation/json_annotation.dart';

part 'apply_leave_request.g.dart';

@JsonSerializable()
class ApplyLeaveRequest {
  final String leaveType;
  final String startDate;
  final String endDate;
  final String reason;
  @JsonKey(name: 'halfDay')
  final bool? isHalfDay;
  final String? halfDayTarget; // "Start" or "End" if needed
  final String? halfDaySession; // "First" or "Second" for API, but can accept "FN"/"AN" which will be mapped
  final String? employeeId; // For HR to apply on behalf

  ApplyLeaveRequest({
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.isHalfDay,
    this.halfDayTarget,
    this.halfDaySession,
    this.employeeId,
  });

  factory ApplyLeaveRequest.fromJson(Map<String, dynamic> json) => _$ApplyLeaveRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ApplyLeaveRequestToJson(this);
}
