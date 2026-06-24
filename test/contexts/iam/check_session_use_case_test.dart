import 'package:flutter_test/flutter_test.dart';

import 'package:courtly_mobile_app/contexts/iam/application/use_cases/check_session_use_case.dart';
import 'package:courtly_mobile_app/contexts/iam/application/use_cases/sign_out_use_case.dart';

import 'fakes.dart';

void main() {
  group('CheckSessionUseCase', () {
    test('devuelve true cuando hay sesion activa', () async {
      final repository = FakeAuthenticationRepository()..sessionActive = true;
      final useCase = CheckSessionUseCase(repository);

      expect(await useCase.execute(), isTrue);
    });

    test('devuelve false cuando no hay sesion', () async {
      final repository = FakeAuthenticationRepository()..sessionActive = false;
      final useCase = CheckSessionUseCase(repository);

      expect(await useCase.execute(), isFalse);
    });
  });

  group('SignOutUseCase', () {
    test('pide al repositorio cerrar la sesion', () async {
      final repository = FakeAuthenticationRepository()..sessionActive = true;
      final useCase = SignOutUseCase(repository);

      await useCase.execute();

      expect(repository.signOutCalled, isTrue);
      expect(repository.sessionActive, isFalse);
    });
  });
}
