import '../../domain/repositories/training_session_repository.dart';

class GetCurrentPlayerProfileIdUseCase {
  final TrainingSessionRepository repository;

  GetCurrentPlayerProfileIdUseCase(this.repository);

  Future<String> execute() => repository.getCurrentPlayerProfileId();
}
