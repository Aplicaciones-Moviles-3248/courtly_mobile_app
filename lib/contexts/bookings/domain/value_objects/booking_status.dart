/// BookingStatus
///
/// Represents the status of a booking.

enum BookingStatus {
  pendingPayment,
  confirmed,
  cancelled,
  completed;

  static BookingStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'CONFIRMED':
        return BookingStatus.confirmed;
      case 'CANCELLED':
        return BookingStatus.cancelled;
      case 'COMPLETED':
        return BookingStatus.completed;
      default:
        return BookingStatus.pendingPayment;
    }
  }

  String get label {
    switch (this) {
      case BookingStatus.pendingPayment:
        return 'Pend. Pago';
      case BookingStatus.confirmed:
        return 'Confirmada';
      case BookingStatus.cancelled:
        return 'Cancelada';
      case BookingStatus.completed:
        return 'Completada';
    }
  }
}