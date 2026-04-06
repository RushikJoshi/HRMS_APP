import 'package:equatable/equatable.dart';

abstract class MyTeamEvent extends Equatable {
  const MyTeamEvent();

  @override
  List<Object?> get props => [];
}

class MyTeamFilterChanged extends MyTeamEvent {
  final String filter;

  const MyTeamFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

class MyTeamLoadRequested extends MyTeamEvent {
  const MyTeamLoadRequested();
}

