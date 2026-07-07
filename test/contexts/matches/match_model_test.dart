import 'package:flutter_test/flutter_test.dart';

import 'package:courtly_mobile_app/contexts/matches/infrastructure/models/match_model.dart';

void main() {
  group('MatchModel.fromJson', () {
    test('mapea correctamente los campos y relaciones anidadas', () {
      final json = {
        'id': 7,
        'title': 'Partido nocturno',
        'description': 'Amistoso',
        'dateTime': '2026-07-10T18:00:00',
        'status': 'OPEN',
        'maxPlayers': 4,
        'currentPlayers': 2,
        'court': {'id': 5, 'name': 'Cancha Norte'},
        'createdBy': {'id': 1, 'name': 'Juan'},
        'participants': [
          {'id': 1, 'name': 'Juan'},
          {'id': 2, 'name': 'Ana'},
        ],
      };

      final model = MatchModel.fromJson(json);

      expect(model.id, '7');
      expect(model.title, 'Partido nocturno');
      expect(model.courtId, '5');
      expect(model.courtName, 'Cancha Norte');
      expect(model.createdBy.name, 'Juan');
      expect(model.participants, hasLength(2));
      expect(model.participants[1].name, 'Ana');
    });

    test('usa valores por defecto cuando faltan campos opcionales', () {
      final json = {
        'id': 3,
        'dateTime': '2026-07-10T18:00:00',
      };

      final model = MatchModel.fromJson(json);

      expect(model.id, '3');
      expect(model.title, '');
      expect(model.status, 'OPEN');
      expect(model.courtName, 'Cancha');
      expect(model.participants, isEmpty);
    });
  });

  group('MatchModel.toCreateJson', () {
    test('serializa la fecha en el formato esperado por el backend', () {
      final body = MatchModel.toCreateJson(
        title: 'Fulbito',
        description: 'desc',
        dateTime: DateTime(2026, 7, 5, 9, 3),
        maxPlayers: 10,
        courtId: 2,
        createdById: 1,
      );

      expect(body['title'], 'Fulbito');
      expect(body['dateTime'], '2026-07-05T09:03:00');
      expect(body['status'], 'OPEN');
      expect(body['currentPlayers'], 1);
      expect(body['courtId'], 2);
      expect(body['createdById'], 1);
    });
  });
}
