import 'package:json_annotation/json_annotation.dart';

part 'leave_balance_response.g.dart';

@JsonSerializable()
class LeaveBalancesResponse {
  final List<LeaveBalance> balances;

  LeaveBalancesResponse({required this.balances});

  factory LeaveBalancesResponse.fromJson(Map<String, dynamic> json) => _$LeaveBalancesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LeaveBalancesResponseToJson(this);
}

@JsonSerializable()
class LeaveBalance {
  final String? leaveType;
  @JsonKey(name: 'available')
  final double? balance;
  @JsonKey(name: 'used')
  final double? taken;
  @JsonKey(name: 'total')
  final double? entitled;
  
  // Also include color if needed
  final String? color;
  
  LeaveBalance({this.leaveType, this.balance, this.taken, this.entitled, this.color});

  factory LeaveBalance.fromJson(Map<String, dynamic> json) => _$LeaveBalanceFromJson(json);
  Map<String, dynamic> toJson() => _$LeaveBalanceToJson(this);
}
