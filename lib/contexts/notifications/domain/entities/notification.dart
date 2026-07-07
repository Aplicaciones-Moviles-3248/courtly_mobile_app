import '../value_objects/notification_type.dart';

class NotificationEntity {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final String? relatedEntityType;
  final String? relatedEntityId;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.relatedEntityType,
    required this.relatedEntityId,
    required this.createdAt,
  });

  NotificationEntity copyWith({
    bool? isRead,
  }) {
    return NotificationEntity(
      id: id,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      relatedEntityType: relatedEntityType,
      relatedEntityId: relatedEntityId,
      createdAt: createdAt,
    );
  }
}