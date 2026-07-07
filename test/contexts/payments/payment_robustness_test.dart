import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:courtly_mobile_app/contexts/payments/infrastructure/datasources/payment_remote_data_source.dart';
import 'package:courtly_mobile_app/shared/infrastructure/http/api_client.dart';
import 'package:courtly_mobile_app/shared/infrastructure/http/api_exception.dart';
import 'package:courtly_mobile_app/shared/infrastructure/storage/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PaymentRemoteDataSource error propagation', () {
    // El data source ya NO fabrica pagos falsos: propaga el error para que la
    // pantalla lo muestre en sus estados de error (sin crashear) y para no
    // hacerle creer al usuario que pagó cuando el backend rechazó la operación.

    test('getMyPayments propagates ApiException when backend fails', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final apiClient = ApiClient(
        LocalStorageService(),
        client: mockClient,
        maxRetries: 1,
      );

      final dataSource = PaymentRemoteDataSource(apiClient);

      expect(
        () => dataSource.getMyPayments(),
        throwsA(isA<ApiException>()),
      );
    });

    test('createPayment does NOT fake success when backend rejects', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Forbidden', 403);
      });

      final apiClient = ApiClient(
        LocalStorageService(),
        client: mockClient,
        maxRetries: 1,
      );

      final dataSource = PaymentRemoteDataSource(apiClient);

      expect(
        () => dataSource.createPayment(userId: 1, bookingId: 10),
        throwsA(isA<ApiException>()),
      );
    });

    test('getMyPayments returns parsed payments on success', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode([
            {
              'id': 5,
              'amount': 45.0,
              'paymentDate': '2026-07-01T10:00:00',
              'status': 'COMPLETED',
              'contextType': 'BOOKING',
              'bookingId': 12,
              'trainingSessionId': null,
              'user': {'id': 1, 'name': 'Juan Pérez'},
            }
          ]),
          200,
        );
      });

      final apiClient = ApiClient(
        LocalStorageService(),
        client: mockClient,
        maxRetries: 1,
      );

      final dataSource = PaymentRemoteDataSource(apiClient);

      final result = await dataSource.getMyPayments();

      expect(result, hasLength(1));
      expect(result.first.id, 5);
      expect(result.first.status, 'COMPLETED');
    });
  });
}
