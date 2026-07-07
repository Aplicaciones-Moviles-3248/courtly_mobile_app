import '../entities/match.dart';
import '../entities/match_join_request.dart';

abstract class MatchRepository {
  Future<Match> createMatch({
    required String title,
    required String description,
    required DateTime dateTime,
    required int maxPlayers,
    required int courtId,
    required int createdById,
  });
  Future<List<Match>> getAllMatches();
  Future<Match> joinMatch(String matchId);
  Future<MatchJoinRequest> createJoinRequest(String matchId);
  Future<List<MatchJoinRequest>> getJoinRequestsForMatch(String matchId);
  Future<MatchJoinRequest> getJoinRequest(String matchId, String requestId);
  Future<MatchJoinRequest> approveJoinRequest(String matchId, String requestId);
}
