import '../entities/payment.dart';

abstract class PaymentRepository {
  Future<List<Payment>> getMyPayments();

  Future<Payment> getPaymentById(int id);

  Future<Payment> createPayment({
    required int userId,
    int? bookingId,
    int? trainingSessionId,
  });
}
