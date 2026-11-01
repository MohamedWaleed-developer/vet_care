import '../../data/models/notification_model.dart';

enum NotificationsStatus {
  initial,
  loading,
  success,
  failure,
}

class NotificationsState {
  final NotificationsStatus status;
  final List<NotificationModel> notifications;
  final String? errorMessage;

  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.errorMessage,
  });

  List<NotificationModel> get todayNotifications {
    final now = DateTime.now();

    return notifications.where((notification) {
      final date = notification.createdAt;

      if (date == null) {
        return false;
      }

      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).toList();
  }

  List<NotificationModel> get earlierNotifications {
    final now = DateTime.now();

    return notifications.where((notification) {
      final date = notification.createdAt;

      if (date == null) {
        return true;
      }

      return date.year != now.year ||
          date.month != now.month ||
          date.day != now.day;
    }).toList();
  }

  int get unreadCount {
    return notifications.where((notification) {
      return !notification.isRead;
    }).length;
  }

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationModel>? notifications,
    String? errorMessage,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}