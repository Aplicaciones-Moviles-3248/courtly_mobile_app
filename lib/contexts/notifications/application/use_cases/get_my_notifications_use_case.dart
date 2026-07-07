import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';

class GetMyNotificationsUseCase {
  final NotificationRepository repository;

  GetMyNotificationsUseCase(this.repository);

  Future<List<AppNotification>> execute() {
    return repository.getMyNotifications();
  }
}
