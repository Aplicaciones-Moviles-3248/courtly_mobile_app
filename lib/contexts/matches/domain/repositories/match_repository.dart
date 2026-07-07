import '../entities/match.dart';

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
}
