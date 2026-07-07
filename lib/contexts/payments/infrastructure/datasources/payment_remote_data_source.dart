import '../../../../shared/infrastructure/http/api_client.dart';
import '../models/payment_model.dart';

/// PaymentRemoteDataSource
///
/// Capa fina de acceso al backend de pagos. NO fabrica datos ni éxitos falsos:
/// los errores se propagan como [ApiException] para que la capa de presentación
/// los muestre en sus estados de error (la pantalla ya no crashea). Fabricar un
/// pago "COMPLETED" cuando el backend lo rechaza haría creer al usuario que pagó
/// sin haberlo hecho, por eso se dejó explícitamente sin fallback de éxito.
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
      'bookingId': bookingId,
      'trainingSessionId': trainingSessionId,
    };

    final json = await apiClient.post('/payments', body);
    return PaymentModel.fromJson(json);
  }
}
