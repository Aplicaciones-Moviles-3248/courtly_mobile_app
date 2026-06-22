import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:courtly_mobile_app/app/courtly_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('CourtlyApp arranca en la pantalla de autenticación',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CourtlyApp());
    await tester.pump();

    expect(find.text('Crear cuenta'), findsOneWidget);
  });
}
