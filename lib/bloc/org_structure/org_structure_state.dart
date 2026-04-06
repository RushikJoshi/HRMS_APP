import 'package:equatable/equatable.dart';

class OrgStructureState extends Equatable {
  final Map<String, int> childPageOffset;

  const OrgStructureState({this.childPageOffset = const {}});

  @override
  List<Object?> get props => [childPageOffset];

  OrgStructureState copyWith({Map<String, int>? childPageOffset}) {
    return OrgStructureState(
      childPageOffset: childPageOffset ?? this.childPageOffset,
    );
  }
}

