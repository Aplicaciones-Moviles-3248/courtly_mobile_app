class TrainingSession {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final double price;
  final String playerName;
  final String coachName;
  final String courtName;
  final String availabilityId;

  const TrainingSession({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.price,
    required this.playerName,
    required this.coachName,
    required this.courtName,
    required this.availabilityId,
  });
}
