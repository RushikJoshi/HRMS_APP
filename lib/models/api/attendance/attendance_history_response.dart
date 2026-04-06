import 'attendance_log.dart';

class AttendanceHistoryResponse {
  final bool success;
  final String? message;
  final List<AttendanceLog>? data;

  AttendanceHistoryResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory AttendanceHistoryResponse.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
       if (json.containsKey('success') || json.containsKey('data')) {
          return AttendanceHistoryResponse(
            success: json['success'] as bool? ?? false,
            message: json['message'] as String?,
            data: (json['data'] as List<dynamic>?)
                ?.map((e) => AttendanceLog.fromJson(e as Map<String, dynamic>))
                .toList(),
          );
       }
    }
    if (json is List) {
       // Direct list
       return AttendanceHistoryResponse(
         success: true,
         message: 'Success',
         data: json.map((e) => AttendanceLog.fromJson(e as Map<String, dynamic>)).toList(),
       );
    }
    return AttendanceHistoryResponse(success: false, message: 'Invalid response format');
  }
}
