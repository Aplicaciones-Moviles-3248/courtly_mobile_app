import '../../domain/entities/match.dart';
import '../../domain/repositories/match_repository.dart';

class GetAllMatchesUseCase {
  final MatchRepository repository;

  GetAllMatchesUseCase(this.repository);

  Future<List<Match>> execute() {
    return repository.getAllMatches();
  }
}
