import 'package:flutter_bloc/flutter_bloc.dart';
import 'delegation_event.dart';
import 'delegation_state.dart';

class DelegationBloc extends Bloc<DelegationEvent, DelegationState> {
  DelegationBloc() : super(const DelegationState()) {
    on<DelegationEmployeeSelected>(_onEmployeeSelected);
    on<DelegationFromDateChanged>(_onFromDateChanged);
    on<DelegationToDateChanged>(_onToDateChanged);
    on<DelegationReasonChanged>(_onReasonChanged);
    on<DelegationSubmitted>(_onSubmitted);
  }

  void _onEmployeeSelected(
    DelegationEmployeeSelected event,
    Emitter<DelegationState> emit,
  ) {
    emit(state.copyWith(selectedEmployee: event.employeeId));
  }

  void _onFromDateChanged(
    DelegationFromDateChanged event,
    Emitter<DelegationState> emit,
  ) {
    emit(state.copyWith(fromDate: event.fromDate));
  }

  void _onToDateChanged(
    DelegationToDateChanged event,
    Emitter<DelegationState> emit,
  ) {
    emit(state.copyWith(toDate: event.toDate));
  }

  void _onReasonChanged(
    DelegationReasonChanged event,
    Emitter<DelegationState> emit,
  ) {
    emit(state.copyWith(reason: event.reason));
  }

  Future<void> _onSubmitted(
    DelegationSubmitted event,
    Emitter<DelegationState> emit,
  ) async {
    if (state.fromDate == null || state.toDate == null) {
      emit(state.copyWith(errorMessage: 'Please select valid From and To dates'));
      return;
    }

    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(state.copyWith(isSubmitting: false));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      ));
    }
  }
}

