import 'package:flutter_test/flutter_test.dart';
import 'package:courtly_mobile_app/contexts/notifications/domain/value_objects/notification_type.dart';
import 'package:courtly_mobile_app/contexts/notifications/infrastructure/models/notification_model.dart';

void main() {
  group('NotificationModel.fromJson', () {
    test('mapea correctamente los campos', () {
      final model = NotificationModel.fromJson({
        'id': 3,
        'title': 'Consenso alcanzado',
        'message': 'Ya formas parte del partido',
        'type': 'MATCH_JOIN_APPROVED',
        'isRead': false,
        'createdAt': '2026-07-10T18:00:00',
      });
      expect(model.id, '3');
      expect(model.title, 'Consenso alcanzado');
      expect(model.message, 'Ya formas parte del partido');
      expect(model.type, NotificationType.matchJoinApproved);
      expect(model.isRead, isFalse);
    });

    test('usa valores por defecto cuando faltan campos opcionales', () {
      final model = NotificationModel.fromJson({
        'id': 1,
        'createdAt': '2026-07-10T18:00:00',
      });
      expect(model.title, '');
      expect(model.message, '');
      expect(model.type, NotificationType.bookingCreated);
      expect(model.isRead, isFalse);
    });
  });
}