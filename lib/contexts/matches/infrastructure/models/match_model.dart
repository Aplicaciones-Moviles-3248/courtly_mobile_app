import '../../../users/domain/entities/user_profile.dart';
import '../../domain/entities/match.dart';

class MatchModel extends Match {
  const MatchModel({
    required super.id,
    required super.title,
    required super.description,
    required super.dateTime,
    required super.status,
    required super.maxPlayers,
    required super.currentPlayers,
    required super.courtId,
    required super.courtName,
    required super.createdBy,
    required super.participants,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    final court = json['court'] as Map<String, dynamic>? ?? {};
    final createdByJson = json['createdBy'] as Map<String, dynamic>? ?? {};
    final participantsList = json['participants'] as List<dynamic>? ?? [];

    final createdBy = UserProfile(
      id: createdByJson['id'] as int? ?? 0,
      name: createdByJson['name'] as String? ?? '',
      email: '',
      phone: '',
      imageUrl: '',
    );

    final participants = participantsList.map((e) {
      final p = e as Map<String, dynamic>;
      return UserProfile(
        id: p['id'] as int? ?? 0,
        name: p['name'] as String? ?? '',
        email: '',
        phone: '',
        imageUrl: '',
      );
    }).toList();

    return MatchModel(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      dateTime: DateTime.parse(json['dateTime'] as String),
      status: json['status'] as String? ?? 'OPEN',
      maxPlayers: json['maxPlayers'] as int? ?? 0,
      currentPlayers: json['currentPlayers'] as int? ?? 0,
      courtId: (court['id'] ?? '').toString(),
      courtName: court['name'] as String? ?? 'Cancha',
      createdBy: createdBy,
      participants: participants,
    );
  }

  static Map<String, dynamic> toCreateJson({
    required String title,
    required String description,
    required DateTime dateTime,
    required int maxPlayers,
    required int courtId,
    required int createdById,
  }) {
    return {
      'title': title,
      'description': description,
      'dateTime': _fmt(dateTime),
      'status': 'OPEN',
      'maxPlayers': maxPlayers,
      'currentPlayers': 1,
      'courtId': courtId,
      'createdById': createdById,
    };
  }

  static String _fmt(DateTime dt) {
    String p(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${p(dt.month)}-${p(dt.day)}T${p(dt.hour)}:${p(dt.minute)}:00';
  }
}
