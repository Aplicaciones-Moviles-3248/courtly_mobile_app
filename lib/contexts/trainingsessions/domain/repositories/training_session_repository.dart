import '../entities/training_availability.dart';
import '../entities/training_court.dart';
import '../entities/training_session.dart';

abstract class TrainingSessionRepository {
  Future<String> getCurrentPlayerProfileId();

  Future<List<TrainingAvailability>> getCoachAvailabilities(String coachId);

  Future<List<TrainingCourt>> getCourts();

  Future<TrainingSession> createTrainingSession({
    required String playerId,
    required String coachId,
    required String courtId,
    required String availabilityId,
    required DateTime startTime,
    required DateTime endTime,
    required double price,
  });
}
