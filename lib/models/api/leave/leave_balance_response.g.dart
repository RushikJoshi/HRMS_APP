// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_balance_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaveBalancesResponse _$LeaveBalancesResponseFromJson(
  Map<String, dynamic> json,
) => LeaveBalancesResponse(
  balances: (json['balances'] as List<dynamic>)
      .map((e) => LeaveBalance.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LeaveBalancesResponseToJson(
  LeaveBalancesResponse instance,
) => <String, dynamic>{'balances': instance.balances};

LeaveBalance _$LeaveBalanceFromJson(Map<String, dynamic> json) => LeaveBalance(
  leaveType: json['leaveType'] as String?,
  balance: (json['available'] as num?)?.toDouble(),
  taken: (json['used'] as num?)?.toDouble(),
  entitled: (json['total'] as num?)?.toDouble(),
  color: json['color'] as String?,
);

Map<String, dynamic> _$LeaveBalanceToJson(LeaveBalance instance) =>
    <String, dynamic>{
      'leaveType': instance.leaveType,
      'available': instance.balance,
      'used': instance.taken,
      'total': instance.entitled,
      'color': instance.color,
    };
