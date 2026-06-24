/// Payment
///
/// Entidad de dominio que representa un pago realizado por el usuario, ya sea
/// asociado a una reserva (booking) o a una sesion de entrenamiento.
class Payment {
  final int id;
  final double amount;
  final DateTime? paymentDate;
  final String status;
  final String contextType;
  final int? bookingId;
  final int? trainingSessionId;
  final int userId;
  final String userName;

  const Payment({
    required this.id,
    required this.amount,
    required this.paymentDate,
    required this.status,
    required this.contextType,
    required this.bookingId,
    required this.trainingSessionId,
    required this.userId,
    required this.userName,
  });

  bool get isBooking => contextType == 'BOOKING';

  bool get isTrainingSession => contextType == 'TRAINING_SESSION';
}
