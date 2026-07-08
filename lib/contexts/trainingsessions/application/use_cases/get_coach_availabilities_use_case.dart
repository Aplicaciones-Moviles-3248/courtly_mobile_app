import '../../domain/entities/training_availability.dart';
import '../../domain/repositories/training_session_repository.dart';

class GetCoachAvailabilitiesUseCase {
  final TrainingSessionRepository repository;

  GetCoachAvailabilitiesUseCase(this.repository);

  Future<List<TrainingAvailability>> execute(String coachId) =>
      repository.getCoachAvailabilities(coachId);
}
