import '../datasources/notifications_remote_data_source.dart';
import '../models/notification_model.dart';

class NotificationsRepository {
  final NotificationsRemoteDataSource _remoteDataSource;

  NotificationsRepository(this._remoteDataSource);

  Stream<List<NotificationModel>> watchNotifications() {
    return _remoteDataSource.watchNotifications();
  }

  Future<void> markAsRead(String notificationId) {
    return _remoteDataSource.markAsRead(notificationId);
  }

  Future<void> markAllAsRead() {
    return _remoteDataSource.markAllAsRead();
  }
}