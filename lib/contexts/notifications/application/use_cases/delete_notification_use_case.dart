import '../../domain/repositories/notification_repository.dart';

class DeleteNotificationUseCase {
  final NotificationRepository repository;

  DeleteNotificationUseCase(this.repository);

  Future<void> execute(String notificationId) {
    return repository.deleteNotification(notificationId);
  }
}