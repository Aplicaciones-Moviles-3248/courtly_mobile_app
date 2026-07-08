import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';

class CreateReviewUseCase {
  final ReviewRepository repository;

  CreateReviewUseCase(this.repository);

  Future<Review> execute({
    required int score,
    required String comment,
    required String targetType,
    required String targetId,
    required String userId,
    String? bookingId,
    String? trainingSessionId,
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
      targetType: targetType,
      targetId: targetId,
      userId: userId,
      bookingId: bookingId,
      trainingSessionId: trainingSessionId,
    );
  }
}
