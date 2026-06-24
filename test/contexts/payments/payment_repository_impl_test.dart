import 'package:flutter_test/flutter_test.dart';

import 'package:courtly_mobile_app/contexts/payments/infrastructure/models/payment_model.dart';
import 'package:courtly_mobile_app/contexts/payments/infrastructure/repositories/payment_repository_impl.dart';

import 'fakes.dart';

void main() {
  group('PaymentRepositoryImpl', () {
    test('getMyPayments delega en el datasource', () async {
      final dataSource = FakePaymentRemoteDataSource()
        ..listResult = const [
          PaymentModel(
            id: 1,
            amount: 50,
            paymentDate: null,
            status: 'COMPLETED',
            contextType: 'BOOKING',
            bookingId: 5,
            trainingSessionId: null,
            userId: 3,
            userName: 'Juan',
          ),
        ];
      final repository = PaymentRepositoryImpl(dataSource);

      final result = await repository.getMyPayments();

      expect(result, hasLength(1));
      expect(result.first.id, 1);
    });

    test('createPayment reenvia los parametros al datasource', () async {
      final dataSource = FakePaymentRemoteDataSource();
      final repository = PaymentRepositoryImpl(dataSource);

      await repository.createPayment(userId: 3, bookingId: 5);

      expect(dataSource.lastUserId, 3);
      expect(dataSource.lastBookingId, 5);
      expect(dataSource.lastTrainingSessionId, isNull);
    });
  });
}
