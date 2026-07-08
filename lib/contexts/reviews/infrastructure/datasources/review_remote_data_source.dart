import '../../../../shared/infrastructure/http/api_client.dart';
import '../models/review_model.dart';

class ReviewRemoteDataSource {
  final ApiClient apiClient;

  ReviewRemoteDataSource(this.apiClient);

  Future<List<ReviewModel>> getReviews() async {
    final list = await apiClient.getList('/reviews');

    return list
        .map((json) => ReviewModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<ReviewModel> createReview({
    required int score,
    required String comment,
    required String type,
    required int targetId,
    required String targetType,
    required int userId,
    required int bookingId,
    required int trainingSessionId,
  }) async {
    final json = await apiClient.post('/reviews', {
      'score': score,
      'comment': comment,
      'type': type,
      'targetId': targetId,
      'targetType': targetType,
      'userId': userId,
      'bookingId': bookingId,
      'trainingSessionId': trainingSessionId,
    });

    return ReviewModel.fromJson(json);
  }
}