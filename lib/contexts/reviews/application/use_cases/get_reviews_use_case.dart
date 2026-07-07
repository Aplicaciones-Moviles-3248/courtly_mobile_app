import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';

class GetReviewsUseCase {
  final ReviewRepository repository;

  GetReviewsUseCase(this.repository);

  Future<List<Review>> execute() => repository.getReviews();
}
