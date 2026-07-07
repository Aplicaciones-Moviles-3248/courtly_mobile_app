import '../../../../shared/infrastructure/http/api_client.dart';
import '../models/coach_model.dart';

class CoachRemoteDataSource {
  final ApiClient apiClient;

  CoachRemoteDataSource(this.apiClient);

  Future<List<CoachModel>> getAvailableCoaches() async {
    final coachesJson = await apiClient.getList('/coaches');
    final availabilitiesJson = await apiClient.getList('/availabilities');

    final availableSlotsByCoachId = <String, int>{};

    for (final item in availabilitiesJson) {
      final availability = item as Map<String, dynamic>;
      final status = availability['status']?.toString().toUpperCase();

      if (status != 'AVAILABLE') {
        continue;
      }

      final coach = availability['coach'];

      if (coach is! Map<String, dynamic>) {
        continue;
      }

      final coachId = coach['id']?.toString();

      if (coachId == null) {
        continue;
      }

      availableSlotsByCoachId[coachId] =
          (availableSlotsByCoachId[coachId] ?? 0) + 1;
    }

    final coaches = coachesJson
        .map((json) => CoachModel.fromJson(json as Map<String, dynamic>))
        .where((coach) => availableSlotsByCoachId.containsKey(coach.id))
        .map(
          (coach) => coach.copyWith(
        availableSlots: availableSlotsByCoachId[coach.id] ?? 0,
      ),
    )
        .toList();

    return coaches;
  }
}