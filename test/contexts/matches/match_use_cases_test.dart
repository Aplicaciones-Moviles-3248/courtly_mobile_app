import 'package:flutter_test/flutter_test.dart';

import 'package:courtly_mobile_app/contexts/matches/application/use_cases/get_all_matches_use_case.dart';
import 'package:courtly_mobile_app/contexts/matches/application/use_cases/join_match_use_case.dart';
import 'package:courtly_mobile_app/contexts/matches/application/use_cases/create_match_use_case.dart';

import 'fakes.dart';

void main() {
  group('GetAllMatchesUseCase', () {
    test('devuelve todos los partidos del repositorio', () async {
      final repo = FakeMatchRepository()
        ..matches = [buildMatch(id: '1'), buildMatch(id: '2')];
      final useCase = GetAllMatchesUseCase(repo);

      final result = await useCase.execute();

      expect(result, hasLength(2));
      expect(result.first.id, '1');
    });
  });

  group('JoinMatchUseCase', () {
    test('une al partido y retorna el partido actualizado', () async {
      final repo = FakeMatchRepository();
      final useCase = JoinMatchUseCase(repo);

      final result = await useCase.execute('42');

      expect(repo.lastJoinedId, '42');
      expect(result.id, '42');
      expect(result.currentPlayers, 2);
    });

    test('propaga el error cuando el backend falla', () async {
      final repo = FakeMatchRepository()..throwOnJoin = Exception('lleno');
      final useCase = JoinMatchUseCase(repo);

      expect(() => useCase.execute('7'), throwsA(isA<Exception>()));
    });
  });

  group('CreateMatchUseCase', () {
    test('crea un partido con los datos provistos', () async {
      final repo = FakeMatchRepository();
      final useCase = CreateMatchUseCase(repo);

      final result = await useCase.execute(
        title: 'Fulbito viernes',
        description: 'desc',
        dateTime: DateTime(2026, 7, 12, 20, 0),
        maxPlayers: 10,
        courtId: 3,
        createdById: 1,
      );

      expect(repo.lastCreatedTitle, 'Fulbito viernes');
      expect(result.maxPlayers, 10);
    });
  });
}
