import 'package:flutter_test/flutter_test.dart';

import 'package:courtly_mobile_app/contexts/matches/infrastructure/models/match_join_request_model.dart';

void main() {
  group('MatchJoinRequestModel.fromJson', () {
    test('mapea correctamente los campos y relaciones anidadas', () {
      final json = {
        'id': 9,
        'matchId': 4,
        'requester': {'id': 2, 'name': 'Ana'},
        'status': 'PENDING',
        'approvedBy': [
          {'id': 1, 'name': 'Juan'},
        ],
        'requiredApprovals': 2,
        'createdAt': '2026-07-10T18:00:00',
        'resolvedAt': null,
      };

      final model = MatchJoinRequestModel.fromJson(json);

      expect(model.id, '9');
      expect(model.matchId, '4');
      expect(model.requesterId, 2);
      expect(model.requesterName, 'Ana');
      expect(model.isPending, isTrue);
      expect(model.approvedByUserIds, [1]);
      expect(model.requiredApprovals, 2);
      expect(model.resolvedAt, isNull);
    });

    test('usa valores por defecto cuando faltan campos opcionales', () {
      final model = MatchJoinRequestModel.fromJson({
        'id': 1,
        'matchId': 2,
        'createdAt': '2026-07-10T18:00:00',
      });

      expect(model.requesterId, 0);
      expect(model.requesterName, '');
      expect(model.status, 'PENDING');
      expect(model.approvedByUserIds, isEmpty);
    });

    test('mapea resolvedAt cuando la solicitud fue resuelta', () {
      final model = MatchJoinRequestModel.fromJson({
        'id': 1,
        'matchId': 2,
        'status': 'APPROVED',
        'createdAt': '2026-07-10T18:00:00',
        'resolvedAt': '2026-07-10T18:05:00',
      });

      expect(model.isApproved, isTrue);
      expect(model.resolvedAt, DateTime(2026, 7, 10, 18, 5));
    });
  });
}
