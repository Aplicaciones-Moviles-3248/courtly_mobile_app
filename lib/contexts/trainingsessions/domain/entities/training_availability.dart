class TrainingAvailability {
  final String id;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String status;
  final String coachId;
  final String coachName;

  const TrainingAvailability({
    required this.id,
    required this.startDateTime,
    required this.endDateTime,
    required this.status,
    required this.coachId,
    required this.coachName,
  });
}
