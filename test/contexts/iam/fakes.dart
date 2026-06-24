import 'package:courtly_mobile_app/contexts/iam/domain/entities/authenticated_user.dart';
import 'package:courtly_mobile_app/contexts/iam/domain/repositories/authentication_repository.dart';
import 'package:courtly_mobile_app/contexts/iam/infrastructure/datasources/authentication_remote_data_source.dart';
import 'package:courtly_mobile_app/contexts/iam/infrastructure/models/authenticated_user_model.dart';
import 'package:courtly_mobile_app/shared/infrastructure/http/api_client.dart';
import 'package:courtly_mobile_app/shared/infrastructure/storage/local_storage_service.dart';

/// Repositorio falso para probar los casos de uso de forma aislada.
class FakeAuthenticationRepository implements AuthenticationRepository {
  AuthenticatedUser signInResult = const AuthenticatedUser(
    id: 1,
    username: 'tester',
    token: 'token-123',
  );
  int signUpResult = 42;
  bool sessionActive = false;
  bool signOutCalled = false;

  String? lastUsername;
  String? lastPassword;
  List<String>? lastRoles;

  @override
  Future<AuthenticatedUser> signIn(String username, String password) async {
    lastUsername = username;
    lastPassword = password;
    return signInResult;
  }

  @override
  Future<int> signUp(String username, String password, List<String> roles) async {
    lastUsername = username;
    lastPassword = password;
    lastRoles = roles;
    return signUpResult;
  }

  @override
  Future<bool> hasActiveSession() async => sessionActive;

  @override
  Future<void> signOut() async {
    signOutCalled = true;
    sessionActive = false;
  }
}

/// Datasource falso que no toca la red, para probar el repositorio real.
class FakeAuthenticationRemoteDataSource
    extends AuthenticationRemoteDataSource {
  FakeAuthenticationRemoteDataSource()
      : super(ApiClient(LocalStorageService()));

  AuthenticatedUserModel signInResult = const AuthenticatedUserModel(
    id: 7,
    username: 'remote-user',
    token: 'remote-token',
  );
  int signUpResult = 99;

  @override
  Future<AuthenticatedUserModel> signIn(String username, String password) async {
    return signInResult;
  }

  @override
  Future<int> signUp(String username, String password, List<String> roles) async {
    return signUpResult;
  }
}
