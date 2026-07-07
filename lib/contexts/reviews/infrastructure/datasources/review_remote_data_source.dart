import '../../../../shared/infrastructure/http/api_client.dart';
import '../models/review_model.dart';

class ReviewRemoteDataSource {
  final ApiClient apiClient;

  ReviewRemoteDataSource(this.apiClient);

  Future<List<ReviewModel>> getReviews() async {
    final list = await apiClient.getList('/reviews');

    return list
        .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ReviewModel> createReview({
    required int score,
    required String comment,
    required String courtId,
    required String userId,
    required String bookingId,
  }) async {
    final body = ReviewModel.toCreateJson(
      score: score,
      comment: comment,
      courtId: courtId,
      userId: userId,
      bookingId: bookingId,
    );

    final json = await apiClient.post('/reviews', body);

    return ReviewModel.fromJson(json);
  }
}
