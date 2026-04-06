class AttendanceLog {
  final String? date;
  final String? inTime;
  final String? outTime;
  final String? status;
  final String? workingHours;
  final String? breakDuration;

  AttendanceLog({
    this.date,
    this.inTime,
    this.outTime,
    this.status,
    this.workingHours,
    this.breakDuration,
  });

  factory AttendanceLog.fromJson(Map<String, dynamic> json) {
    return AttendanceLog(
      date: json['date'] as String?,
      inTime: json['checkIn'] as String?, // API uses 'checkIn' not 'inTime'
      outTime: json['checkOut'] as String?, // API uses 'checkOut' not 'outTime'
      status: json['status'] as String?,
      workingHours: json['workingHours']?.toString(), // Convert int/double to String
      breakDuration: json['breakDuration']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'inTime': inTime,
      'outTime': outTime,
      'status': status,
      'workingHours': workingHours,
      'breakDuration': breakDuration,
    };
  }
}
