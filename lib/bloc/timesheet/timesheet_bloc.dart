import 'package:flutter_bloc/flutter_bloc.dart';
import 'timesheet_event.dart';
import 'timesheet_state.dart';

class TimesheetBloc extends Bloc<TimesheetEvent, TimesheetState> {
  TimesheetBloc() : super(TimesheetState(selectedMonth: DateTime.now())) {
    on<TimesheetMonthChanged>(_onMonthChanged);
  }

  void _onMonthChanged(
    TimesheetMonthChanged event,
    Emitter<TimesheetState> emit,
  ) {
    emit(state.copyWith(selectedMonth: DateTime(event.month.year, event.month.month)));
  }
}

