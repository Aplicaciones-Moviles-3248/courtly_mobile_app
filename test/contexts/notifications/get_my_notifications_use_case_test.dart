import 'package:flutter_test/flutter_test.dart';

import 'package:courtly_mobile_app/contexts/notifications/application/use_cases/get_my_notifications_use_case.dart';
import 'package:courtly_mobile_app/contexts/notifications/domain/entities/app_notification.dart';
import 'package:courtly_mobile_app/contexts/notifications/domain/repositories/notification_repository.dart';

class _FakeNotificationRepository implements NotificationRepository {
  List<AppNotification> notifications = [];
  Object? error;

  @override
  Future<List<AppNotification>> getMyNotifications() async {
    if (error != null) throw error!;
    return notifications;
  }
}

AppNotification _buildNotification({String id = '1', String type = 'MATCH_JOIN_REQUESTED'}) {
  return AppNotification(
    id: id,
    title: 'Título',
    message: 'Mensaje',
    type: type,
    isRead: false,
    createdAt: DateTime(2026, 7, 10, 18, 0),
  );
}

void main() {
  group('GetMyNotificationsUseCase', () {
    test('retorna las notificaciones del repositorio', () async {
      final repo = _FakeNotificationRepository()
        ..notifications = [_buildNotification(id: '1'), _buildNotification(id: '2')];
      final useCase = GetMyNotificationsUseCase(repo);

      final result = await useCase.execute();

      expect(result, hasLength(2));
      expect(result.first.id, '1');
    });

    test('propaga el error cuando el backend falla', () async {
      final repo = _FakeNotificationRepository()..error = Exception('500');
      final useCase = GetMyNotificationsUseCase(repo);

      expect(() => useCase.execute(), throwsA(isA<Exception>()));
    });
  });
}
