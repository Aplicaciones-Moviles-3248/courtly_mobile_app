/// Booking
///
/// Entidad de dominio que representa una reserva realizada por el usuario.

import '../value_objects/booking_status.dart';

class Booking {
  final String id;
  final String courtId;
  final String courtName;
  final String userId;
  final String userName;
  final DateTime startTime;
  final DateTime endTime;
  final BookingStatus status;

  const Booking({
    required this.id,
    required this.courtId,
    required this.courtName,
    required this.userId,
    required this.userName,
    required this.startTime,
    required this.endTime,
    required this.status,
  });
}