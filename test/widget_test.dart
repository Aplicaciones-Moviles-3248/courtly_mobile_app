import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:courtly_mobile_app/contexts/iam/presentation/screens/sign_in_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SignInScreen muestra las pestañas de autenticación',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignInScreen()));
    await tester.pump();

    expect(find.text('Iniciar sesión'), findsWidgets);
    expect(find.text('Crear cuenta'), findsOneWidget);
  });

  testWidgets('SignInScreen alterna al formulario de registro',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignInScreen()));
    await tester.pump();

    await tester.tap(find.text('Crear cuenta'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Nombre completo'), findsOneWidget);
    expect(find.text('Tipo de cuenta'), findsOneWidget);
  });
}
