import 'package:dio/dio.dart';
import '../api_client/api_services.dart';

import '../injection/injection.dart';
import '../models/api/login_request.dart';
import '../models/api/login_response.dart';
import '../models/api/profile_response.dart';
import '../models/api/circular_response.dart';
import '../models/api/holiday_response.dart';
import '../models/api/payslip.dart';
import '../models/api/leave/leave_dto.dart';
import '../models/api/leave/leave_balance_response.dart';
import '../models/api/attendance/attendance_punch_request.dart';
import '../models/api/attendance/face_image_request.dart';
import '../models/api/attendance/attendance_history_response.dart';
import '../models/api/attendance/attendance_summary_response.dart';
import '../models/api/attendance/regularization.dart';
import '../services/face_service.dart';
import '../services/storage_service.dart';

class Api {
  final ApiServices _services = apiServices;

  bool _shouldUseLocalFaceFallback(DioException error) {
    final statusCode = error.response?.statusCode;
    return statusCode == 500 ||
        statusCode == 502 ||
        statusCode == 503 ||
        statusCode == 504;
  }

  bool _isRegisteredFaceStatus(dynamic response) {
    return response is Map &&
        (response['registered'] == true || response['status'] == 'Registered');
  }

  Future<Map<String, dynamic>?> _getLocalFaceStatus({
    String? employeeId,
    String? companyCode,
  }) async {
    final hasLocalRegistration = await StorageService.hasLocalFaceRegistration(
      employeeId: employeeId,
      companyCode: companyCode,
    );

    if (!hasLocalRegistration) {
      return null;
    }

    return {'registered': true, 'status': 'Registered', 'source': 'local'};
  }

  Future<LoginResponse> loginEmployee({
    required String companyCode,
    required String employeeId,
    required String password,
  }) async {
    try {
      final request = LoginRequest(
        companyCode: companyCode,
        employeeId: employeeId,
        password: password,
      );
      return await _services.loginEmployee(request);
    } catch (e) {
      // Re-throw or handle error formatting here if needed
      rethrow;
    }
  }

  Future<ProfileResponse> getEmployeeProfile() async {
    try {
      return await _services.getEmployeeProfile();
    } catch (e) {
      // Re-throw or handle error formatting here if needed
      rethrow;
    }
  }

  // Pseudo-Refresh Token Logic (Verification)
  Future<ProfileResponse> refreshToken() async {
    return await getEmployeeProfile();
  }

