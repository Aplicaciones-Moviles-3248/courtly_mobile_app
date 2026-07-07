import '../../domain/repositories/notification_repository.dart';

class MarkNotificationAsReadUseCase {
  final NotificationRepository repository;

  MarkNotificationAsReadUseCase(this.repository);

  Future<void> execute(String notificationId) {
    return repository.markAsRead(notificationId);
  }
}