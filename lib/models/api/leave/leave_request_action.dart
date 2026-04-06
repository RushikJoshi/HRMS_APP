import 'package:json_annotation/json_annotation.dart';

part 'leave_request_action.g.dart';

@JsonSerializable()
class LeaveRequestAction {
  final String? status;
  final String remark;

  LeaveRequestAction({this.status, required this.remark});

  factory LeaveRequestAction.fromJson(Map<String, dynamic> json) => _$LeaveRequestActionFromJson(json);
  Map<String, dynamic> toJson() => _$LeaveRequestActionToJson(this);
}
