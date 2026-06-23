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
    final user  = json['user']  as Map<String, dynamic>? ?? {};
    final court = json['court'] as Map<String, dynamic>? ?? {};

    return BookingModel(
      id:        json['id'].toString(),
      courtId:   (court['id'] ?? '').toString(),
      courtName: court['name'] as String? ?? 'Cancha',
      userId:    (user['id'] ?? '').toString(),
      userName:  user['name'] as String? ?? '',
      startTime: DateTime.parse(json['startTime'] as String),
      endTime:   DateTime.parse(json['endTime']   as String),
      status:    BookingStatus.fromString(json['status'] as String? ?? ''),
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
      'endTime':   _fmt(endTime),
      'userId':  int.tryParse(userId)  ?? userId,
      'courtId': int.tryParse(courtId) ?? courtId,
    };
  }

  static String _fmt(DateTime dt) {
    String p(int n) => n.toString().padLeft(2, '0');

    return '${dt.year}-${p(dt.month)}-${p(dt.day)}T${p(dt.hour)}:${p(dt.minute)}:00';
  }
}