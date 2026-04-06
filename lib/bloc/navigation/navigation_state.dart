import 'package:equatable/equatable.dart';

class NavigationState extends Equatable {
  final int selectedIndex;

  const NavigationState({this.selectedIndex = 0});

  @override
  List<Object?> get props => [selectedIndex];

  NavigationState copyWith({int? selectedIndex}) {
    return NavigationState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}

