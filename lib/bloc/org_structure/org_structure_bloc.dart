import 'package:flutter_bloc/flutter_bloc.dart';
import 'org_structure_event.dart';
import 'org_structure_state.dart';

class OrgStructureBloc extends Bloc<OrgStructureEvent, OrgStructureState> {
  static const int pageSize =
      2; // Reduced to 2 to eliminate horizontal scrolling on mobile

  OrgStructureBloc() : super(const OrgStructureState()) {
    on<OrgStructureNextPage>(_onNextPage);
    on<OrgStructurePreviousPage>(_onPrevPage);
  }

  void _onNextPage(
    OrgStructureNextPage event,
    Emitter<OrgStructureState> emit,
  ) {
    final current = state.childPageOffset[event.nodeId] ?? 0;
    if (current + pageSize < event.totalChildren) {
      final updated = Map<String, int>.from(state.childPageOffset);
      updated[event.nodeId] = current + pageSize;
      emit(state.copyWith(childPageOffset: updated));
    }
  }

  void _onPrevPage(
    OrgStructurePreviousPage event,
    Emitter<OrgStructureState> emit,
  ) {
    final current = state.childPageOffset[event.nodeId] ?? 0;
    if (current - pageSize >= 0) {
      final updated = Map<String, int>.from(state.childPageOffset);
      updated[event.nodeId] = current - pageSize;
      emit(state.copyWith(childPageOffset: updated));
    }
  }
}
