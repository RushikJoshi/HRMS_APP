import 'package:json_annotation/json_annotation.dart';

part 'override_leave_request.g.dart';

@JsonSerializable()
class OverrideLeaveRequest {
  final String employeeId;
  final String leaveType;
  @JsonKey(name: 'fromDate')
  final String startDate;
  @JsonKey(name: 'toDate')
  final String endDate;
  final String status;
  final String remark;

  OverrideLeaveRequest({
    required this.employeeId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.remark,
  });

  factory OverrideLeaveRequest.fromJson(Map<String, dynamic> json) => _$OverrideLeaveRequestFromJson(json);
  Map<String, dynamic> toJson() => _$OverrideLeaveRequestToJson(this);
}
