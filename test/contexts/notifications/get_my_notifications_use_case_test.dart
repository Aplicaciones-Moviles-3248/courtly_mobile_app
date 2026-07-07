import 'package:flutter_test/flutter_test.dart';
import 'package:courtly_mobile_app/contexts/notifications/application/use_cases/get_my_notifications_use_case.dart';
import 'package:courtly_mobile_app/contexts/notifications/domain/entities/notification.dart';
import 'package:courtly_mobile_app/contexts/notifications/domain/entities/notification_count.dart';
import 'package:courtly_mobile_app/contexts/notifications/domain/repositories/notification_repository.dart';
import 'package:courtly_mobile_app/contexts/notifications/domain/value_objects/notification_type.dart';

class _FakeNotificationRepository implements NotificationRepository {
  final List<NotificationEntity> _items;
  _FakeNotificationRepository(this._items);

  @override
  Future<List<NotificationEntity>> getMyNotifications() async => _items;

  @override
  Future<NotificationCount> getUnreadCount() async =>
      const NotificationCount(userId: '3', unreadCount: 0);

  @override
  Future<void> markAsRead(String notificationId) async {}

  @override
  Future<void> deleteNotification(String notificationId) async {}
}

NotificationEntity _build({String id = '1', bool isRead = false}) =>
    NotificationEntity(
      id: id,
      title: 'Reserva confirmada',
      message: 'Tu reserva ha sido confirmada.',
      type: NotificationType.bookingConfirmed,
      isRead: isRead,
      relatedEntityType: 'BOOKING',
      relatedEntityId: '5',
      createdAt: DateTime(2026, 6, 25, 10, 30),
    );

void main() {
  group('GetMyNotificationsUseCase', () {
    test('devuelve la lista de notificaciones', () async {
      final repo    = _FakeNotificationRepository([_build()]);
      final useCase = GetMyNotificationsUseCase(repo);

      final result = await useCase.execute();

      expect(result.length, 1);
      expect(result.first.id, '1');
      expect(result.first.type, NotificationType.bookingConfirmed);
    });

    test('devuelve lista vacía cuando no hay notificaciones', () async {
      final repo    = _FakeNotificationRepository([]);
      final useCase = GetMyNotificationsUseCase(repo);

      final result  = await useCase.execute();

      expect(result, isEmpty);
    });

    test('devuelve múltiples notificaciones', () async {
      final repo = _FakeNotificationRepository([
        _build(id: '1'),
        _build(id: '2'),
        _build(id: '3'),
      ]);
      final useCase = GetMyNotificationsUseCase(repo);

      final result = await useCase.execute();

      expect(result.length, 3);
    });
  });
}