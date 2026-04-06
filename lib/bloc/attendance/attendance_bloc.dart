import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';
import '../../api/api.dart';
import '../../services/punch_service.dart';
import '../../injection/injection.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  Timer? _workingTimer;
  Timer? _breakTimer;
  late PunchService _punchService;
  bool _isPunchServiceReady = false;

  final Api _api = Api();

  AttendanceBloc() : super(const AttendanceState()) {
    on<AttendanceInitRequested>(_onInitRequested);
    on<AttendancePunchInRequested>(_onPunchInRequested);
    on<AttendancePunchOutRequested>(_onPunchOutRequested);
    on<AttendanceTimerTick>(_onTimerTick);
    on<AttendanceBreakStarted>(_onBreakStarted);
    on<AttendanceBreakEnded>(_onBreakEnded);
    on<AttendanceBreakTimerTick>(_onBreakTimerTick);
    on<AttendanceReset>(_onReset);
    on<AttendanceHistoryRequested>(_onHistoryRequested);
    on<AttendanceSummaryRequested>(_onSummaryRequested);
    _initServices();
  }

  void _initServices() async {
    _punchService = PunchService();
    await _punchService.init();
    _isPunchServiceReady = true;
    add(const AttendanceInitRequested());
  }

  Future<void> _onInitRequested(
    AttendanceInitRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    final isPunched = _punchService.isAlreadyPunchedInToday();
    final punchTime = _punchService.getPunchInTime();

    if (isPunched && punchTime != null) {
      emit(
        state.copyWith(
          isPunchedIn: true,
          punchInTime: punchTime,
          isInitialized: true,
        ),
      );
      _startWorkingTimer();
    } else {
      emit(state.copyWith(isInitialized: true));
    }
  }

  Future<void> _onPunchInRequested(
    AttendancePunchInRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    if (_punchService.isAlreadyPunchedInToday()) {
      emit(
        state.copyWith(
          errorMessage:
              'Already punched in today. Can punch in only once per day.',
        ),
      );
      await Future.delayed(const Duration(seconds: 3));
      emit(state.copyWith(errorMessage: null));
      return;
    }

    try {
      await _api.punchAttendance('IN');
      final punchInTime = event.punchInTime;
      await _punchService.savePunchIn(punchInTime);

      emit(
        state.copyWith(
          isPunchedIn: true,
          punchInTime: punchInTime,
          totalWorkingSeconds: 0,
          errorMessage: null,
        ),
      );

      // Start timer after a small delay to ensure state is propagated
      await Future.delayed(const Duration(milliseconds: 100));
      _startWorkingTimer();
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Punch in failed: ${e.toString()}'));
      await Future.delayed(const Duration(seconds: 3));
      emit(state.copyWith(errorMessage: null));
    }
  }

  Future<void> _onPunchOutRequested(
    AttendancePunchOutRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      await _api.punchAttendance('OUT');

      if (state.isOnBreak) {
        _breakTimer?.cancel();
      }

      await _punchService.clearPunchIn();

      emit(
        state.copyWith(
          isPunchedIn: false,
          punchOutTime: event.punchOutTime,
          punchInTime: null,
          totalWorkingSeconds: 0,
          isOnBreak: false,
          currentBreakType: null,
          breakRemainingSeconds: 0,
          errorMessage: null,
        ),
      );

      _workingTimer?.cancel();
      _breakTimer?.cancel();
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Punch out failed: $e'));
      await Future.delayed(const Duration(seconds: 3));
      emit(state.copyWith(errorMessage: null));
    }
  }

  void _startWorkingTimer() {
    _workingTimer?.cancel();
    if (!state.isPunchedIn || state.punchInTime == null) return;

    _workingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.isPunchedIn || state.isOnBreak || state.punchInTime == null) {
        timer.cancel();
        return;
      }
      add(const AttendanceTimerTick());
    });
  }

  void _onTimerTick(AttendanceTimerTick event, Emitter<AttendanceState> emit) {
    if (state.isPunchedIn && !state.isOnBreak && state.punchInTime != null) {
      final elapsed = DateTime.now().difference(state.punchInTime!).inSeconds;
      emit(state.copyWith(totalWorkingSeconds: elapsed));
    }
  }

  void _onBreakStarted(
    AttendanceBreakStarted event,
    Emitter<AttendanceState> emit,
  ) {
    if (!state.isPunchedIn) return;
    if (event.breakType == 'Lunch' && state.lunchTakenToday) return;

    emit(
      state.copyWith(
        isOnBreak: true,
        currentBreakType: event.breakType,
        breakRemainingSeconds: event.durationMinutes * 60,
      ),
    );

    // Start break timer
    _breakTimer?.cancel();
    _breakTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(const AttendanceBreakTimerTick());
    });
  }

  void _onBreakEnded(
    AttendanceBreakEnded event,
    Emitter<AttendanceState> emit,
  ) {
    _breakTimer?.cancel();

    final lunchTaken = state.currentBreakType == 'Lunch'
        ? true
        : state.lunchTakenToday;

    emit(
      state.copyWith(
        isOnBreak: false,
        currentBreakType: null,
        breakRemainingSeconds: 0,
        lunchTakenToday: lunchTaken,
      ),
    );
  }

  void _onBreakTimerTick(
    AttendanceBreakTimerTick event,
    Emitter<AttendanceState> emit,
  ) {
    if (state.breakRemainingSeconds > 0) {
      emit(
        state.copyWith(breakRemainingSeconds: state.breakRemainingSeconds - 1),
      );
    } else {
      // Break finished automatically
      add(const AttendanceBreakEnded());
    }
  }

  void _onReset(AttendanceReset event, Emitter<AttendanceState> emit) {
    _workingTimer?.cancel();
    _breakTimer?.cancel();
    emit(const AttendanceState());
  }

  @override
  Future<void> close() {
    _workingTimer?.cancel();
    _breakTimer?.cancel();
    return super.close();
  }

  Future<void> _onHistoryRequested(
    AttendanceHistoryRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    final targetDate = DateTime(
      event.year ?? DateTime.now().year,
      event.month ?? DateTime.now().month,
    );
    emit(
      state.copyWith(isLoadingHistory: true, selectedHistoryDate: targetDate),
    );
    try {
      final response = await _api.getMyAttendance(
        month: event.month,
        year: event.year,
      );
      if (response.success || response.data != null) {
        emit(
          state.copyWith(
            isLoadingHistory: false,
            attendanceHistory: response.data ?? [],
          ),
        );
      } else {
        emit(
          state.copyWith(isLoadingHistory: false),
        ); // Handle error state if needed
      }
    } catch (e) {
      print('Error fetching attendance history: $e');
      emit(state.copyWith(isLoadingHistory: false));
    }
  }

  DateTime? _parseTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    try {
      final now = DateTime.now();
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final h = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        final s = parts.length > 2
            ? double.parse(parts[2]).toInt()
            : 0; // Handle partial seconds if any
        return DateTime(now.year, now.month, now.day, h, m, s);
      }
      return DateTime.tryParse(timeStr);
    } catch (_) {
      return null;
    }
  }

  Future<void> _onSummaryRequested(
    AttendanceSummaryRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(isLoadingSummary: true));
    try {
      final response = await _api.getAttendanceSummary();
      if (response.success || response.data != null) {
        final summary = response.data!;
        final inTime = _parseTime(summary.inTime);
        final outTime = _parseTime(summary.outTime);

        // Keep local persisted punch state as fallback when API summary is delayed.
        final localIsPunchedIn = _isPunchServiceReady
            ? _punchService.isAlreadyPunchedInToday()
            : false;
        final localPunchInTime = _isPunchServiceReady
            ? _punchService.getPunchInTime()
            : null;

        final effectivePunchInTime = inTime ?? localPunchInTime;
        final bool isPunchedIn =
            outTime == null && (inTime != null || localIsPunchedIn);

        int workingSeconds = state.totalWorkingSeconds;
        if (isPunchedIn && effectivePunchInTime != null) {
          workingSeconds = DateTime.now()
              .difference(effectivePunchInTime)
              .inSeconds;
        }

        emit(
          state.copyWith(
            isLoadingSummary: false,
            attendanceSummary: summary,
            isPunchedIn: isPunchedIn,
            punchInTime: effectivePunchInTime,
            punchOutTime: outTime,
            totalWorkingSeconds: workingSeconds > 0 ? workingSeconds : 0,
          ),
        );

        // Start timer if punched in and timer not running
        if (isPunchedIn && _workingTimer == null) {
          _workingTimer?.cancel();
          _workingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
            if (!state.isPunchedIn || state.isOnBreak) return;
            add(const AttendanceTimerTick());
          });
        } else if (!isPunchedIn) {
          _workingTimer?.cancel();
          _workingTimer = null;
        }
      } else {
        emit(state.copyWith(isLoadingSummary: false));
      }
    } catch (e) {
      print('Error fetching attendance summary: $e');
      emit(state.copyWith(isLoadingSummary: false));
    }
  }
}
