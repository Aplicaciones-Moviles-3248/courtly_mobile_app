import 'package:flutter_test/flutter_test.dart';

import 'package:courtly_mobile_app/contexts/bookings/application/use_cases/cancel_booking_use_case.dart';
import 'package:courtly_mobile_app/contexts/bookings/domain/value_objects/booking_status.dart';

import 'fakes.dart';

void main() {
  group('CancelBookingUseCase', () {
    test('cancela una reserva correctamente', () async {
      final repository = FakeBookingRepository();
      final useCase = CancelBookingUseCase(repository);
      final booking = await useCase.execute('5');

      expect(repository.lastCancelledBookingId, '5');
      expect(booking.id, '5');
      expect(booking.status, BookingStatus.cancelled);
    });
  });
}