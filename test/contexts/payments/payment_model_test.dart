import 'package:flutter_test/flutter_test.dart';

import 'package:courtly_mobile_app/contexts/payments/infrastructure/models/payment_model.dart';

void main() {
  group('PaymentModel.fromJson', () {
    test('mapea la respuesta real del backend (reserva)', () {
      final json = {
        'id': 10,
        'amount': 75.50,
        'paymentDate': '2026-06-22T10:30:00',
        'status': 'COMPLETED',
        'contextType': 'BOOKING',
        'bookingId': 5,
        'trainingSessionId': null,
        'user': {'id': 3, 'name': 'Juan'},
      };

      final model = PaymentModel.fromJson(json);

      expect(model.id, 10);
      expect(model.amount, 75.50);
      expect(model.status, 'COMPLETED');
      expect(model.contextType, 'BOOKING');
      expect(model.isBooking, isTrue);
      expect(model.bookingId, 5);
      expect(model.trainingSessionId, isNull);
      expect(model.userId, 3);
      expect(model.userName, 'Juan');
      expect(model.paymentDate, DateTime.parse('2026-06-22T10:30:00'));
    });

    test('mapea una sesion de entrenamiento y amount como entero/string', () {
      final json = {
        'id': '11',
        'amount': '120',
        'paymentDate': null,
        'status': 'PENDING',
        'contextType': 'TRAINING_SESSION',
        'bookingId': null,
        'trainingSessionId': 8,
        'user': {'id': 4, 'name': 'Ana'},
      };

      final model = PaymentModel.fromJson(json);

      expect(model.id, 11);
      expect(model.amount, 120.0);
      expect(model.isTrainingSession, isTrue);
      expect(model.trainingSessionId, 8);
      expect(model.bookingId, isNull);
      expect(model.paymentDate, isNull);
    });

    test('usa valores por defecto cuando faltan campos', () {
      final model = PaymentModel.fromJson({});

      expect(model.id, 0);
      expect(model.amount, 0);
      expect(model.status, '');
      expect(model.contextType, '');
      expect(model.userId, 0);
      expect(model.userName, '');
    });
  });
}
