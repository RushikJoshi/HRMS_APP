import 'package:equatable/equatable.dart';
import '../../screens/circular_screen.dart';

enum CircularLoadStatus { initial, loading, success, failure }

class CircularState extends Equatable {
  final List<Circular> allCirculars;
  final String searchQuery;
  final String? selectedCategory;
  final CircularLoadStatus status;
  final String? errorMessage;

  const CircularState({
    this.allCirculars = const [],
    this.searchQuery = '',
    this.selectedCategory,
    this.status = CircularLoadStatus.initial,
    this.errorMessage,
  });

  static const Object _unset = Object();

  List<Circular> get filteredCirculars {
    var filtered = allCirculars;

    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((circular) =>
              circular.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              circular.description.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    if (selectedCategory != null) {
      filtered = filtered
          .where((circular) => circular.category == selectedCategory)
          .toList();
    }

    return filtered;
  }

  Map<String, List<Circular>> get groupedCirculars {
    final grouped = <String, List<Circular>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);
    final prevMonthStart = DateTime(now.year, now.month - 1, 1);

    for (var circular in filteredCirculars) {
      final circularDate = DateTime(circular.date.year, circular.date.month, circular.date.day);
      
      String group;
      if (circularDate == today) {
        group = 'Today';
      } else if (circularDate.isAfter(weekStart.subtract(const Duration(days: 1)))) {
        group = 'This Week';
      } else if (circularDate.isAfter(prevMonthStart.subtract(const Duration(days: 1))) &&
          circularDate.isBefore(monthStart)) {
        group = 'Previous Month';
      } else {
        group = 'Older';
      }

      grouped.putIfAbsent(group, () => []).add(circular);
    }

    return grouped;
  }

  @override
  List<Object?> get props => [allCirculars, searchQuery, selectedCategory, status, errorMessage];

  CircularState copyWith({
    List<Circular>? allCirculars,
    String? searchQuery,
    Object? selectedCategory = _unset,
    CircularLoadStatus? status,
    Object? errorMessage = _unset,
  }) {
    return CircularState(
      allCirculars: allCirculars ?? this.allCirculars,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory == _unset
          ? this.selectedCategory
          : selectedCategory as String?,
      status: status ?? this.status,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
