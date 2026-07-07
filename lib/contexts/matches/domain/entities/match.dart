import '../../../users/domain/entities/user_profile.dart';

class Match {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String status;
  final int maxPlayers;
  final int currentPlayers;
  final String courtId;
  final String courtName;
  final UserProfile createdBy;
  final List<UserProfile> participants;

  const Match({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.status,
    required this.maxPlayers,
    required this.currentPlayers,
    required this.courtId,
    required this.courtName,
    required this.createdBy,
    required this.participants,
  });
}
