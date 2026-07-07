import '../../domain/entities/match_join_request.dart';
import '../../domain/repositories/match_repository.dart';

class GetMatchJoinRequestUseCase {
  final MatchRepository repository;

  GetMatchJoinRequestUseCase(this.repository);

  Future<MatchJoinRequest> execute(String matchId, String requestId) {
    return repository.getJoinRequest(matchId, requestId);
  }
}
