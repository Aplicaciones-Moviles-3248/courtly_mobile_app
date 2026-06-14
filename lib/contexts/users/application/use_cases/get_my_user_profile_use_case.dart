import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';

class GetMyUserProfileUseCase {
  final UserProfileRepository repository;

  GetMyUserProfileUseCase(this.repository);

  Future<UserProfile> execute() {
    return repository.getMyProfile();
  }
}