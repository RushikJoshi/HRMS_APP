import 'package:flutter_bloc/flutter_bloc.dart';
import 'language_event.dart';
import 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc() : super(const LanguageState()) {
    on<LanguageSelected>(_onLanguageSelected);
  }

  void _onLanguageSelected(
    LanguageSelected event,
    Emitter<LanguageState> emit,
  ) {
    emit(state.copyWith(selectedLanguage: event.language));
  }
}

