import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';

class GetMyPaymentsUseCase {
  final PaymentRepository repository;

  GetMyPaymentsUseCase(this.repository);

  Future<List<Payment>> execute() {
    return repository.getMyPayments();
  }
}
