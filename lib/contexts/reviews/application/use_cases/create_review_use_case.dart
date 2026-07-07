import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';

class CreateReviewUseCase {
  final ReviewRepository repository;

  CreateReviewUseCase(this.repository);

  Future<Review> execute({
    required int score,
    required String comment,
    required String courtId,
    required String userId,
    required String bookingId,
  }) {
    if (score < 1 || score > 5) {
      throw ArgumentError('Score must be between 1 and 5.');
    }

    if (comment.trim().isEmpty) {
      throw ArgumentError('Comment must not be empty.');
    }

    return repository.createReview(
      score: score,
      comment: comment.trim(),
      courtId: courtId,
      userId: userId,
      bookingId: bookingId,
    );
  }
}
