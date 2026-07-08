import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';

class GetMyBookingsUseCase {
  final BookingRepository repository;
  GetMyBookingsUseCase(this.repository);

  Future<List<Booking>> execute() => repository.getMyBookings();
}