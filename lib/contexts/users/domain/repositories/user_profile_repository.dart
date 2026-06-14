import '../entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<UserProfile> getMyProfile();

  Future<UserProfile> updateProfile(UserProfile profile);
}