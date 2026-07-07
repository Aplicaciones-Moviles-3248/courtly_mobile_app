import 'package:courtly_mobile_app/contexts/matches/domain/entities/match.dart';
import 'package:courtly_mobile_app/contexts/matches/domain/entities/match_join_request.dart';
import 'package:courtly_mobile_app/contexts/matches/domain/repositories/match_repository.dart';
import 'package:courtly_mobile_app/contexts/users/domain/entities/user_profile.dart';

UserProfile buildUser({int id = 1, String name = 'Juan'}) {
  return UserProfile(
    id: id,
    name: name,
    email: '',
    phone: '',
    imageUrl: '',
  );
}

Match buildMatch({
  String id = '1',
  String title = 'Partido de prueba',
  String status = 'OPEN',
  int maxPlayers = 4,
  int currentPlayers = 1,
  List<UserProfile>? participants,
}) {
  return Match(
    id: id,
    title: title,
    description: 'desc',
    dateTime: DateTime(2026, 7, 10, 18, 0),
    status: status,
    maxPlayers: maxPlayers,
    currentPlayers: currentPlayers,
    courtId: '5',
    courtName: 'Cancha Central',
    createdBy: buildUser(),
    participants: participants ?? [buildUser()],
  );
}

MatchJoinRequest buildJoinRequest({
  String id = '1',
  String matchId = '1',
  int requesterId = 2,
  String requesterName = 'Requester',
  String status = 'PENDING',
  List<int>? approvedByUserIds,
  int requiredApprovals = 1,
}) {
  return MatchJoinRequest(
    id: id,
    matchId: matchId,
    requesterId: requesterId,
    requesterName: requesterName,
    status: status,
    approvedByUserIds: approvedByUserIds ?? [],
    requiredApprovals: requiredApprovals,
    createdAt: DateTime(2026, 7, 10, 17, 0),
  );
}

class FakeMatchRepository implements MatchRepository {
  List<Match> matches = [buildMatch()];
  Match? joinResult;
  Object? throwOnJoin;
  MatchJoinRequest? joinRequestResult;
  MatchJoinRequest? approveResult;
  List<MatchJoinRequest> joinRequests = [];

  String? lastJoinedId;
  String? lastCreatedTitle;
  String? lastJoinRequestMatchId;
  String? lastApprovedRequestId;

  @override
  Future<Match> createMatch({
    required String title,
    required String description,
    required DateTime dateTime,
    required int maxPlayers,
    required int courtId,
    required int createdById,
  }) async {
    lastCreatedTitle = title;
    return buildMatch(id: '99', title: title, maxPlayers: maxPlayers);
  }

  @override
  Future<List<Match>> getAllMatches() async => matches;

  @override
  Future<Match> joinMatch(String matchId) async {
    lastJoinedId = matchId;
    if (throwOnJoin != null) throw throwOnJoin!;
    return joinResult ?? buildMatch(id: matchId, currentPlayers: 2);
  }

  @override
  Future<MatchJoinRequest> createJoinRequest(String matchId) async {
    lastJoinRequestMatchId = matchId;
    return joinRequestResult ?? buildJoinRequest(matchId: matchId);
  }

  @override
  Future<List<MatchJoinRequest>> getJoinRequestsForMatch(String matchId) async {
    return joinRequests;
  }

  @override
  Future<MatchJoinRequest> getJoinRequest(String matchId, String requestId) async {
    return joinRequestResult ?? buildJoinRequest(id: requestId, matchId: matchId);
  }

  @override
  Future<MatchJoinRequest> approveJoinRequest(String matchId, String requestId) async {
    lastApprovedRequestId = requestId;
    return approveResult ?? buildJoinRequest(id: requestId, matchId: matchId, status: 'APPROVED');
  }
}
