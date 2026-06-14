import '../entities/authenticated_user.dart';

abstract class AuthenticationRepository {
  Future<AuthenticatedUser> signIn(String username, String password);

  Future<int> signUp(String username, String password, List<String> roles);
}