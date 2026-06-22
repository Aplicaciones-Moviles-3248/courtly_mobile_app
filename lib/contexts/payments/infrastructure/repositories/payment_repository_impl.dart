import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_data_source.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource dataSource;

  PaymentRepositoryImpl(this.dataSource);

  @override
  Future<List<Payment>> getMyPayments() {
    return dataSource.getMyPayments();
  }

  @override
  Future<Payment> getPaymentById(int id) {
    return dataSource.getPaymentById(id);
  }

  @override
  Future<Payment> createPayment({
    required int userId,
    int? bookingId,
    int? trainingSessionId,
  }) {
    return dataSource.createPayment(
      userId: userId,
      bookingId: bookingId,
      trainingSessionId: trainingSessionId,
    );
  }
}
