import '../entities/booking.dart';

abstract class BookingRepository {
  Future<Booking> createBooking({
    required DateTime startTime,
    required DateTime endTime,
    required String userId,
    required String courtId,
  });

  Future<List<Booking>> getMyBookings();

  Future<Booking> cancelBooking(String bookingId);
}