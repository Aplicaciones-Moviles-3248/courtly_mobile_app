import '../../domain/entities/match.dart';
import '../../domain/repositories/match_repository.dart';

class CreateMatchUseCase {
  final MatchRepository repository;

  CreateMatchUseCase(this.repository);

  Future<Match> execute({
    required String title,
    required String description,
    required DateTime dateTime,
    required int maxPlayers,
    required int courtId,
    required int createdById,
  }) {
    return repository.createMatch(
      title: title,
      description: description,
      dateTime: dateTime,
      maxPlayers: maxPlayers,
      courtId: courtId,
      createdById: createdById,
    );
  }
}
