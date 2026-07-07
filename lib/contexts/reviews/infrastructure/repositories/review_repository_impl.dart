import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_data_source.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource dataSource;

  ReviewRepositoryImpl(this.dataSource);

  @override
  Future<List<Review>> getReviews() {
    return dataSource.getReviews();
  }

  @override
  Future<Review> createReview({
    required int score,
    required String comment,
    required String type,
    required int targetId,
    required String targetType,
    required int userId,
    required int bookingId,
    required int trainingSessionId,
  }) {
    return dataSource.createReview(
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