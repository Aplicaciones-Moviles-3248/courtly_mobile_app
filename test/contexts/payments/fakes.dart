import 'package:courtly_mobile_app/contexts/payments/domain/entities/payment.dart';
import 'package:courtly_mobile_app/contexts/payments/domain/repositories/payment_repository.dart';
import 'package:courtly_mobile_app/contexts/payments/infrastructure/datasources/payment_remote_data_source.dart';
import 'package:courtly_mobile_app/contexts/payments/infrastructure/models/payment_model.dart';
import 'package:courtly_mobile_app/shared/infrastructure/http/api_client.dart';
import 'package:courtly_mobile_app/shared/infrastructure/storage/local_storage_service.dart';

Payment buildPayment({
  int id = 1,
  double amount = 50.0,
  String status = 'COMPLETED',
  String contextType = 'BOOKING',
  int? bookingId = 5,
  int? trainingSessionId,
}) {
  return Payment(
    id: id,
    amount: amount,
    paymentDate: DateTime(2026, 6, 22, 10, 30),
    status: status,
    contextType: contextType,
    bookingId: bookingId,
    trainingSessionId: trainingSessionId,
    userId: 3,
    userName: 'Juan',
  );
}

/// Repositorio falso para probar casos de uso y la pantalla sin red.
class FakePaymentRepository implements PaymentRepository {
  List<Payment> myPayments = [buildPayment()];
  Payment? createdResult;
  Object? throwOnGetMyPayments;

  int? lastUserId;
  int? lastBookingId;
  int? lastTrainingSessionId;

  @override
  Future<List<Payment>> getMyPayments() async {
    if (throwOnGetMyPayments != null) {
      throw throwOnGetMyPayments!;
    }
    return myPayments;
  }

  @override
  Future<Payment> getPaymentById(int id) async {
    return buildPayment(id: id);
  }

  @override
  Future<Payment> createPayment({
    required int userId,
    int? bookingId,
    int? trainingSessionId,
  }) async {
    lastUserId = userId;
    lastBookingId = bookingId;
    lastTrainingSessionId = trainingSessionId;
    return createdResult ??
        buildPayment(
          id: 99,
          bookingId: bookingId,
          trainingSessionId: trainingSessionId,
          contextType: trainingSessionId != null ? 'TRAINING_SESSION' : 'BOOKING',
        );
  }
}

/// Datasource falso para probar el repositorio sin red.
class FakePaymentRemoteDataSource extends PaymentRemoteDataSource {
  FakePaymentRemoteDataSource() : super(ApiClient(LocalStorageService()));

  List<PaymentModel> listResult = const [];
  int? lastUserId;
  int? lastBookingId;
  int? lastTrainingSessionId;

  @override
  Future<List<PaymentModel>> getMyPayments() async => listResult;

  @override
  Future<PaymentModel> createPayment({
    required int userId,
    int? bookingId,
    int? trainingSessionId,
  }) async {
    lastUserId = userId;
    lastBookingId = bookingId;
    lastTrainingSessionId = trainingSessionId;
    return const PaymentModel(
      id: 1,
      amount: 80.0,
      paymentDate: null,
      status: 'COMPLETED',
      contextType: 'BOOKING',
      bookingId: 5,
      trainingSessionId: null,
      userId: 3,
      userName: 'Juan',
    );
  }
}
