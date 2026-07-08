import '../../domain/entities/training_availability.dart';

class TrainingAvailabilityModel extends TrainingAvailability {
  const TrainingAvailabilityModel({
    required super.id,
    required super.startDateTime,
    required super.endDateTime,
    required super.status,
    required super.coachId,
    required super.coachName,
  });

  factory TrainingAvailabilityModel.fromJson(Map<String, dynamic> json) {
    final coach = json['coach'] as Map<String, dynamic>? ?? {};
    final date = json['date'] as String? ?? '';
    final startTime = json['startTime'] as String? ?? '00:00:00';
    final endTime = json['endTime'] as String? ?? '00:00:00';

    return TrainingAvailabilityModel(
      id: '${json['id'] ?? ''}',
      startDateTime: DateTime.parse('${date}T$startTime'),
      endDateTime: DateTime.parse('${date}T$endTime'),
      status: json['status'] as String? ?? '',
      coachId: '${coach['id'] ?? ''}',
      coachName: coach['name'] as String? ?? 'Coach',
    );
  }
}
