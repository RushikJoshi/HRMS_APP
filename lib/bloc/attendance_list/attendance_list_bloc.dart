import 'package:flutter_bloc/flutter_bloc.dart';
import 'attendance_list_event.dart';
import 'attendance_list_state.dart';

class AttendanceListBloc extends Bloc<AttendanceListEvent, AttendanceListState> {
  AttendanceListBloc() : super(AttendanceListState(selectedMonth: DateTime.now())) {
    on<AttendanceListMonthChanged>((event, emit) {
      emit(state.copyWith(selectedMonth: event.month));
    });
  }
}
