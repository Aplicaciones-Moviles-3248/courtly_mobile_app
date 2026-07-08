import '../../domain/entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.score,
    required super.comment,
    required super.type,
    required super.targetId,
    required super.targetType,
    required super.bookingId,
    required super.trainingSessionId,
    required super.createdAt,
    required super.userId,
    required super.userName,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final createdAtValue = json['createdAt'] as String?;

    return ReviewModel(
      id: (json['id'] ?? '').toString(),
      score: _asInt(json['score']),
      comment: json['comment'] as String? ?? '',
      type: json['type'] as String? ?? '',
      targetId: (json['targetId'] ?? '').toString(),
      targetType: json['targetType'] as String? ?? '',
      bookingId: json['bookingId']?.toString(),
      trainingSessionId: json['trainingSessionId']?.toString(),
      createdAt: createdAtValue == null
          ? null
          : DateTime.tryParse(createdAtValue),
      userId: (user['id'] ?? '').toString(),
      userName: user['name'] as String? ?? 'Jugador',
    );
  }

  static Map<String, dynamic> toCreateJson({
    required int score,
    required String comment,
    required String targetType,
    required String targetId,
    required String userId,
    String? bookingId,
    String? trainingSessionId,
  }) {
    return {
      'score': score,
      'comment': comment,
      'type': targetType,
      'targetId': int.tryParse(targetId) ?? targetId,
      'targetType': targetType,
      'userId': int.tryParse(userId) ?? userId,
      'bookingId': bookingId == null
          ? null
          : (int.tryParse(bookingId) ?? bookingId),
      'trainingSessionId': trainingSessionId == null
          ? null
          : (int.tryParse(trainingSessionId) ?? trainingSessionId),
    };
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return double.tryParse(value?.toString() ?? '')?.round() ?? 0;
  }
}
