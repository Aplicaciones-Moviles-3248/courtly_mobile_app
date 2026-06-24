import 'package:flutter_test/flutter_test.dart';

import 'package:courtly_mobile_app/contexts/iam/application/use_cases/sign_in_use_case.dart';

import 'fakes.dart';

void main() {
  group('SignInUseCase', () {
    test('delega las credenciales al repositorio y devuelve el usuario', () async {
      final repository = FakeAuthenticationRepository();
      final useCase = SignInUseCase(repository);

      final result = await useCase.execute('juan', 'secret');

      expect(repository.lastUsername, 'juan');
      expect(repository.lastPassword, 'secret');
      expect(result.username, 'tester');
      expect(result.token, 'token-123');
    });
  });
}
