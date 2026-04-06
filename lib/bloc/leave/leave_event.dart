import 'package:equatable/equatable.dart';
import '../../models/leave/leave_request_model.dart';
import '../../models/api/leave/override_leave_request.dart';

abstract class LeaveEvent extends Equatable {
  const LeaveEvent();

  @override
  List<Object?> get props => [];
}

class LeaveLoadBalances extends LeaveEvent {
  const LeaveLoadBalances();
}

class LeaveLoadHistory extends LeaveEvent {
  const LeaveLoadHistory();
}

class LeaveApplied extends LeaveEvent {
  final LeaveRequest leaveRequest;

  const LeaveApplied(this.leaveRequest);

  @override
  List<Object?> get props => [leaveRequest];
}

class LeaveDeleted extends LeaveEvent {
  final String leaveId;

  const LeaveDeleted(this.leaveId);

  @override
  List<Object?> get props => [leaveId];
}

class LeaveLoadTeamRequests extends LeaveEvent {
  const LeaveLoadTeamRequests();
}

class LeaveLoadAllLeaves extends LeaveEvent {
  const LeaveLoadAllLeaves();
}

class LeaveApproveRequest extends LeaveEvent {
  final String leaveId;
  final String remark;
  const LeaveApproveRequest(this.leaveId, this.remark);
  @override
  List<Object?> get props => [leaveId, remark];
}

class LeaveRejectRequest extends LeaveEvent {
  final String leaveId;
  final String remark;
  const LeaveRejectRequest(this.leaveId, this.remark);
  @override
  List<Object?> get props => [leaveId, remark];
}

class LeaveCancelRequest extends LeaveEvent {
  final String leaveId;
  const LeaveCancelRequest(this.leaveId);
  @override
  List<Object?> get props => [leaveId];
}

class LeaveOverrideRequest extends LeaveEvent {
  final OverrideLeaveRequest request;
  const LeaveOverrideRequest(this.request);
  @override
  List<Object?> get props => [request];
}

class LeaveLoadLeavesByDate extends LeaveEvent {
  final DateTime date;
  const LeaveLoadLeavesByDate(this.date);
  @override
  List<Object?> get props => [date];
}

