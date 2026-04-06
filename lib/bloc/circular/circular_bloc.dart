import 'package:flutter_bloc/flutter_bloc.dart';
import '../../screens/circular_screen.dart';
import 'circular_event.dart';
import 'circular_state.dart';
import '../../api/api.dart';
import '../../models/api/circular_response.dart';

class CircularBloc extends Bloc<CircularEvent, CircularState> {
  final Api _api = Api();

  CircularBloc() : super(const CircularState()) {
    on<CircularLoad>(_onLoad);
    on<CircularSearchChanged>(_onSearchChanged);
    on<CircularCategoryFilterChanged>(_onCategoryFilterChanged);
    on<CircularMarkAsRead>(_onMarkAsRead);
    
    add(const CircularLoad());
  }

  Future<void> _onLoad(
    CircularLoad event,
    Emitter<CircularState> emit,
  ) async {
    emit(state.copyWith(status: CircularLoadStatus.loading));

    try {
      final response = await _api.getNotifications();
      print('CircularBloc: Response: $response');
      
      if (response.success) {
        final circulars = response.data.map((item) {
          return Circular(
            id: item.id ?? '',
            title: item.title ?? 'No Title',
            date: DateTime.tryParse(item.createdAt ?? '') ?? DateTime.now(),
            description: item.description ?? '',
            uploadedBy: item.createdBy ?? 'System',
            status: item.status == 'Important' ? CircularStatus.important : CircularStatus.newStatus,
            attachments: item.attachments ?? [],
            isRead: item.isRead,
            category: item.category ?? 'General',
          );
        }).toList();

        // Sort by date descending here instead of in the state getter
        circulars.sort((a, b) => b.date.compareTo(a.date));

        emit(state.copyWith(
          allCirculars: circulars,
          status: CircularLoadStatus.success,
          errorMessage: null,
        ));
      } else {
        // Handle API failure response logic
        print('Failed to load circulars: ${response.message}');
        emit(state.copyWith(
          status: CircularLoadStatus.failure,
          errorMessage: response.message,
        ));
      }
    } catch (e) {
      print('Error loading circulars: $e');
      emit(state.copyWith(
        status: CircularLoadStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onSearchChanged(
    CircularSearchChanged event,
    Emitter<CircularState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.searchQuery));
  }

  void _onCategoryFilterChanged(
    CircularCategoryFilterChanged event,
    Emitter<CircularState> emit,
  ) {
    emit(state.copyWith(selectedCategory: event.category));
  }

  void _onMarkAsRead(
    CircularMarkAsRead event,
    Emitter<CircularState> emit,
  ) {
    final updatedCirculars = state.allCirculars.map((circular) {
      if (circular.id == event.circularId) {
        return Circular(
          id: circular.id,
          title: circular.title,
          date: circular.date,
          description: circular.description,
          uploadedBy: circular.uploadedBy,
          status: circular.status,
          attachments: circular.attachments,
          isRead: true,
          category: circular.category,
        );
      }
      return circular;
    }).toList();

    emit(state.copyWith(allCirculars: updatedCirculars));
  }
}

