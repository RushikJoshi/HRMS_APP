import 'package:dio/dio.dart';
import '../injection/injection.dart'; // shared Dio instance (has auth interceptor)
import '../models/api/leave/leave_dto.dart';
import '../models/api/leave/leave_balance_response.dart';

/// Service for all Leave APIs
/// Base: https://hrms.gitakshmi.com/api
/// All paths under /leaves/* (plural)
class LeaveService {
  // Re-use the globally configured Dio (carries Auth + X-Tenant-ID interceptors)
  final Dio _dio = dio;

  LeaveService({dynamic apiServices}); // kept for backward-compat with callers

  // ──────────────────────────────────────────────────────────
  // 1. GET /leaves/balances  — My Leave Balances
  // ──────────────────────────────────────────────────────────
  Future<LeaveBalancesResponse> getLeaveBalance() async {
    try {
      final response = await _dio.get('/employee/leaves/balances');
      final data = response.data;

      // Response may be a list or a map with a 'balances' key
      List<dynamic> rawList = [];
      if (data is List) {
        rawList = data;
      } else if (data is Map) {
        rawList =
            (data['balances'] ?? data['data'] ?? data['leaveBalances'] ?? [])
                as List;
      }

      final balances = rawList
          .map(
            (e) => LeaveBalance.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();

      return LeaveBalancesResponse(balances: balances);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ──────────────────────────────────────────────────────────
  // 2. POST /leaves/apply  — Apply / on-behalf Leave
  // ──────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> applyLeave({
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    bool isHalfDay = false,
    String? halfDayTarget, // "Start" | "End"
    String? halfDaySession, // "Morning" | "Afternoon"
    String? employeeId, // HR: apply on behalf
  }) async {
    try {
      final body = <String, dynamic>{
        'leaveType': leaveType,
        'startDate': startDate.toIso8601String().split('T')[0],
        'endDate': endDate.toIso8601String().split('T')[0],
        'reason': reason,
        'isHalfDay': isHalfDay,
        if (isHalfDay && halfDayTarget != null) 'halfDayTarget': halfDayTarget,
        if (isHalfDay && halfDaySession != null)
          'halfDaySession': halfDaySession,
        if (employeeId != null && employeeId.isNotEmpty)
          'employeeId': employeeId,
      };

      final response = await _dio.post('/employee/leaves/apply', data: body);
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) return responseData;
      return {'success': true, 'message': 'Leave applied successfully'};
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ──────────────────────────────────────────────────────────
  // 3. GET /leaves/my  — My Leave History
  // ──────────────────────────────────────────────────────────
  Future<List<LeaveDto>> getMyLeaves({int page = 1, int limit = 10}) async {
    try {
      final response = await _dio.get('/employee/leaves/history');
      return _parseLeaveDtoList(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ──────────────────────────────────────────────────────────
  // 4. PUT /leaves/edit/{leaveId}  — Edit Pending Leave
  // ──────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> editLeave({
    required String leaveId,
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    bool isHalfDay = false,
    String? halfDayTarget,
    String? halfDaySession,
  }) async {
    try {
      final body = <String, dynamic>{
        'leaveType': leaveType,
        'startDate': startDate.toIso8601String().split('T')[0],
        'endDate': endDate.toIso8601String().split('T')[0],
        'reason': reason,
        'isHalfDay': isHalfDay,
        if (isHalfDay && halfDayTarget != null) 'halfDayTarget': halfDayTarget,
        if (isHalfDay && halfDaySession != null)
          'halfDaySession': halfDaySession,
      };

      final response = await _dio.put(
        '/employee/leaves/edit/$leaveId',
        data: body,
      );
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) return responseData;
      return {'success': true};
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ──────────────────────────────────────────────────────────
  // 5. POST /leaves/cancel/{leaveId}  — Cancel Leave
  // ──────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> cancelLeave({required String leaveId}) async {
    try {
      final response = await _dio.post('/employee/leaves/cancel/$leaveId');
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) return responseData;
      return {'success': true};
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ──────────────────────────────────────────────────────────
  // 6. GET /leaves/approved-dates  — Calendar Approved Dates
  // ──────────────────────────────────────────────────────────
  Future<List<DateTime>> getApprovedDates() async {
    try {
      final response = await _dio.get('/employee/leaves/approved-dates');
      final data = response.data;
      if (data is List) {
        return data
            .map((e) {
              final raw = e is Map
                  ? (e['date'] ?? e['startDate'] ?? '')
                  : e.toString();
              return DateTime.tryParse(raw.toString());
            })
            .whereType<DateTime>()
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ──────────────────────────────────────────────────────────
  // 7. GET /leaves/team  — Manager: Team Leaves
  // ──────────────────────────────────────────────────────────
  Future<List<LeaveDto>> getTeamLeaves({int page = 1, int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/employee/leaves/team',
        queryParameters: {'page': page, 'limit': limit},
      );
      return _parseLeaveDtoList(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ──────────────────────────────────────────────────────────
  // 8. POST /leaves/approve/{leaveId}  — Approve Leave
  // ──────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> approveLeave({
    required String leaveId,
    String remark = 'Approved',
  }) async {
    try {
      final response = await _dio.post(
        '/employee/leaves/approve/$leaveId',
        data: {'remark': remark},
      );
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) return responseData;
      return {'success': true};
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ──────────────────────────────────────────────────────────
  // 9. POST /leaves/reject/{leaveId}  — Reject Leave
  // ──────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> rejectLeave({
    required String leaveId,
    required String rejectionReason,
  }) async {
    try {
      final response = await _dio.post(
        '/employee/leaves/reject/$leaveId',
        data: {'rejectionReason': rejectionReason},
      );
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) return responseData;
      return {'success': true};
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ──────────────────────────────────────────────────────────
  // 10. GET /leaves/all  — HR/Admin: All Company Leaves
  // ──────────────────────────────────────────────────────────
  Future<List<LeaveDto>> getAllLeaves({int page = 1, int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/employee/leaves/all',
        queryParameters: {'page': page, 'limit': limit},
      );
      return _parseLeaveDtoList(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ──────────────────────────────────────────────────────────
  // HELPERS
  // ──────────────────────────────────────────────────────────
  List<LeaveDto> _parseLeaveDtoList(dynamic data) {
    List<dynamic> rawList = [];
    if (data is List) {
      rawList = data;
    } else if (data is Map) {
      rawList =
          (data['leaves'] ??
                  data['data'] ??
                  data['requests'] ??
                  data['leaveRequests'] ??
                  [])
              as List;
    }
    return rawList
        .map((e) => LeaveDto.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  String _handleDioError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response?.statusCode;
      final responseData = error.response?.data;

      if (responseData is Map && responseData.containsKey('message')) {
        return responseData['message'].toString();
      }
      switch (statusCode) {
        case 400:
          return 'Bad request: ${responseData ?? 'Invalid data'}';
        case 401:
          return 'Unauthorized: Please login again';
        case 403:
          return 'Forbidden: You do not have permission';
        case 404:
          return 'Not found: Resource does not exist';
        case 500:
          return 'Server error: Please try again later';
        default:
          return 'Error ${statusCode ?? ''}: ${error.message}';
      }
    } else if (error.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout: Please check your internet';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return 'Request timeout: Server is taking too long';
    }
    return 'Network error: Please check your connection';
  }
}
