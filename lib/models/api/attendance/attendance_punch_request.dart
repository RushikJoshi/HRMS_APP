class AttendancePunchRequest {
  final String method; // "MANUAL", "FACE", etc.
  final String action; // "IN" or "OUT"

  AttendancePunchRequest({required this.method, required this.action});

  Map<String, dynamic> toJson() => {'method': method, 'action': action};
}
