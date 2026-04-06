import 'package:equatable/equatable.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
  });
}

class NotificationState extends Equatable {
  final List<NotificationItem> notifications;

  const NotificationState({this.notifications = const []});

  @override
  List<Object?> get props => [notifications];

  NotificationState copyWith({List<NotificationItem>? notifications}) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
    );
  }
}

