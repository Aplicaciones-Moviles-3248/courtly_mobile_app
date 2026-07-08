import '../entities/review.dart';

abstract class ReviewRepository {
  Future<List<Review>> getReviews();

  Future<Review> createReview({
    required int score,
    required String comment,
    required String targetType,
    required String targetId,
    required String userId,
    String? bookingId,
    String? trainingSessionId,
  });
}
