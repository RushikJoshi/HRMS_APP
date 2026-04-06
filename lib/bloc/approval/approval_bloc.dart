import 'package:flutter_bloc/flutter_bloc.dart';
import 'approval_event.dart';
import 'approval_state.dart';

class ApprovalBloc extends Bloc<ApprovalEvent, ApprovalState> {
  ApprovalBloc() : super(const ApprovalState()) {
    on<ApprovalLoadPending>(_onLoadPending);
    on<ApprovalDecisionMade>(_onDecisionMade);
    
    add(const ApprovalLoadPending());
  }

  void _onLoadPending(
    ApprovalLoadPending event,
    Emitter<ApprovalState> emit,
  ) {
    // Mock data - in real app, fetch from API
    final requests = [
      {
        'id': '1',
        'name': 'Sarah Jones',
        'type': 'Sick Leave',
        'dates': '24 Dec - 25 Dec',
        'reason': 'Viral fever, doctor advised rest.',
        'appliedBy': 'Self',
      },
      {
        'id': '2',
        'name': 'Mike Ross',
        'type': 'Casual Leave',
        'dates': '30 Dec',
        'reason': 'New Year preparation.',
        'appliedBy': 'Self',
      },
      {
        'id': '3',
        'name': 'Rachel Zane',
        'type': 'Privilege Leave',
        'dates': '01 Jan - 05 Jan',
        'reason': 'Family Vacation.',
        'appliedBy': 'Self',
      },
    ];

    emit(state.copyWith(pendingRequests: requests));
  }

  void _onDecisionMade(
    ApprovalDecisionMade event,
    Emitter<ApprovalState> emit,
  ) {
    final updatedRequests = state.pendingRequests
        .where((req) => req['id'] != event.requestId)
        .toList();
    emit(state.copyWith(pendingRequests: updatedRequests));
  }
}

