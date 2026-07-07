import '../../domain/entities/match.dart';
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
}
