import 'package:json_annotation/json_annotation.dart';

part 'leave_dto.g.dart';

@JsonSerializable()
class LeaveDto {
  @JsonKey(name: '_id')
  final String? id;
  final String? leaveType;
  final String? startDate;
  final String? endDate;
  final String? reason;
  final String? status;
  final String? appliedDate;
  @JsonKey(fromJson: _employeeFromJson)
  final Map<String, dynamic>? employee; // For Team/HR view

  static Map<String, dynamic>? _employeeFromJson(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    return null;
  }

  LeaveDto({
    this.id,
    this.leaveType,
    this.startDate,
    this.endDate,
    this.reason,
    this.status,
    this.appliedDate,
    this.employee,
  });

  factory LeaveDto.fromJson(Map<String, dynamic> json) {
     // Handle cases where id might be 'id' or '_id'
     if (json['id'] != null && json['_id'] == null) {
       json['_id'] = json['id'];
     }
     return _$LeaveDtoFromJson(json);
  }
  Map<String, dynamic> toJson() => _$LeaveDtoToJson(this);
}
