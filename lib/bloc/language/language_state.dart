import 'package:equatable/equatable.dart';

class LanguageState extends Equatable {
  final String selectedLanguage;

  const LanguageState({this.selectedLanguage = 'English'});

  @override
  List<Object?> get props => [selectedLanguage];

  LanguageState copyWith({String? selectedLanguage}) {
    return LanguageState(
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }
}

