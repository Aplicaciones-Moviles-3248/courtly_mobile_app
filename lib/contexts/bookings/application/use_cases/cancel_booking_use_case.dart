import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';

class CancelBookingUseCase {
  final BookingRepository repository;
  CancelBookingUseCase(this.repository);

  Future<Booking> execute(String bookingId) => repository.cancelBooking(bookingId);
}