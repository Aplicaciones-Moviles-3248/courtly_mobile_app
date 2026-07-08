import '../../domain/entities/training_availability.dart';
import '../../domain/entities/training_court.dart';
import '../../domain/entities/training_session.dart';
import '../../domain/repositories/training_session_repository.dart';
import '../datasources/training_session_remote_data_source.dart';

class TrainingSessionRepositoryImpl implements TrainingSessionRepository {
  final TrainingSessionRemoteDataSource dataSource;

  TrainingSessionRepositoryImpl(this.dataSource);

  @override
  Future<String> getCurrentPlayerProfileId() => dataSource.getCurrentPlayerProfileId();

  @override
  Future<List<TrainingAvailability>> getCoachAvailabilities(String coachId) =>
      dataSource.getCoachAvailabilities(coachId);

  @override
  Future<List<TrainingCourt>> getCourts() => dataSource.getCourts();

  @override
  Future<TrainingSession> createTrainingSession({
    required String playerId,
    required String coachId,
    required String courtId,
    required String availabilityId,
    required DateTime startTime,
    required DateTime endTime,
    required double price,
  }) {
    return dataSource.createTrainingSession(
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
