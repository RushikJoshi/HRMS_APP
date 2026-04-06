import 'package:equatable/equatable.dart';

abstract class PayslipEvent extends Equatable {
  const PayslipEvent();

  @override
  List<Object?> get props => [];
}

class PayslipMonthChanged extends PayslipEvent {
  final DateTime month;

  const PayslipMonthChanged(this.month);

  @override
  List<Object?> get props => [month];
}

class PayslipLoad extends PayslipEvent {
  const PayslipLoad();
}
