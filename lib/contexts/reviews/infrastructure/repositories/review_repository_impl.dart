import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_data_source.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource dataSource;

  ReviewRepositoryImpl(this.dataSource);

  @override
  Future<List<Review>> getReviews() => dataSource.getReviews();

  @override
  Future<Review> createReview({
    required int score,
    required String comment,
    required String courtId,
    required String userId,
    required String bookingId,
  }) => dataSource.createReview(
    score: score,
    comment: comment,
    courtId: courtId,
    userId: userId,
    bookingId: bookingId,
  );
}
