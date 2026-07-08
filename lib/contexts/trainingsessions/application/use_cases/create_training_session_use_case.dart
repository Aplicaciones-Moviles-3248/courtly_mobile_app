import '../../domain/entities/training_session.dart';
import '../../domain/repositories/training_session_repository.dart';

class CreateTrainingSessionUseCase {
  final TrainingSessionRepository repository;

  CreateTrainingSessionUseCase(this.repository);

  Future<TrainingSession> execute({
    required String playerId,
    required String coachId,
    required String courtId,
    required String availabilityId,
    required DateTime startTime,
    required DateTime endTime,
    required double price,
  }) {
    return repository.createTrainingSession(
      playerId: playerId,
      coachId: coachId,
      courtId: courtId,
      availabilityId: availabilityId,
      startTime: startTime,
      endTime: endTime,
      price: price,
    );
  }
}
