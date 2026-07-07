import '../entities/review.dart';

abstract class ReviewRepository {
  Future<List<Review>> getReviews();

  Future<Review> createReview({
    required int score,
    required String comment,
    required String type,
    required int targetId,
    required String targetType,
    required int userId,
    required int bookingId,
    required int trainingSessionId,
  });
}