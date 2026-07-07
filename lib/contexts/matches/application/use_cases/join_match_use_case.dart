import '../../domain/entities/match.dart';
import '../../domain/repositories/match_repository.dart';

class JoinMatchUseCase {
  final MatchRepository repository;

  JoinMatchUseCase(this.repository);

  Future<Match> execute(String matchId) {
    return repository.joinMatch(matchId);
  }
}
