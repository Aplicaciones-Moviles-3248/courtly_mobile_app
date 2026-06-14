class AuthenticatedUser {
  final int id;
  final String username;
  final String token;

  const AuthenticatedUser({
    required this.id,
    required this.username,
    required this.token,
  });
}