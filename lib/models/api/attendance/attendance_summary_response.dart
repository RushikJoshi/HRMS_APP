import 'attendance_summary.dart';

class AttendanceSummaryResponse {
  final bool success;
  final String? message;
  final AttendanceSummary? data;

  AttendanceSummaryResponse({
    this.success = false,
    this.message,
    this.data,
  });

  factory AttendanceSummaryResponse.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      if (json.containsKey('success') || json.containsKey('data')) {
        return AttendanceSummaryResponse(
          success: json['success'] as bool? ?? false,
          message: json['message'] as String?,
          data: json['data'] != null ? AttendanceSummary.fromJson(json['data'] as Map<String, dynamic>) : null,
        );
      }
      // Unwrapped
      return AttendanceSummaryResponse(
        success: true,
        message: 'Loaded',
        data: AttendanceSummary.fromJson(json),
      );
    }
    return AttendanceSummaryResponse(success: false);
  }
}
