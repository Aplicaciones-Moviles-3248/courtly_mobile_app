import 'package:flutter_test/flutter_test.dart';

import 'package:courtly_mobile_app/contexts/iam/application/use_cases/sign_up_use_case.dart';

import 'fakes.dart';

void main() {
  group('SignUpUseCase', () {
    test('envia username, password y roles, y devuelve el id creado', () async {
      final repository = FakeAuthenticationRepository()..signUpResult = 2;
      final useCase = SignUpUseCase(repository);

      final id = await useCase.execute('juan', 'secret', ['ROLE_USER']);

      expect(repository.lastUsername, 'juan');
      expect(repository.lastPassword, 'secret');
      expect(repository.lastRoles, ['ROLE_USER']);
      expect(id, 2);
    });
  });
}
