class Review {
  final String id;
  final int score;
  final String comment;
  final String type;
  final String targetId;
  final String targetType;
  final String? bookingId;
  final String? trainingSessionId;
  final DateTime? createdAt;
  final String userId;
  final String userName;

  const Review({
    required this.id,
    required this.score,
    required this.comment,
    required this.type,
    required this.targetId,
    required this.targetType,
    required this.bookingId,
    required this.trainingSessionId,
    required this.createdAt,
    required this.userId,
    required this.userName,
  });
}
