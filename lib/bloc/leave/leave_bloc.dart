import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/leave/leave_request_model.dart';
import '../../models/api/leave/override_leave_request.dart';
import 'leave_event.dart';
import 'leave_state.dart';
import '../../api/api.dart';
import '../../services/leave_service.dart';
import '../../injection/injection.dart';
import '../../models/api/leave/leave_dto.dart';
import '../../models/api/leave/leave_balance_response.dart';

class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  final LeaveService _leaveService = LeaveService(apiServices: apiServices);

  static List<LeaveBalance> demoBalances = [];

  LeaveBloc() : super(const LeaveState()) {
    on<LeaveLoadBalances>(_onLoadBalances);
    on<LeaveLoadHistory>(_onLoadHistory);
    on<LeaveApplied>(_onLeaveApplied);
    on<LeaveDeleted>(_onLeaveDeleted);
    on<LeaveLoadTeamRequests>(_onLoadTeamRequests);
    on<LeaveLoadAllLeaves>(_onLoadAllLeaves);
    on<LeaveApproveRequest>(_onApproveRequest);
    on<LeaveRejectRequest>(_onRejectRequest);
    on<LeaveCancelRequest>(_onCancelRequest);
    on<LeaveOverrideRequest>(_onLeaveOverride);
    on<LeaveLoadLeavesByDate>(_onLoadLeavesByDate);

    // Load initial data
    add(const LeaveLoadBalances());
    add(const LeaveLoadHistory());
  }

  Future<void> _onLoadBalances(
    LeaveLoadBalances event,
    Emitter<LeaveState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      print('📊 Loading leave balances...');
      final response = await _leaveService.getLeaveBalance();
      final balancesList = response.balances;
      print(
        '✅ Leave balances loaded successfully: ${balancesList.length} balances',
      );
      for (var balance in balancesList) {
        print(
          '  - ${balance.leaveType}: ${balance.balance} available, ${balance.taken} taken, ${balance.entitled} entitled',
        );
      }
      emit(state.copyWith(leaveBalances: balancesList, isLoading: false));
    } catch (e, stackTrace) {
      print('❌ Error loading leave balances: $e');
      print('Stack trace: $stackTrace');
      emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
    }
  }

  Future<void> _onLoadHistory(
    LeaveLoadHistory event,
    Emitter<LeaveState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      print('📜 Loading leave history...');
      final leaveDtos = await _leaveService.getMyLeaves();
      print('✅ Leave history loaded: ${leaveDtos.length} requests');
      final requests = leaveDtos.map((dto) => _mapDtoToRequest(dto)).toList();
      emit(state.copyWith(leaveRequests: requests, isLoading: false));
    } catch (e, stackTrace) {
      print('❌ Error loading leave history: $e');
      print('Stack trace: $stackTrace');
      emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
    }
  }

  LeaveRequest _mapDtoToRequest(LeaveDto dto) {
    String? appliedBy = dto.employee != null ? dto.employee!['name'] : null;
    return LeaveRequest(
      id: dto.id ?? '',
      type: LeaveType.fromString(dto.leaveType ?? ''),
      fromDate: DateTime.tryParse(dto.startDate ?? '') ?? DateTime.now(),
      toDate: DateTime.tryParse(dto.endDate ?? '') ?? DateTime.now(),
      reason: dto.reason ?? '',
      status: LeaveStatus.fromString(dto.status ?? 'Pending'),
      appliedDate: DateTime.tryParse(dto.appliedDate ?? ''),
      locationType: 'In-Land',
      appliedBy: appliedBy,
    );
  }

  Future<void> _onLoadTeamRequests(
    LeaveLoadTeamRequests event,
    Emitter<LeaveState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final dtos = await _leaveService.getTeamLeaves();
      final requests = dtos.map((dto) => _mapDtoToRequest(dto)).toList();
      emit(state.copyWith(teamRequests: requests, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadAllLeaves(
    LeaveLoadAllLeaves event,
    Emitter<LeaveState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final dtos = await _leaveService.getAllLeaves();
      final requests = dtos.map((dto) => _mapDtoToRequest(dto)).toList();
      emit(state.copyWith(allLeaves: requests, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onApproveRequest(
    LeaveApproveRequest event,
    Emitter<LeaveState> emit,
  ) async {
    try {
      await _leaveService.approveLeave(
        leaveId: event.leaveId,
        remark: event.remark,
      );
      add(const LeaveLoadTeamRequests());
      add(const LeaveLoadAllLeaves());
      add(const LeaveLoadHistory());
      add(const LeaveLoadBalances());
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onRejectRequest(
    LeaveRejectRequest event,
    Emitter<LeaveState> emit,
  ) async {
    try {
      await _leaveService.rejectLeave(
        leaveId: event.leaveId,
        rejectionReason: event.remark,
      );
      add(const LeaveLoadTeamRequests());
      add(const LeaveLoadAllLeaves());
      add(const LeaveLoadHistory());
      add(const LeaveLoadBalances());
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onCancelRequest(
    LeaveCancelRequest event,
    Emitter<LeaveState> emit,
  ) async {
    try {
      await _leaveService.cancelLeave(leaveId: event.leaveId);
      add(const LeaveLoadHistory());
      add(const LeaveLoadBalances());
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onLeaveOverride(
    LeaveOverrideRequest event,
    Emitter<LeaveState> emit,
  ) async {
    // No dedicated override endpoint in new API – keep as not supported
    emit(
      state.copyWith(
        errorMessage: 'Override functionality not available',
        isLoading: false,
      ),
    );
  }

  Future<void> _onLoadLeavesByDate(
    LeaveLoadLeavesByDate event,
    Emitter<LeaveState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final dtos = await _leaveService.getAllLeaves();
      final target = event.date.toIso8601String().split('T')[0];
      final filtered = dtos
          .where((dto) => (dto.startDate ?? '').startsWith(target))
          .toList();
      final requests = filtered.map((dto) => _mapDtoToRequest(dto)).toList();
      emit(state.copyWith(allLeaves: requests, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onLeaveApplied(LeaveApplied event, Emitter<LeaveState> emit) {
    final updatedRequests = [event.leaveRequest, ...state.leaveRequests];
    emit(state.copyWith(leaveRequests: updatedRequests));
    // Refresh balance after applying leave
    add(const LeaveLoadBalances());
  }

  void _onLeaveDeleted(LeaveDeleted event, Emitter<LeaveState> emit) {
    final updatedRequests = state.leaveRequests
        .where((request) => request.id != event.leaveId)
        .toList();
    emit(state.copyWith(leaveRequests: updatedRequests));
    // Refresh balance after deleting leave
    add(const LeaveLoadBalances());
  }
}
