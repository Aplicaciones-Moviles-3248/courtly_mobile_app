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
    return repository.createReview(
      score: score,
      comment: comment,
      type: type,
      targetId: targetId,
      targetType: targetType,
      userId: userId,
      bookingId: bookingId,
      trainingSessionId: trainingSessionId,
    );
  }
}