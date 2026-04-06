import 'package:flutter_bloc/flutter_bloc.dart';
import '../../api/api.dart';
import '../../models/api/payslip.dart';
import 'payslip_event.dart';
import 'payslip_state.dart';

class PayslipBloc extends Bloc<PayslipEvent, PayslipState> {
  final Api _api = Api();

  PayslipBloc() : super(PayslipState(selectedMonth: DateTime.now())) {
    on<PayslipMonthChanged>(_onMonthChanged);
    on<PayslipLoad>(_onLoad);

    // Load initial payslips
    add(const PayslipLoad());
  }

  void _onMonthChanged(PayslipMonthChanged event, Emitter<PayslipState> emit) {
    final newMonth = DateTime(event.month.year, event.month.month);
    emit(state.copyWith(selectedMonth: newMonth));
    // Fetch payslips for new month
    add(const PayslipLoad());
  }

  Future<void> _onLoad(PayslipLoad event, Emitter<PayslipState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final List<Payslip> list = await _api.getPayslips();
      emit(state.copyWith(payslips: list, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
