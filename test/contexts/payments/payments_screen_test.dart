import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtly_mobile_app/contexts/payments/presentation/screens/payments_screen.dart';

import 'fakes.dart';

void main() {
  testWidgets('muestra la lista de pagos del usuario', (tester) async {
    final repository = FakePaymentRepository()
      ..myPayments = [buildPayment(id: 1, amount: 50.0, status: 'COMPLETED')];

    await tester.pumpWidget(
      MaterialApp(home: PaymentsScreen(repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mis pagos'), findsOneWidget);
    expect(find.text('S/ 50.00'), findsOneWidget);
    expect(find.text('COMPLETADO'), findsOneWidget);
  });

  testWidgets('muestra el estado vacio cuando no hay pagos', (tester) async {
    final repository = FakePaymentRepository()..myPayments = [];

    await tester.pumpWidget(
      MaterialApp(home: PaymentsScreen(repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aun no tienes pagos'), findsOneWidget);
  });

  testWidgets('muestra el estado de error cuando falla la carga',
      (tester) async {
    final repository = FakePaymentRepository()
      ..throwOnGetMyPayments = Exception('boom');

    await tester.pumpWidget(
      MaterialApp(home: PaymentsScreen(repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Algo salio mal'), findsOneWidget);
  });
}
