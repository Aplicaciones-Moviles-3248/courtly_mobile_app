import '../../../../shared/infrastructure/storage/local_storage_service.dart';
import '../../domain/entities/authenticated_user.dart';
import '../../domain/repositories/authentication_repository.dart';
import '../datasources/authentication_remote_data_source.dart';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final AuthenticationRemoteDataSource dataSource;
  final LocalStorageService localStorageService;

  AuthenticationRepositoryImpl({
    required this.dataSource,
    required this.localStorageService,
  });

  @override
  Future<AuthenticatedUser> signIn(String username, String password) async {
    final authenticatedUser = await dataSource.signIn(username, password);
    await localStorageService.saveToken(authenticatedUser.token);
    return authenticatedUser;
  }

  @override
  Future<int> signUp(String username, String password, List<String> roles) {
    return dataSource.signUp(username, password, roles);
  }
}