import '../../domain/repositories/authentication_repository.dart';

class SignUpUseCase {
  final AuthenticationRepository repository;

  SignUpUseCase(this.repository);

  Future<int> execute(String username, String password, List<String> roles) {
    return repository.signUp(username, password, roles);
  }
}