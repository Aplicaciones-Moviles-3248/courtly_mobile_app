import 'package:flutter_test/flutter_test.dart';

import 'package:courtly_mobile_app/contexts/payments/application/use_cases/get_my_payments_use_case.dart';
import 'package:courtly_mobile_app/contexts/payments/application/use_cases/get_payment_by_id_use_case.dart';

import 'fakes.dart';

void main() {
  group('GetMyPaymentsUseCase', () {
    test('devuelve la lista de pagos del repositorio', () async {
      final repository = FakePaymentRepository()
        ..myPayments = [buildPayment(id: 1), buildPayment(id: 2)];
      final useCase = GetMyPaymentsUseCase(repository);

      final result = await useCase.execute();

      expect(result, hasLength(2));
      expect(result.first.id, 1);
    });
  });

  group('GetPaymentByIdUseCase', () {
    test('devuelve el pago solicitado', () async {
      final useCase = GetPaymentByIdUseCase(FakePaymentRepository());

      final payment = await useCase.execute(7);

      expect(payment.id, 7);
    });
  });
}