  Future<CircularResponse> getNotifications() async {
    try {
      return await _services.getNotifications();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Holiday>> getHolidays() async {
    try {
      return await _services.getHolidays();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Payslip>> getPayslips() async {
    try {
      return await _services.getPayslips();
    } catch (e) {
      rethrow;
    }
  }

  // ==================== LEAVE APIs ====================
  // EMPLOYEE: Get My Leave Balances
  Future<LeaveBalancesResponse> getLeaveBalances() async {
    try {
      return await _services.getLeaveBalance();
    } catch (e) {
      rethrow;
    }
  }

  // EMPLOYEE: Apply Leave
  Future<dynamic> applyLeave({
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    bool isHalfDay = false,
    String? halfDayTarget,
    String? halfDaySession,
    String? employeeId,
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
      return await _services.applyLeave(body);
    } catch (e) {
      rethrow;
    }
  }

  // EMPLOYEE: Get My Leaves
  Future<List<LeaveDto>> getMyLeaves({int page = 1, int limit = 10}) async {
    try {
      return await _services.getMyLeaves(page: page, limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  // EMPLOYEE: Edit Leave
  Future<dynamic> editLeave({
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
      return await _services.editLeave(leaveId, body);
    } catch (e) {
      rethrow;
    }
  }

  // EMPLOYEE: Cancel Leave
  Future<dynamic> cancelLeave({required String leaveId}) async {
    try {
      return await _services.cancelLeave(leaveId);
    } catch (e) {
      rethrow;
    }
  }

  // EMPLOYEE: Get Approved Dates (Calendar)
  Future<dynamic> getApprovedDates() async {
    try {
      return await _services.getApprovedDates();
    } catch (e) {
      rethrow;
    }
  }

  // MANAGER: Get Team Leaves
  Future<List<LeaveDto>> getTeamLeaves({int page = 1, int limit = 10}) async {
    try {
      return await _services.getTeamLeaves(page: page, limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  // MANAGER/HR/ADMIN: Approve Leave
  Future<dynamic> approveLeave({
    required String leaveId,
    String? remark,
  }) async {
    try {
      final body = <String, dynamic>{
        if (remark != null && remark.isNotEmpty) 'remark': remark,
      };
      return await _services.approveLeave(leaveId, body);
    } catch (e) {
      rethrow;
    }
  }

  // MANAGER/HR/ADMIN: Reject Leave
  Future<dynamic> rejectLeave({
    required String leaveId,
    required String rejectionReason,
  }) async {
    try {
      final body = <String, dynamic>{'rejectionReason': rejectionReason};
      return await _services.rejectLeave(leaveId, body);
    } catch (e) {
      rethrow;
    }
  }

  // HR/ADMIN: Get All Leaves
  Future<List<LeaveDto>> getAllLeaves({int page = 1, int limit = 10}) async {
    try {
      return await _services.getAllLeaves(page: page, limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  // Attendance & Face
  Future<void> punchAttendance(String action) async {
    try {
      final request = AttendancePunchRequest(
        method: 'MANUAL',
        action: action, // "IN" or "OUT"
      );
      await _services.punchAttendance(request);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> validateAttendanceLocation(
    double lat,
    double lng,
    double accuracy,
  ) async {
    try {
      final payload = {
        'isFaceVerified': true,
        'location': {'lat': lat, 'lng': lng, 'accuracy': accuracy},
        'device': 'Mobile App',
      };
      await _services.validateAttendanceLocation(payload);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> registerFace(
    List<double> embedding, {
    String employeeName = 'Employee',
    String? image,
  }) async {
    final employeeId = await StorageService.getEmployeeId();
    final companyCode = await StorageService.getCompanyCode();
    final sanitizedImage = (image != null && image.isNotEmpty) ? image : null;
    final payloads = <Map<String, dynamic>>[
      {
        if (employeeId != null && employeeId.isNotEmpty)
          'employeeId': employeeId,
        if (companyCode != null && companyCode.isNotEmpty)
          'companyCode': companyCode,
        'faceEmbedding': embedding,
        if (sanitizedImage != null) 'image': sanitizedImage,
      },
      {
        if (employeeId != null && employeeId.isNotEmpty)
          'employeeId': employeeId,
        if (companyCode != null && companyCode.isNotEmpty)
          'companyCode': companyCode,
        'faceEmbedding': embedding,
        if (sanitizedImage != null) 'image': sanitizedImage,
        'employeeName': employeeName,
      },
      {
        if (employeeId != null && employeeId.isNotEmpty)
          'employeeId': employeeId,
        if (companyCode != null && companyCode.isNotEmpty)
          'companyCode': companyCode,
        'faceEmbedding': embedding,
        if (sanitizedImage != null) 'image': sanitizedImage,
        'consentGiven': true,
        'registrationNotes': 'Initial face registration',
        'employeeName': employeeName,
      },
    ];

    DioException? lastError;

    for (final payload in payloads) {
      try {
        print(
          'Face Registration Payload Keys: ${payload.keys.toList()} | '
          'imageLength: ${sanitizedImage?.length ?? 0}',
        );
        await dio.post('/attendance/register-face', data: payload);
        await StorageService.saveLocalFaceRegistration(
          embedding: embedding,
          employeeId: employeeId,
          companyCode: companyCode,
        );
        return;
      } on DioException catch (e) {
        lastError = e;
        final statusCode = e.response?.statusCode;

        // Retry only when the server rejects our payload shape.
        if (statusCode != 500 &&
            statusCode != 400 &&
            statusCode != 415 &&
            statusCode != 502 &&
            statusCode != 503 &&
            statusCode != 504) {
          rethrow;
        }
      }
    }

    if (lastError != null) {
      if (_shouldUseLocalFaceFallback(lastError)) {
        print(
          'Face registration endpoint unavailable. Saving face locally '
          'for device fallback.',
        );
        await StorageService.saveLocalFaceRegistration(
          embedding: embedding,
          employeeId: employeeId,
          companyCode: companyCode,
        );
        return;
      }
      throw lastError;
    }
  }

  Future<void> verifyFace(
    String location, {
    List<double>? embedding,
    String? base64Image,
    String? actionType,
  }) async {
    try {
      // Backend expects structured location, not a plain string.
      Map<String, dynamic>? locationPayload;
      final parts = location.split(',');
      if (parts.length == 2) {
        final lat = double.tryParse(parts[0]);
        final lng = double.tryParse(parts[1]);
        if (lat != null && lng != null) {
          locationPayload = {'lat': lat, 'lng': lng};
        }
      }

      final request = FaceImageRequest(
        embedding: embedding,
        image: (base64Image != null && base64Image.isNotEmpty)
            ? base64Image
            : null,
        location: locationPayload,
        actionType: actionType,
      );
      await _services.verifyFace(request);
    } on DioException catch (e) {
      if (!_shouldUseLocalFaceFallback(e) ||
          embedding == null ||
          embedding.isEmpty ||
          actionType == null ||
          actionType.isEmpty) {
        rethrow;
      }

      final employeeId = await StorageService.getEmployeeId();
      final companyCode = await StorageService.getCompanyCode();
      final localEmbedding = await StorageService.getLocalFaceEmbedding(
        employeeId: employeeId,
        companyCode: companyCode,
      );

      if (localEmbedding == null || localEmbedding.isEmpty) {
        rethrow;
      }

      final similarity = FaceService.compareEmbeddings(
        localEmbedding,
        embedding,
      );
      print(
        'Face verify endpoint unavailable. '
        'Local face similarity: ${similarity.toStringAsFixed(4)}',
      );

      if (!FaceService.isFaceMatch(localEmbedding, embedding)) {
        throw Exception(
          'Face mismatch. Please re-register your face on this device.',
        );
      }

      await punchAttendance(actionType);
    } catch (e) {
      rethrow;
    }
  }

  Future<AttendanceHistoryResponse> getMyAttendance({
    int? month,
    int? year,
  }) async {
    try {
      return await _services.getMyAttendanceHistory(month: month, year: year);
    } catch (e) {
      rethrow;
    }
  }

  Future<AttendanceSummaryResponse> getAttendanceSummary() async {
    try {
      return await _services.getAttendanceSummary();
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getFaceStatus() async {
    final employeeId = await StorageService.getEmployeeId();
    final companyCode = await StorageService.getCompanyCode();
    final localFaceStatus = await _getLocalFaceStatus(
      employeeId: employeeId,
      companyCode: companyCode,
    );

    try {
      final queryParameters = <String, dynamic>{
        if (employeeId != null && employeeId.isNotEmpty)
          'employeeId': employeeId,
        if (companyCode != null && companyCode.isNotEmpty)
          'companyCode': companyCode,
      };

      final response = await dio.get(
        '/attendance/face-status',
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );
      if (_isRegisteredFaceStatus(response.data)) {
        return response.data;
      }
      return localFaceStatus ?? response.data;
    } on DioException catch (e) {
      if (_shouldUseLocalFaceFallback(e)) {
        return localFaceStatus ?? {'registered': false, 'status': 'Unknown'};
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // Regularization APIs
  Future<void> submitRegularization(RegularizationRequest request) async {
    try {
      await dio.post('/attendance/regularization', data: request.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<RegularizationResponse> getMyRegularizations({
    int? month,
    int? year,
  }) async {
    try {
      final response = await dio.get(
        '/attendance/regularization',
        queryParameters: {
          if (month != null) 'month': month,
          if (year != null) 'year': year,
        },
      );
      return RegularizationResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
