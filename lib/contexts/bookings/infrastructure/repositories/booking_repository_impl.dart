import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_data_source.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource dataSource;

  BookingRepositoryImpl(this.dataSource);

  @override
  Future<Booking> createBooking({
    required DateTime startTime,
    required DateTime endTime,
    required String userId,
    required String courtId,
  }) => dataSource.createBooking(
    startTime: startTime,
    endTime:   endTime,
    userId:    userId,
    courtId:   courtId,
  );

  @override
  Future<List<Booking>> getMyBookings() => dataSource.getMyBookings();

  @override
  Future<Booking> cancelBooking(String bookingId) =>
      dataSource.cancelBooking(bookingId);
}
