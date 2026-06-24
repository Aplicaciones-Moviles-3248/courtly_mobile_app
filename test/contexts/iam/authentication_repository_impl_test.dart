import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:courtly_mobile_app/contexts/iam/infrastructure/repositories/authentication_repository_impl.dart';
import 'package:courtly_mobile_app/shared/infrastructure/storage/local_storage_service.dart';

import 'fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthenticationRepositoryImpl', () {
    test('signIn persiste la sesion completa (id, username, token)', () async {
      final storage = LocalStorageService();
      final repository = AuthenticationRepositoryImpl(
        dataSource: FakeAuthenticationRemoteDataSource(),
        localStorageService: storage,
      );

      final user = await repository.signIn('remote-user', 'pass');

      expect(user.id, 7);
      expect(await storage.getToken(), 'remote-token');
      expect(await storage.getUserId(), 7);
      expect(await storage.getUsername(), 'remote-user');
      expect(await repository.hasActiveSession(), isTrue);
    });

    test('signOut limpia la sesion persistida', () async {
      final storage = LocalStorageService();
      final repository = AuthenticationRepositoryImpl(
        dataSource: FakeAuthenticationRemoteDataSource(),
        localStorageService: storage,
      );

      await repository.signIn('remote-user', 'pass');
      expect(await repository.hasActiveSession(), isTrue);

      await repository.signOut();

      expect(await repository.hasActiveSession(), isFalse);
      expect(await storage.getToken(), isNull);
      expect(await storage.getUserId(), isNull);
    });

    test('signUp delega en el datasource y devuelve el id', () async {
      final repository = AuthenticationRepositoryImpl(
        dataSource: FakeAuthenticationRemoteDataSource()..signUpResult = 123,
        localStorageService: LocalStorageService(),
      );

      final id = await repository.signUp('nuevo', 'pass', ['ROLE_USER']);

      expect(id, 123);
    });
  });
}
