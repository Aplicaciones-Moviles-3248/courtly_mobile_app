import '../../domain/entities/training_court.dart';
import '../../domain/repositories/training_session_repository.dart';

class GetTrainingCourtsUseCase {
  final TrainingSessionRepository repository;

  GetTrainingCourtsUseCase(this.repository);

  Future<List<TrainingCourt>> execute() => repository.getCourts();
}
