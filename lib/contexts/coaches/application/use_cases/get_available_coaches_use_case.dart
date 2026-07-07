import '../../domain/entities/coach.dart';
import '../../domain/repositories/coach_repository.dart';

class GetAvailableCoachesUseCase {
  final CoachRepository repository;

  GetAvailableCoachesUseCase(this.repository);

  Future<List<Coach>> execute() {
    return repository.getAvailableCoaches();
  }
}