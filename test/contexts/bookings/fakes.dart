import 'package:courtly_mobile_app/contexts/bookings/domain/entities/booking.dart';
import 'package:courtly_mobile_app/contexts/bookings/domain/repositories/booking_repository.dart';
import 'package:courtly_mobile_app/contexts/bookings/domain/value_objects/booking_status.dart';
import 'package:courtly_mobile_app/contexts/bookings/infrastructure/datasources/booking_remote_data_source.dart';
import 'package:courtly_mobile_app/contexts/bookings/infrastructure/models/booking_model.dart';
import 'package:courtly_mobile_app/shared/infrastructure/http/api_client.dart';
import 'package:courtly_mobile_app/shared/infrastructure/storage/local_storage_service.dart';

Booking buildBooking({
  String id = '1',
  String courtId = '5',
  String courtName = 'Central Court',
  String userId = '3',
  String userName = 'Pedro',
}) {
  return Booking(
    id: id,
    courtId: courtId,
    courtName: courtName,
    userId: userId,
    userName: userName,
    startTime: DateTime(2026, 6, 25, 18, 0),
    endTime: DateTime(2026, 6, 25, 20, 0),
    status: BookingStatus.pendingPayment,
  );
}

class FakeBookingRepository implements BookingRepository {
  List<Booking> myBookings = [buildBooking()];

  Booking? createdResult;
  String? lastUserId;
  String? lastCourtId;
  DateTime? lastStartTime;
  DateTime? lastEndTime;
  String? lastCancelledBookingId;

  @override
  Future<Booking> createBooking({
    required DateTime startTime,
    required DateTime endTime,
    required String userId,
    required String courtId,
  }) async {
    lastStartTime = startTime;
    lastEndTime = endTime;
    lastUserId = userId;
    lastCourtId = courtId;

    return createdResult ??
        Booking(
          id: '99',
          courtId: courtId,
          courtName: 'Central Court',
          userId: userId,
          userName: 'Pedro',
          startTime: startTime,
          endTime: endTime,
          status: BookingStatus.pendingPayment,
        );
  }

  @override
  Future<List<Booking>> getMyBookings() async {
    return myBookings;
  }

  @override
  Future<Booking> cancelBooking(String bookingId) async {
    lastCancelledBookingId = bookingId;

    return Booking(
      id: bookingId,
      courtId: '5',
      courtName: 'Central Court',
      userId: '3',
      userName: 'Pedro',
      startTime: DateTime(2026, 6, 25, 18, 0,),
      endTime: DateTime(2026, 6, 25, 20, 0,),
      status: BookingStatus.cancelled,
    );
  }
}


class FakeBookingRemoteDataSource extends BookingRemoteDataSource {
  FakeBookingRemoteDataSource()
      : super(ApiClient(LocalStorageService()));
  List<BookingModel> listResult = [];
  String? lastUserId;
  String? lastCourtId;
  DateTime? lastStartTime;
  DateTime? lastEndTime;
  String? lastCancelledBookingId;

  @override
  Future<List<BookingModel>> getMyBookings() async {
    return listResult;
  }

  @override
  Future<BookingModel> createBooking({
    required DateTime startTime,
    required DateTime endTime,
    required String userId,
    required String courtId,
  }) async {
    lastStartTime = startTime;
    lastEndTime = endTime;
    lastUserId = userId;
    lastCourtId = courtId;

    return BookingModel(
      id: '99',
      courtId: courtId,
      courtName: 'Central Court',
      userId: userId,
      userName: 'Pedro',
      startTime: startTime,
      endTime: endTime,
      status: BookingStatus.pendingPayment,
    );
  }

  @override
  Future<BookingModel> cancelBooking(String bookingId) async {
    lastCancelledBookingId = bookingId;

    return BookingModel(
      id: bookingId,
      courtId: '5',
      courtName: 'Central Court',
      userId: '3',
      userName: 'Pedro',
      startTime: DateTime(2026, 6, 25, 18,),
      endTime: DateTime(2026, 6, 25, 20,),
      status: BookingStatus.cancelled,
    );
  }
}