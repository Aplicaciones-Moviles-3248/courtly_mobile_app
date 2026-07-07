import '../../domain/entities/notification_count.dart';

class NotificationCountModel extends NotificationCount {
  const NotificationCountModel({
    required super.userId,
    required super.unreadCount,
  });

  factory NotificationCountModel.fromJson(Map<String, dynamic> json) {
    return NotificationCountModel(
      userId: json['userId'].toString(),
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}