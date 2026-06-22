import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:courtly_mobile_app/shared/infrastructure/storage/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocalStorageService', () {
    test('saveSession y lectura de los datos persistidos', () async {
      final storage = LocalStorageService();

      await storage.saveSession(
        userId: 5,
        username: 'juan',
        token: 'jwt-token',
      );

      expect(await storage.getToken(), 'jwt-token');
      expect(await storage.getUserId(), 5);
      expect(await storage.getUsername(), 'juan');
      expect(await storage.hasActiveSession(), isTrue);
    });

    test('hasActiveSession es false sin token', () async {
      final storage = LocalStorageService();
      expect(await storage.hasActiveSession(), isFalse);
    });

    test('clearSession elimina todos los datos de sesion', () async {
      final storage = LocalStorageService();
      await storage.saveSession(userId: 5, username: 'juan', token: 'jwt');

      await storage.clearSession();

      expect(await storage.getToken(), isNull);
      expect(await storage.getUserId(), isNull);
      expect(await storage.getUsername(), isNull);
      expect(await storage.hasActiveSession(), isFalse);
    });
  });
}
