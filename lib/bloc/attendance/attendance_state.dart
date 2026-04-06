import 'package:equatable/equatable.dart';

import '../../models/api/attendance/attendance_log.dart';
import '../../models/api/attendance/attendance_summary.dart';

class AttendanceState extends Equatable {
  final bool isPunchedIn;
  final DateTime? punchInTime;
  final DateTime? punchOutTime;
  final int totalWorkingSeconds;
  final bool isOnBreak;
  final String? currentBreakType;
  final int breakRemainingSeconds;
  final bool lunchTakenToday;
  final String? errorMessage;
  final bool isInitialized;

  final List<AttendanceLog>? attendanceHistory;
  final AttendanceSummary? attendanceSummary;
  final bool isLoadingHistory;
  final bool isLoadingSummary;
  final DateTime? selectedHistoryDate;

  const AttendanceState({
    this.isPunchedIn = false,
    this.punchInTime,
    this.punchOutTime,
    this.totalWorkingSeconds = 0,
    this.isOnBreak = false,
    this.currentBreakType,
    this.breakRemainingSeconds = 0,
    this.lunchTakenToday = false,
    this.errorMessage,
    this.isInitialized = false,
    this.attendanceHistory,
    this.attendanceSummary,
    this.isLoadingHistory = false,
    this.isLoadingSummary = false,
    this.selectedHistoryDate,
  });

  @override
  List<Object?> get props => [
    isPunchedIn,
    punchInTime,
    punchOutTime,
    totalWorkingSeconds,
    isOnBreak,
    currentBreakType,
    breakRemainingSeconds,
    lunchTakenToday,
    errorMessage,
    isInitialized,
    attendanceHistory,
    attendanceSummary,
    isLoadingHistory,
    isLoadingSummary,
    selectedHistoryDate,
  ];

  AttendanceState copyWith({
    bool? isPunchedIn,
    DateTime? punchInTime,
    DateTime? punchOutTime,
    int? totalWorkingSeconds,
    bool? isOnBreak,
    String? currentBreakType,
    int? breakRemainingSeconds,
    bool? lunchTakenToday,
    String? errorMessage,
    bool? isInitialized,
    List<AttendanceLog>? attendanceHistory,
    AttendanceSummary? attendanceSummary,
    bool? isLoadingHistory,
    bool? isLoadingSummary,
    DateTime? selectedHistoryDate,
  }) {
    return AttendanceState(
      isPunchedIn: isPunchedIn ?? this.isPunchedIn,
      punchInTime: punchInTime ?? this.punchInTime,
      punchOutTime: punchOutTime ?? this.punchOutTime,
      totalWorkingSeconds: totalWorkingSeconds ?? this.totalWorkingSeconds,
      isOnBreak: isOnBreak ?? this.isOnBreak,
      currentBreakType: currentBreakType ?? this.currentBreakType,
      breakRemainingSeconds:
          breakRemainingSeconds ?? this.breakRemainingSeconds,
      lunchTakenToday: lunchTakenToday ?? this.lunchTakenToday,
      errorMessage: errorMessage,
      isInitialized: isInitialized ?? this.isInitialized,
      attendanceHistory: attendanceHistory ?? this.attendanceHistory,
      attendanceSummary: attendanceSummary ?? this.attendanceSummary,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      isLoadingSummary: isLoadingSummary ?? this.isLoadingSummary,
      selectedHistoryDate: selectedHistoryDate ?? this.selectedHistoryDate,
    );
  }
}
