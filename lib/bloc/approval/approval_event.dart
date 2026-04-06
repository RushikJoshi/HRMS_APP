import 'package:equatable/equatable.dart';

abstract class ApprovalEvent extends Equatable {
  const ApprovalEvent();

  @override
  List<Object?> get props => [];
}

class ApprovalLoadPending extends ApprovalEvent {
  const ApprovalLoadPending();
}

class ApprovalDecisionMade extends ApprovalEvent {
  final String requestId;
  final bool approved;

  const ApprovalDecisionMade({
    required this.requestId,
    required this.approved,
  });

  @override
  List<Object?> get props => [requestId, approved];
}

