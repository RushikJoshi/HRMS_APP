import 'package:flutter_bloc/flutter_bloc.dart';
import 'holiday_event.dart';
import 'holiday_state.dart';
import '../../api/api.dart';
import '../../models/api/holiday_response.dart';

class HolidayBloc extends Bloc<HolidayEvent, HolidayState> {
  final Api _api = Api();

  HolidayBloc() : super(HolidayState(focusedDay: DateTime.now())) {
    on<HolidayMonthChanged>(_onMonthChanged);
    on<HolidayPreviousMonth>(_onPreviousMonth);
    on<HolidayNextMonth>(_onNextMonth);
    on<HolidayLoad>(_onLoad);

    // Load holidays on creation
    add(const HolidayLoad());
  }

  void _onMonthChanged(HolidayMonthChanged event, Emitter<HolidayState> emit) {
    emit(state.copyWith(focusedDay: event.month));
  }

  void _onPreviousMonth(
    HolidayPreviousMonth event,
    Emitter<HolidayState> emit,
  ) {
    final newDate = DateTime(state.focusedDay.year, state.focusedDay.month - 1);
    emit(state.copyWith(focusedDay: newDate));
  }

  void _onNextMonth(HolidayNextMonth event, Emitter<HolidayState> emit) {
    final newDate = DateTime(state.focusedDay.year, state.focusedDay.month + 1);
    emit(state.copyWith(focusedDay: newDate));
  }

  Future<void> _onLoad(HolidayLoad event, Emitter<HolidayState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final List<Holiday> list = await _api.getHolidays();
      emit(state.copyWith(holidays: list, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
