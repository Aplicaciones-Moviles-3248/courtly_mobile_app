import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courtly_mobile_app/contexts/bookings/presentation/screens/create_booking_screen.dart';


void main() {
  testWidgets('muestra la pantalla de crear reserva', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CreateBookingScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(
        find.text('Reservar cancha'),
        findsOneWidget
    );
    expect(
        find.text('Fecha'),
        findsOneWidget
    );
    expect(
        find.text('Horario'),
        findsOneWidget
    );
    expect(
        find.text('Seleccionar fecha'),
        findsOneWidget
    );
    expect(
        find.text('Confirmar reserva'),
        findsOneWidget
    );
  });


  testWidgets('no permite confirmar sin fecha ni horario', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CreateBookingScreen(),
      ),
    );

    await tester.pumpAndSettle();

    final button = find.text(
        'Confirmar reserva'
    );

    expect(button, findsOneWidget);

    final elevatedButton = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton),
    );

    expect(elevatedButton.onPressed, isNull);
  });


  testWidgets('muestra la información de cancha recibida por argumentos',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CreateBookingScreen(),
            routes: {},
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Cancha'), findsOneWidget);
      });
}