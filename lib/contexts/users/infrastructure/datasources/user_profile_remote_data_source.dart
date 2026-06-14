import '../../domain/entities/user_profile.dart';
import '../models/user_profile_model.dart';
import '../../../../shared/infrastructure/http/api_client.dart';

class UserProfileRemoteDataSource {
  final ApiClient apiClient;

  UserProfileRemoteDataSource(this.apiClient);

  Future<UserProfileModel> getMyProfile() async {
    final json = await apiClient.get('/user-profiles/me');
    return UserProfileModel.fromJson(json);
  }

  Future<UserProfileModel> updateProfile(UserProfile profile) async {
    final model = UserProfileModel(
      id: profile.id,
      name: profile.name,
      email: profile.email,
      phone: profile.phone,
      imageUrl: profile.imageUrl,
      userId: profile.userId,
    );

    final json = await apiClient.put(
      '/user-profiles/${profile.id}',
      model.toUpdateJson(),
    );

    return UserProfileModel.fromJson(json);
  }
}