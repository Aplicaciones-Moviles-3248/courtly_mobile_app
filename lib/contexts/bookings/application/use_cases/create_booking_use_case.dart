import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';

class CreateBookingUseCase {
  final BookingRepository repository;
  CreateBookingUseCase(this.repository);

  Future<Booking> execute({
    required DateTime startTime,
    required DateTime endTime,
    required String userId,
    required String courtId,
  }) {
    return repository.createBooking(
      startTime: startTime,
      endTime: endTime,
      userId: userId,
      courtId: courtId,
    );
  }
}