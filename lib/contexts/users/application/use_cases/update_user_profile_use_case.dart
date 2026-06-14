import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';

class UpdateUserProfileUseCase {
  final UserProfileRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<UserProfile> execute(UserProfile profile) {
    return repository.updateProfile(profile);
  }
}