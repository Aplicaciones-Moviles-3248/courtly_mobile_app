class UserProfile {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String imageUrl;
  final int? userId;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.imageUrl,
    this.userId,
  });

  UserProfile copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? imageUrl,
    int? userId,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      userId: userId ?? this.userId,
    );
  }
}