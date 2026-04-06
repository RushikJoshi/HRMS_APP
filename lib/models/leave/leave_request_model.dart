import 'package:flutter/material.dart';

enum LeaveType {
  casual('Casual Leave', 'CL'),
  sick('Sick Leave', 'SL'),
  annual('Annual Leave', 'AL'),
  earned('Earned Leave', 'EL'),
  eol('Extra Ordinary Leave (EOL)', 'EOL'),
  maternity('Maternity Leave', 'ML'),
  paternity('Paternity Leave', 'PL');

  final String label;
  final String code;
  const LeaveType(this.label, this.code);

  static LeaveType fromString(String value) {
    return LeaveType.values.firstWhere(
      (e) => e.label.toLowerCase() == value.toLowerCase() || 
             e.name.toLowerCase() == value.toLowerCase() ||
             e.code.toLowerCase() == value.toLowerCase(),
      orElse: () => LeaveType.casual, // Default fallback
    );
  }
}

enum LeaveStatus {
  pending('Pending', Color(0xFFE67E22)),   // Orange
  inProcess('In Process', Color(0xFF2980B9)), // Blue
  approved('Approved', Color(0xFF27AE60)),  // Green
  rejected('Rejected', Color(0xFFC0392B)),  // Red
  cancelled('Cancelled', Color(0xFF9E9E9E)); // Grey

  final String label;
  final Color color;
  const LeaveStatus(this.label, this.color);

  static LeaveStatus fromString(String value) {
    return LeaveStatus.values.firstWhere(
      (e) => e.label.toLowerCase() == value.toLowerCase() || 
             e.name.toLowerCase() == value.toLowerCase() ||
             (value.toLowerCase() == 'pending' && e == LeaveStatus.pending),
      orElse: () => LeaveStatus.pending,
    );
  }
}

class LeaveRequest {
  final String id;
  final LeaveType type;
  final DateTime fromDate;
  final DateTime toDate;
  final String reason;
  final LeaveStatus status;
  final DateTime? appliedDate;
  final DateTime? approvalDate;
  final String? attachmentUrl;
  final String? appliedBy;
  final String? appliedFor;
  final bool isHalfDay;
  final String locationType; // 'In-Land' or 'Ex-Pak'

  LeaveRequest({
    required this.id,
    required this.type,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    required this.status,
    this.appliedDate,
    this.approvalDate,
    this.attachmentUrl,
    this.appliedBy,
    this.appliedFor,
    this.isHalfDay = false,
    this.locationType = 'In-Land',
  });

  int get totalDays {
    return toDate.difference(fromDate).inDays + 1;
  }
}
