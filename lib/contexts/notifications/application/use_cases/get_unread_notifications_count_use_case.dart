import '../../domain/entities/notification_count.dart';
import '../../domain/repositories/notification_repository.dart';

class GetUnreadNotificationsCountUseCase {
  final NotificationRepository repository;

  GetUnreadNotificationsCountUseCase(this.repository);

  Future<NotificationCount> execute() {
    return repository.getUnreadCount();
  }
}