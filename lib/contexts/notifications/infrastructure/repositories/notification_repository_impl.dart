import '../../domain/entities/notification.dart';
import '../../domain/entities/notification_count.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';

class NotificationRepositoryImpl
    implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<NotificationEntity>> getMyNotifications() {
    return remoteDataSource.getMyNotifications();
  }

  @override
  Future<NotificationCount> getUnreadCount() {
    return remoteDataSource.getUnreadCount();
  }

  @override
  Future<void> markAsRead(String notificationId) {
    return remoteDataSource.markAsRead(notificationId);
  }

  @override
  Future<void> deleteNotification(String notificationId) {
    return remoteDataSource.deleteNotification(notificationId);
  }
}