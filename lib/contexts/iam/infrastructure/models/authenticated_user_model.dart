import '../../domain/entities/authenticated_user.dart';

class AuthenticatedUserModel extends AuthenticatedUser {
  const AuthenticatedUserModel({
    required super.id,
    required super.username,
    required super.token,
  });

  factory AuthenticatedUserModel.fromJson(Map<String, dynamic> json) {
    return AuthenticatedUserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      token: json['token'] ?? json['accessToken'] ?? json['jwt'] ?? '',
    );
  }
}
