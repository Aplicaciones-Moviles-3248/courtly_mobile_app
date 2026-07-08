import '../../domain/entities/training_session.dart';

class TrainingSessionModel extends TrainingSession {
  const TrainingSessionModel({
    required super.id,
    required super.startTime,
    required super.endTime,
    required super.status,
    required super.price,
    required super.playerName,
    required super.coachName,
    required super.courtName,
    required super.availabilityId,
  });

  factory TrainingSessionModel.fromJson(Map<String, dynamic> json) {
    final player = json['player'] as Map<String, dynamic>? ?? {};
    final coach = json['coach'] as Map<String, dynamic>? ?? {};
    final court = json['court'] as Map<String, dynamic>? ?? {};

    return TrainingSessionModel(
      id: '${json['id'] ?? ''}',
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      status: '${json['status'] ?? ''}',
      price: _toDouble(json['price']),
      playerName: player['name'] as String? ?? 'Jugador',
      coachName: coach['name'] as String? ?? 'Coach',
      courtName: court['name'] as String? ?? 'Cancha',
      availabilityId: '${json['availabilityId'] ?? ''}',
    );
  }

  static Map<String, dynamic> toCreateJson({
    required String playerId,
    required String coachId,
    required String courtId,
    required String availabilityId,
    required DateTime startTime,
    required DateTime endTime,
    required double price,
  }) {
    return {
      'playerId': int.parse(playerId),
      'coachId': int.parse(coachId),
      'courtId': int.parse(courtId),
      'availabilityId': int.parse(availabilityId),
      'startTime': _fmt(startTime),
      'endTime': _fmt(endTime),
      'price': price,
    };
  }

  static String _fmt(DateTime dt) {
    String p(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${p(dt.month)}-${p(dt.day)}T${p(dt.hour)}:${p(dt.minute)}:${p(dt.second)}';
  }

  static double _toDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse('${value ?? ''}') ?? 0;
  }
}
