import 'package:equatable/equatable.dart';

class ApprovalState extends Equatable {
  final List<Map<String, dynamic>> pendingRequests;

  const ApprovalState({
    this.pendingRequests = const [],
  });

  @override
  List<Object?> get props => [pendingRequests];

  ApprovalState copyWith({
    List<Map<String, dynamic>>? pendingRequests,
  }) {
    return ApprovalState(
      pendingRequests: pendingRequests ?? this.pendingRequests,
    );
  }
}

