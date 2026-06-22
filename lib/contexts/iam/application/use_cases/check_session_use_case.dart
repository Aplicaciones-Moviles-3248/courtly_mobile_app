import '../../domain/repositories/authentication_repository.dart';

class CheckSessionUseCase {
  final AuthenticationRepository repository;

  CheckSessionUseCase(this.repository);

  Future<bool> execute() {
    return repository.hasActiveSession();
  }
}
