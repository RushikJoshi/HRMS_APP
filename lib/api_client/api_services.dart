import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/api/login_request.dart';
import '../models/api/login_response.dart';
import '../models/api/profile_response.dart';

import '../models/api/circular_response.dart';
import '../models/api/payslip.dart';
import '../models/api/attendance/attendance_punch_request.dart';
import '../models/api/attendance/face_image_request.dart';
import '../models/api/holiday_response.dart';
import '../models/api/leave/apply_leave_request.dart';
import '../models/api/leave/leave_dto.dart';
import '../models/api/leave/leave_balance_response.dart';
import '../models/api/attendance/attendance_history_response.dart';
import '../models/api/attendance/attendance_summary_response.dart';

part 'api_services.g.dart';

@RestApi(baseUrl: "https://hrms.dev.gitakshmi.com/api")
abstract class ApiServices {
  factory ApiServices(Dio dio, {String baseUrl}) = _ApiServices;

  // ==================== AUTH ====================
  @POST("/auth/login-employee")
  Future<LoginResponse> loginEmployee(@Body() LoginRequest request);

  // ==================== EMPLOYEE PROFILE ====================
  @GET("/employee/profile")
  Future<ProfileResponse> getEmployeeProfile();

  @GET("/notifications")
  Future<CircularResponse> getNotifications();

  @GET("/employee/payslips")
  Future<List<Payslip>> getPayslips();

  @GET("/holidays")
  Future<List<Holiday>> getHolidays();

  // ==================== LEAVE MANAGEMENT ====================

  // ✅ 1. Apply Leave
  @POST("/employee/leaves/apply")
  Future<void> applyLeave(@Body() Map<String, dynamic> request);

  // 📊 2. Get My Leave Balance
  @GET("/employee/leaves/balance")
  Future<LeaveBalancesResponse> getLeaveBalance();

  // 📋 3. Get My Leaves
  @GET("/employee/leaves/history")
  Future<List<LeaveDto>> getMyLeaves({
    @Query("page") int? page,
    @Query("limit") int? limit,
  });

  // 👥 4. Get Team Leaves (Manager/Team Lead)
  @GET("/employee/leaves/team")
  Future<List<LeaveDto>> getTeamLeaves({
    @Query("page") int? page,
    @Query("limit") int? limit,
  });

  // 🏢 5. Get All Leaves (Admin/HR)
  @GET("/employee/leaves/all")
  Future<List<LeaveDto>> getAllLeaves({
    @Query("page") int? page,
    @Query("limit") int? limit,
  });

  // ✅ 6. Approve Leave
  @PUT("/employee/leaves/approve/{leaveId}")
  Future<void> approveLeave(
    @Path("leaveId") String leaveId,
    @Body() Map<String, dynamic> request,
  );

  // ❌ 7. Reject Leave
  @PUT("/employee/leaves/reject/{leaveId}")
  Future<void> rejectLeave(
    @Path("leaveId") String leaveId,
    @Body() Map<String, dynamic> request,
  );

  // ✏️ 8. Edit Leave
  @PUT("/employee/leaves/edit/{leaveId}")
  Future<void> editLeave(
    @Path("leaveId") String leaveId,
    @Body() Map<String, dynamic> request,
  );

  // 🚫 9. Cancel Leave
  @PUT("/employee/leaves/cancel/{leaveId}")
  Future<void> cancelLeave(@Path("leaveId") String leaveId);

  // 📅 10. Get Approved Dates
  @GET("/employee/leaves/approved-dates")
  Future<void> getApprovedDates();

  // ==================== ATTENDANCE & FACE ====================
  @POST("/attendance/punch")
  Future<void> punchAttendance(@Body() AttendancePunchRequest request);

  @POST("/attendance/validate-location")
  Future<void> validateAttendanceLocation(@Body() Map<String, dynamic> request);

  @POST("/attendance/register-face")
  Future<void> registerFace(@Body() FaceImageRequest request);

  @POST("/attendance/verify-face")
  Future<void> verifyFace(@Body() FaceImageRequest request);

  @GET("/attendance/face-status")
  Future<void> getFaceStatus();

  // ==================== ATTENDANCE HISTORY ====================
  @GET("/attendance/my")
  Future<AttendanceHistoryResponse> getMyAttendanceHistory({
    @Query("month") int? month,
    @Query("year") int? year,
  });

  @GET("/attendance/today-summary")
  Future<AttendanceSummaryResponse> getAttendanceSummary();
}
