class AttendanceSummary {
  final String? inTime;
  final String? outTime;
  final String? workingHours;
  final String? status;

  AttendanceSummary({
    this.inTime,
    this.outTime,
    this.workingHours,
    this.status,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      inTime: json['checkIn'] as String?, // API uses 'checkIn'
      outTime: json['checkOut'] as String?, // API uses 'checkOut'
      workingHours: json['workingHours']?.toString(), // Convert to String
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inTime': inTime,
      'outTime': outTime,
      'workingHours': workingHours,
      'status': status,
    };
  }
}
