import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/user_profile_remote_data_source.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource dataSource;

  UserProfileRepositoryImpl(this.dataSource);

  @override
  Future<UserProfile> getMyProfile() {
    return dataSource.getMyProfile();
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) {
    return dataSource.updateProfile(profile);
  }
}