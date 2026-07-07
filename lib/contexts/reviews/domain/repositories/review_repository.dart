import '../entities/review.dart';

abstract class ReviewRepository {
  Future<List<Review>> getReviews();

  Future<Review> createReview({
    required int score,
    required String comment,
    required String courtId,
    required String userId,
    required String bookingId,
  });
}
