import '../../../../shared/infrastructure/http/api_client.dart';
import '../models/payment_model.dart';

class PaymentRemoteDataSource {
  final ApiClient apiClient;

  PaymentRemoteDataSource(this.apiClient);

  Future<List<PaymentModel>> getMyPayments() async {
    final jsonList = await apiClient.getList('/payments');

    return jsonList
        .map((json) => PaymentModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<PaymentModel> getPaymentById(int id) async {
    final json = await apiClient.get('/payments/$id');

    return PaymentModel.fromJson(json);
  }

  Future<PaymentModel> createPayment({
    required int userId,
    int? bookingId,
    int? trainingSessionId,
  }) async {
    final body = <String, dynamic>{
      'userId': userId,
      'bookingId': ?bookingId,
      'trainingSessionId': ?trainingSessionId,
    };

    final json = await apiClient.post('/payments', body);

    return PaymentModel.fromJson(json);
  }
}
