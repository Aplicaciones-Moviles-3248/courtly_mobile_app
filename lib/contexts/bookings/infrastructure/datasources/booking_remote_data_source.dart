import '../../../../shared/infrastructure/http/api_client.dart';
import '../models/booking_model.dart';

class BookingRemoteDataSource {
  final ApiClient apiClient;

  BookingRemoteDataSource(this.apiClient);

  Future<BookingModel> createBooking({
    required DateTime startTime,
    required DateTime endTime,
    required String userId,
    required String courtId,
  }) async {

    final body = BookingModel.toCreateJson(
      startTime: startTime,
      endTime:   endTime,
      userId:    userId,
      courtId:   courtId,
    );

    final json = await apiClient.post('/bookings', body);

    return BookingModel.fromJson(json);
  }

  Future<List<BookingModel>> getMyBookings() async {
    final list = await apiClient.getList('/bookings');

    return list
        .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BookingModel> cancelBooking(String bookingId) async {
    final json = await apiClient.post('/bookings/$bookingId/cancel', {});

    return BookingModel.fromJson(json);
  }
}