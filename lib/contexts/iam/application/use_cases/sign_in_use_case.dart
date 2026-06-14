import '../../domain/entities/authenticated_user.dart';
import '../../domain/repositories/authentication_repository.dart';

class SignInUseCase {
  final AuthenticationRepository repository;

  SignInUseCase(this.repository);

  Future<AuthenticatedUser> execute(String username, String password) {
    return repository.signIn(username, password);
  }
}