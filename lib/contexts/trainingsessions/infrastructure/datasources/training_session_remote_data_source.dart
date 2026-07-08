import '../../../../shared/infrastructure/http/api_client.dart';
import '../models/training_availability_model.dart';
import '../models/training_court_model.dart';
import '../models/training_session_model.dart';

class TrainingSessionRemoteDataSource {
  final ApiClient apiClient;

  TrainingSessionRemoteDataSource(this.apiClient);

  Future<String> getCurrentPlayerProfileId() async {
    final json = await apiClient.get('/user-profiles/me');
    return '${json['id'] ?? ''}';
  }

  Future<List<TrainingAvailabilityModel>> getCoachAvailabilities(
    String coachId,
  ) async {
    final list = await apiClient.getList('/availabilities');

    return list
        .map((json) => TrainingAvailabilityModel.fromJson(json as Map<String, dynamic>))
        .where((availability) =>
            availability.coachId == coachId &&
            availability.status.toUpperCase() == 'AVAILABLE')
        .toList()
      ..sort((left, right) => left.startDateTime.compareTo(right.startDateTime));
  }

  Future<List<TrainingCourtModel>> getCourts() async {
    final list = await apiClient.getList('/courts');

    return list
        .map((json) => TrainingCourtModel.fromJson(json as Map<String, dynamic>))
        .toList()
      ..sort((left, right) => left.pricePerHour.compareTo(right.pricePerHour));
  }

  Future<TrainingSessionModel> createTrainingSession({
    required String playerId,
    required String coachId,
    required String courtId,
    required String availabilityId,
    required DateTime startTime,
    required DateTime endTime,
    required double price,
  }) async {
    final json = await apiClient.post(
      '/training-sessions',
      TrainingSessionModel.toCreateJson(
        playerId: playerId,
        coachId: coachId,
        courtId: courtId,
        availabilityId: availabilityId,
        startTime: startTime,
        endTime: endTime,
        price: price,
      ),
    );

    return TrainingSessionModel.fromJson(json);
  }
}
