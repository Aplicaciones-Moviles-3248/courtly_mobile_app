import 'package:flutter_test/flutter_test.dart';

import 'package:courtly_mobile_app/contexts/bookings/application/use_cases/create_booking_use_case.dart';

import 'fakes.dart';


void main() {
  group('CreateBookingUseCase', () {
    test('crea una reserva correctamente', () async {
      final repository = FakeBookingRepository();

      final useCase = CreateBookingUseCase(repository);

      final booking = await useCase.execute(
        startTime: DateTime.parse('2026-06-25T18:00:00'),
        endTime: DateTime.parse('2026-06-25T20:00:00'),
        userId: '3',
        courtId: '5',
      );

      expect(repository.lastUserId, '3');
      expect(repository.lastCourtId, '5');
      expect(
          repository.lastStartTime,
          DateTime.parse(
              '2026-06-25T18:00:00'
          )
      );
      expect(
          repository.lastEndTime,
          DateTime.parse(
              '2026-06-25T20:00:00'
          )
      );
      expect(
          booking.courtId,
          '5'
      );
    });


    test('crea una reserva con otra cancha', () async {
      final repository = FakeBookingRepository();

      final useCase = CreateBookingUseCase(repository);

      final booking = await useCase.execute(
        startTime: DateTime.parse('2026-06-26T10:00:00'),
        endTime: DateTime.parse('2026-06-26T12:00:00'),
        userId: '8',
        courtId: '10',
      );
      expect(repository.lastUserId, '8');
      expect(repository.lastCourtId, '10');
      expect(booking.userId, '8');
    });


    test('crea una reserva manteniendo los datos enviados', () async {
      final repository = FakeBookingRepository();
      final useCase = CreateBookingUseCase(repository);
      final start = DateTime.parse('2026-07-01T15:00:00');
      final end = DateTime.parse('2026-07-01T17:00:00');

      final booking = await useCase.execute(
        startTime: start,
        endTime: end,
        userId: '20',
        courtId: '30',
      );
      expect(repository.lastStartTime, start);
      expect(repository.lastEndTime, end);
      expect(booking.userId, '20');
      expect(booking.courtId, '30');
    });
  });
}