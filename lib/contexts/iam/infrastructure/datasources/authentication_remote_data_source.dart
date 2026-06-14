import '../../../../shared/infrastructure/http/api_client.dart';
import '../models/authenticated_user_model.dart';

class AuthenticationRemoteDataSource {
  final ApiClient apiClient;

  AuthenticationRemoteDataSource(this.apiClient);

  Future<AuthenticatedUserModel> signIn(String username, String password) async {
    final json = await apiClient.post(
      '/authentication/sign-in',
      {
        'username': username,
        'password': password,
      },
    );

    return AuthenticatedUserModel.fromJson(json);
  }

  Future<int> signUp(String username, String password, List<String> roles) async {
    final json = await apiClient.post(
      '/authentication/sign-up',
      {
        'username': username,
        'password': password,
        'roles': roles,
      },
    );

    return json['id'] ?? 0;
  }
}