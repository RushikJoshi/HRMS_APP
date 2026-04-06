import 'package:equatable/equatable.dart';

abstract class LanguageEvent extends Equatable {
  const LanguageEvent();

  @override
  List<Object?> get props => [];
}

class LanguageSelected extends LanguageEvent {
  final String language;

  const LanguageSelected(this.language);

  @override
  List<Object?> get props => [language];
}

