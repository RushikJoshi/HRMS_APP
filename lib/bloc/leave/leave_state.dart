import 'package:equatable/equatable.dart';
import '../../models/leave/leave_request_model.dart';
import '../../models/api/leave/leave_balance_response.dart';

class LeaveState extends Equatable {
  final List<LeaveBalance> leaveBalances;
  final List<LeaveRequest> leaveRequests;
  final List<LeaveRequest> teamRequests;
  final List<LeaveRequest> allLeaves;
  final bool isLoading;
  final String? errorMessage;

  const LeaveState({
    this.leaveBalances = const [],
    this.leaveRequests = const [],
    this.teamRequests = const [],
    this.allLeaves = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [leaveBalances, leaveRequests, teamRequests, allLeaves, isLoading, errorMessage];

  LeaveState copyWith({
    List<LeaveBalance>? leaveBalances,
    List<LeaveRequest>? leaveRequests,
    List<LeaveRequest>? teamRequests,
    List<LeaveRequest>? allLeaves,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LeaveState(
      leaveBalances: leaveBalances ?? this.leaveBalances,
      leaveRequests: leaveRequests ?? this.leaveRequests,
      teamRequests: teamRequests ?? this.teamRequests,
      allLeaves: allLeaves ?? this.allLeaves,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

