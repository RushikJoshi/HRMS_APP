import 'package:flutter_bloc/flutter_bloc.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(const NotificationState()) {
    on<NotificationLoad>(_onLoad);
    on<NotificationMarkRead>(_onMarkRead);
    
    add(const NotificationLoad());
  }

  void _onLoad(
    NotificationLoad event,
    Emitter<NotificationState> emit,
  ) {
    // Mock data - in real app, fetch from API
    final notifications = [
      NotificationItem(
        id: '1',
        title: 'Leave Approved',
        message: 'Your leave request for Dec 25-26 has been approved',
        time: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
      NotificationItem(
        id: '2',
        title: 'New Circular',
        message: 'Holiday list for 2026 has been published',
        time: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      NotificationItem(
        id: '3',
        title: 'Payslip Generated',
        message: 'Your payslip for November 2025 is ready',
        time: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ];

    emit(state.copyWith(notifications: notifications));
  }

  void _onMarkRead(
    NotificationMarkRead event,
    Emitter<NotificationState> emit,
  ) {
    final updatedNotifications = state.notifications.map((notification) {
      if (notification.id == event.notificationId) {
        return NotificationItem(
          id: notification.id,
          title: notification.title,
          message: notification.message,
          time: notification.time,
          isRead: true,
        );
      }
      return notification;
    }).toList();

    emit(state.copyWith(notifications: updatedNotifications));
  }
}

