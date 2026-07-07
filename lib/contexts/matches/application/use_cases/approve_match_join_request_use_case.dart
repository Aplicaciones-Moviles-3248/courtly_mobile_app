import '../../domain/entities/match_join_request.dart';
import '../../domain/repositories/match_repository.dart';

class ApproveMatchJoinRequestUseCase {
  final MatchRepository repository;

  ApproveMatchJoinRequestUseCase(this.repository);

  Future<MatchJoinRequest> execute(String matchId, String requestId) {
    return repository.approveJoinRequest(matchId, requestId);
  }
}
