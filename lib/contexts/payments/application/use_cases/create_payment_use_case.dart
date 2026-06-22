import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';

class CreatePaymentUseCase {
  final PaymentRepository repository;

  CreatePaymentUseCase(this.repository);

  /// Crea un pago para una reserva o una sesion de entrenamiento.
  ///
  /// El backend exige que el pago referencie exactamente un objetivo:
  /// una reserva (bookingId) o una sesion de entrenamiento (trainingSessionId),
  /// nunca ambos ni ninguno. Se valida aqui para fallar rapido con un mensaje claro.
  Future<Payment> execute({
    required int userId,
    int? bookingId,
    int? trainingSessionId,
  }) {
    final hasBooking = bookingId != null;
    final hasTrainingSession = trainingSessionId != null;

    if (hasBooking == hasTrainingSession) {
      throw ArgumentError(
        'El pago debe referenciar exactamente un objetivo: reserva o sesion de entrenamiento.',
      );
    }

    return repository.createPayment(
      userId: userId,
      bookingId: bookingId,
      trainingSessionId: trainingSessionId,
    );
  }
}
