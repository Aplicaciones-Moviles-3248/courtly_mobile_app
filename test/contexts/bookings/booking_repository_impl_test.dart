import 'package:flutter_test/flutter_test.dart';

import 'package:courtly_mobile_app/contexts/bookings/infrastructure/repositories/booking_repository_impl.dart';
import 'package:courtly_mobile_app/contexts/bookings/infrastructure/models/booking_model.dart';
import 'package:courtly_mobile_app/contexts/bookings/domain/value_objects/booking_status.dart';

import 'fakes.dart';

void main() {
  group('BookingRepositoryImpl', () {
    test('getMyBookings delega en el datasource', () async {
      final dataSource = FakeBookingRemoteDataSource()
        ..listResult = [
          BookingModel(
            id: '1',
            courtId: '5',
            courtName: 'Central Court',
            userId: '3',
            userName: 'Pedro',
            startTime: DateTime(2026, 6, 25, 18,),
            endTime: DateTime(2026, 6, 25, 20,),
            status: BookingStatus.pendingPayment,
          ),
        ];

      final repository = BookingRepositoryImpl(
          dataSource
      );

      final result = await repository.getMyBookings();

      expect(result, hasLength(1));
      expect(result.first.id, '1');
      expect(result.first.courtName, 'Central Court');
    });


    test('createBooking reenvia los parametros al datasource', () async {
      final dataSource = FakeBookingRemoteDataSource();
      final repository = BookingRepositoryImpl(
          dataSource
      );
      await repository.createBooking(
        startTime: DateTime.parse('2026-06-25T18:00:00'),
        endTime: DateTime.parse('2026-06-25T20:00:00'),
        userId: '3',
        courtId: '5',
      );

      expect(dataSource.lastUserId, '3');
      expect(dataSource.lastCourtId, '5');
      expect(dataSource.lastStartTime, DateTime.parse('2026-06-25T18:00:00'));
      expect(dataSource.lastEndTime, DateTime.parse('2026-06-25T20:00:00'));
    });


    test('cancelBooking reenvia el id al datasource', () async {
      final dataSource = FakeBookingRemoteDataSource();
      final repository = BookingRepositoryImpl(dataSource);
      await repository.cancelBooking('10');
      expect(dataSource.lastCancelledBookingId, '10');
    });
  });
}