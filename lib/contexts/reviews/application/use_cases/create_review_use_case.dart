import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';

class CreateReviewUseCase {
  final ReviewRepository repository;

  CreateReviewUseCase(this.repository);

  Future<Review> execute({
    required int score,
    required String comment,
    required String type,
    required int targetId,
    required String targetType,
    required int userId,
    required int bookingId,
    required int trainingSessionId,
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
      type: type,
      targetId: targetId,
      targetType: targetType,
      userId: userId,
      bookingId: bookingId,
      trainingSessionId: trainingSessionId,
    );
  }
}