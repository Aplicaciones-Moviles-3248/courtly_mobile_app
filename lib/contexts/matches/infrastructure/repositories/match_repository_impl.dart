import '../../domain/entities/match.dart';
import '../../domain/entities/match_join_request.dart';
import '../../domain/repositories/match_repository.dart';
import '../datasources/match_remote_data_source.dart';

class MatchRepositoryImpl implements MatchRepository {
  final MatchRemoteDataSource remoteDataSource;

  MatchRepositoryImpl(this.remoteDataSource);

  @override
  Future<Match> createMatch({
    required String title,
    required String description,
    required DateTime dateTime,
    required int maxPlayers,
    required int courtId,
    required int createdById,
  }) {
    return remoteDataSource.createMatch(
      title: title,
      description: description,
      dateTime: dateTime,
      maxPlayers: maxPlayers,
      courtId: courtId,
      createdById: createdById,
    );
  }

  @override
  Future<List<Match>> getAllMatches() {
    return remoteDataSource.getAllMatches().then((list) => list.cast<Match>());
  }

  @override
  Future<Match> joinMatch(String matchId) {
    return remoteDataSource.joinMatch(matchId);
  }

  @override
  Future<MatchJoinRequest> createJoinRequest(String matchId) {
    return remoteDataSource.createJoinRequest(matchId);
  }

  @override
  Future<List<MatchJoinRequest>> getJoinRequestsForMatch(String matchId) {
    return remoteDataSource
        .getJoinRequestsForMatch(matchId)
        .then((list) => list.cast<MatchJoinRequest>());
  }

  @override
  Future<MatchJoinRequest> getJoinRequest(String matchId, String requestId) {
    return remoteDataSource.getJoinRequest(matchId, requestId);
  }

  @override
  Future<MatchJoinRequest> approveJoinRequest(String matchId, String requestId) {
    return remoteDataSource.approveJoinRequest(matchId, requestId);
  }
}
