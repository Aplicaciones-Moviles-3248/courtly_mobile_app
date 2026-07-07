import '../entities/notification.dart';
import '../entities/notification_count.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getMyNotifications();

  Future<NotificationCount> getUnreadCount();

  Future<void> markAsRead(String notificationId);

  Future<void> deleteNotification(String notificationId);
}