import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';

class GetMyNotificationsUseCase {
  final NotificationRepository repository;

  GetMyNotificationsUseCase(this.repository);

  Future<List<NotificationEntity>> execute() {
    return repository.getMyNotifications();
  }
}
