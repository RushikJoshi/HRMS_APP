import 'package:equatable/equatable.dart';

abstract class OrgStructureEvent extends Equatable {
  const OrgStructureEvent();

  @override
  List<Object?> get props => [];
}

class OrgStructureNextPage extends OrgStructureEvent {
  final String nodeId;
  final int totalChildren;

  const OrgStructureNextPage({
    required this.nodeId,
    required this.totalChildren,
  });

  @override
  List<Object?> get props => [nodeId, totalChildren];
}

class OrgStructurePreviousPage extends OrgStructureEvent {
  final String nodeId;

  const OrgStructurePreviousPage(this.nodeId);

  @override
  List<Object?> get props => [nodeId];
}

