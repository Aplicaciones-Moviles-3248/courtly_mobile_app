import '../../domain/entities/match_join_request.dart';
import '../../domain/repositories/match_repository.dart';

class CreateMatchJoinRequestUseCase {
  final MatchRepository repository;

  CreateMatchJoinRequestUseCase(this.repository);

  Future<MatchJoinRequest> execute(String matchId) {
    return repository.createJoinRequest(matchId);
  }
}
