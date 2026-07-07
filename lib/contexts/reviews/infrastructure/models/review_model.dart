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
    required super.userName,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];

    return ReviewModel(
      id: json['id']?.toString() ?? '',
      score: _toInt(json['score']),
      comment: json['comment']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      targetId: _toInt(json['targetId']),
      targetType: json['targetType']?.toString() ?? '',
      bookingId: _toInt(json['bookingId']),
      trainingSessionId: _toInt(json['trainingSessionId']),
      createdAt: json['createdAt']?.toString() ?? '',
      userName: user is Map<String, dynamic>
          ? user['name']?.toString() ?? 'Usuario'
          : 'Usuario',
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}