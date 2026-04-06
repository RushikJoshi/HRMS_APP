import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class NotificationLoad extends NotificationEvent {
  const NotificationLoad();
}

class NotificationMarkRead extends NotificationEvent {
  final String notificationId;

  const NotificationMarkRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

