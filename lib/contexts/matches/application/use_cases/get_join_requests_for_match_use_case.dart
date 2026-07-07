import '../../domain/entities/match_join_request.dart';
import '../../domain/repositories/match_repository.dart';

class GetJoinRequestsForMatchUseCase {
  final MatchRepository repository;

  GetJoinRequestsForMatchUseCase(this.repository);

  Future<List<MatchJoinRequest>> execute(String matchId) {
    return repository.getJoinRequestsForMatch(matchId);
  }
}
