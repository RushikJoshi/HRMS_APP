import 'package:equatable/equatable.dart';
import '../../models/api/payslip.dart';

class PayslipState extends Equatable {
  final DateTime selectedMonth;
  final List<Payslip> payslips;
  final bool loading;
  final String? error;

  const PayslipState({
    required this.selectedMonth,
    this.payslips = const [],
    this.loading = false,
    this.error,
  });

  @override
  List<Object?> get props => [selectedMonth, payslips, loading, error];

  PayslipState copyWith({
    DateTime? selectedMonth,
    List<Payslip>? payslips,
    bool? loading,
    String? error,
  }) {
    return PayslipState(
      selectedMonth: selectedMonth ?? this.selectedMonth,
      payslips: payslips ?? this.payslips,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}
