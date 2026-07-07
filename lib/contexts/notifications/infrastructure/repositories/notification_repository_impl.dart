import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<AppNotification>> getMyNotifications() {
    return remoteDataSource
        .getMyNotifications()
        .then((list) => list.cast<AppNotification>());
  }
}
