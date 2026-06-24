import 'package:flutter_test/flutter_test.dart';

import 'package:courtly_mobile_app/contexts/payments/application/use_cases/create_payment_use_case.dart';

import 'fakes.dart';

void main() {
  group('CreatePaymentUseCase', () {
    test('crea un pago para una reserva', () async {
      final repository = FakePaymentRepository();
      final useCase = CreatePaymentUseCase(repository);

      final payment = await useCase.execute(userId: 3, bookingId: 5);

      expect(repository.lastUserId, 3);
      expect(repository.lastBookingId, 5);
      expect(repository.lastTrainingSessionId, isNull);
      expect(payment.isBooking, isTrue);
    });

    test('crea un pago para una sesion de entrenamiento', () async {
      final repository = FakePaymentRepository();
      final useCase = CreatePaymentUseCase(repository);

      final payment = await useCase.execute(userId: 3, trainingSessionId: 8);

      expect(repository.lastTrainingSessionId, 8);
      expect(repository.lastBookingId, isNull);
      expect(payment.isTrainingSession, isTrue);
    });

    test('lanza error si no se referencia ningun objetivo', () {
      final useCase = CreatePaymentUseCase(FakePaymentRepository());

      expect(
        () => useCase.execute(userId: 3),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('lanza error si se referencian ambos objetivos', () {
      final useCase = CreatePaymentUseCase(FakePaymentRepository());

      expect(
        () => useCase.execute(userId: 3, bookingId: 5, trainingSessionId: 8),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
