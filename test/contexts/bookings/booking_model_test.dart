import 'package:flutter_test/flutter_test.dart';

import 'package:courtly_mobile_app/contexts/bookings/infrastructure/models/booking_model.dart';
import 'package:courtly_mobile_app/contexts/bookings/domain/value_objects/booking_status.dart';

void main() {
  group('BookingModel.fromJson', () {
    test('mapea correctamente una reserva confirmada del backend', () {
      final json = {
        'id': 15,
        'court': {
          'id': 3,
          'name': 'Central Court'
        },
        'user': {
          'id': 8,
          'name': 'Pedro'
        },
        'startTime': '2026-06-25T18:00:00',
        'endTime': '2026-06-25T20:00:00',
        'status': 'CONFIRMED'
      };

      final model = BookingModel.fromJson(json);

      expect(model.id, '15');
      expect(model.courtId, '3');
      expect(model.courtName, 'Central Court');
      expect(model.userId, '8');
      expect(model.userName, 'Pedro');
      expect(
          model.startTime,
          DateTime.parse('2026-06-25T18:00:00')
      );
      expect(
          model.endTime,
          DateTime.parse('2026-06-25T20:00:00')
      );
      expect(
          model.status,
          BookingStatus.confirmed
      );
    });

    test('convierte ids string correctamente', () {
      final json = {
        'id': '20',
        'court': {
          'id': '5',
          'name': 'North Court'
        },
        'user': {
          'id': '9',
          'name': 'Ana'
        },
        'startTime': '2026-06-25T10:00:00',
        'endTime': '2026-06-25T12:00:00',
        'status': 'PENDING_PAYMENT'
      };

      final model = BookingModel.fromJson(json);

      expect(model.id, '20');
      expect(model.courtId, '5');
      expect(model.userId, '9');
      expect(
          model.status,
          BookingStatus.pendingPayment
      );
    });

    test('usa valores por defecto cuando faltan campos', () {
      final json = {
        'id': null,
        'court': {
          'id': null,
          'name': null
        },
        'user': {
          'id': null,
          'name': null
        },
        'startTime': '2026-06-25T10:00:00',
        'endTime': '2026-06-25T11:00:00',
      };

      final model = BookingModel.fromJson(json);

      expect(model.id, 'null');
      expect(model.courtId, '');
      expect(model.courtName, 'Cancha');
      expect(model.userId, '');
      expect(model.userName, '');
    });
  });
}