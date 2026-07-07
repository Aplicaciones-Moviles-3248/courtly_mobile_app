import '../../domain/entities/booking.dart';
import '../../domain/value_objects/booking_status.dart';

class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.courtId,
    required super.courtName,
    required super.userId,
    required super.userName,
    required super.startTime,
    required super.endTime,
    required super.status,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final court = json['court'] as Map<String, dynamic>? ?? {};

    return BookingModel(
      id: json['id'].toString(),
      courtId: (court['id'] ?? json['courtId'] ?? '').toString(),
      courtName: court['name'] as String? ?? 'Cancha',
      userId: (user['id'] ?? json['userId'] ?? '').toString(),
      userName: (user['name'] ?? user['username'] ?? '').toString(),
      startTime: _parseDateTime(json['startTime']),
      endTime: _parseDateTime(json['endTime']),
      status: BookingStatus.fromString(json['status'] as String? ?? ''),
    );
  }

  static Map<String, dynamic> toCreateJson({
    required DateTime startTime,
    required DateTime endTime,
    required String userId,
    required String courtId,
  }) {
    return {
      'startTime': _fmt(startTime),
      'endTime': _fmt(endTime),
      'userId': int.tryParse(userId) ?? userId,
      'courtId': int.tryParse(courtId) ?? courtId,
    };
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return DateTime.tryParse(value.toString()) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  static String _fmt(DateTime dt) {
    String p(int n) => n.toString().padLeft(2, '0');

    return '${dt.year}-${p(dt.month)}-${p(dt.day)}T${p(dt.hour)}:${p(dt.minute)}:00';
  }
}
