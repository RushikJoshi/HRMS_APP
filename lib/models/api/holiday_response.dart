class Holiday {
  final int? id;
  final String name;
  final DateTime date;
  final String? category;

  Holiday({this.id, required this.name, required this.date, this.category});

  factory Holiday.fromJson(Map<String, dynamic> json) {
    final dateValue = json['date'];
    DateTime parsed;
    if (dateValue is String) {
      parsed = DateTime.parse(dateValue);
    } else if (dateValue is int) {
      parsed = DateTime.fromMillisecondsSinceEpoch(dateValue);
    } else {
      parsed = DateTime.now();
    }
    return Holiday(
      id: json['id'] is int
          ? json['id'] as int
          : (json['id'] != null ? int.tryParse('${json['id']}') : null),
      name: json['name'] ?? '',
      date: parsed,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
    'date': date.toIso8601String(),
    if (category != null) 'category': category,
  };
}
