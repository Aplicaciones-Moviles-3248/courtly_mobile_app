import 'package:flutter_test/flutter_test.dart';

import 'package:courtly_mobile_app/contexts/matches/application/use_cases/approve_match_join_request_use_case.dart';
import 'package:courtly_mobile_app/contexts/matches/application/use_cases/create_match_join_request_use_case.dart';
import 'package:courtly_mobile_app/contexts/matches/application/use_cases/get_join_requests_for_match_use_case.dart';
import 'package:courtly_mobile_app/contexts/matches/application/use_cases/get_match_join_request_use_case.dart';

import 'fakes.dart';

void main() {
  group('CreateMatchJoinRequestUseCase', () {
    test('crea una solicitud pendiente para el partido indicado', () async {
      final repo = FakeMatchRepository();
      final useCase = CreateMatchJoinRequestUseCase(repo);

      final result = await useCase.execute('5');

      expect(repo.lastJoinRequestMatchId, '5');
      expect(result.matchId, '5');
      expect(result.isPending, isTrue);
    });
  });

  group('GetMatchJoinRequestUseCase', () {
    test('retorna el estado actual de la solicitud', () async {
      final repo = FakeMatchRepository()
        ..joinRequestResult = buildJoinRequest(
          id: '3',
          matchId: '5',
          status: 'APPROVED',
          approvedByUserIds: [1, 2],
          requiredApprovals: 2,
        );
      final useCase = GetMatchJoinRequestUseCase(repo);

      final result = await useCase.execute('5', '3');

      expect(result.isApproved, isTrue);
      expect(result.approvalsCount, 2);
    });
  });

  group('GetJoinRequestsForMatchUseCase', () {
    test('retorna todas las solicitudes del partido', () async {
      final repo = FakeMatchRepository()
        ..joinRequests = [buildJoinRequest(id: '1'), buildJoinRequest(id: '2')];
      final useCase = GetJoinRequestsForMatchUseCase(repo);

      final result = await useCase.execute('5');

      expect(result, hasLength(2));
    });
  });

  group('ApproveMatchJoinRequestUseCase', () {
    test('aprueba la solicitud y retorna su nuevo estado', () async {
      final repo = FakeMatchRepository();
      final useCase = ApproveMatchJoinRequestUseCase(repo);

      final result = await useCase.execute('5', '3');

      expect(repo.lastApprovedRequestId, '3');
      expect(result.status, 'APPROVED');
    });
  });
}
