import 'package:equatable/equatable.dart';

abstract class CircularEvent extends Equatable {
  const CircularEvent();

  @override
  List<Object?> get props => [];
}

class CircularLoad extends CircularEvent {
  const CircularLoad();
}

class CircularSearchChanged extends CircularEvent {
  final String searchQuery;

  const CircularSearchChanged(this.searchQuery);

  @override
  List<Object?> get props => [searchQuery];
}

class CircularCategoryFilterChanged extends CircularEvent {
  final String? category;

  const CircularCategoryFilterChanged(this.category);

  @override
  List<Object?> get props => [category];
}

class CircularMarkAsRead extends CircularEvent {
  final String circularId;

  const CircularMarkAsRead(this.circularId);

  @override
  List<Object?> get props => [circularId];
}

