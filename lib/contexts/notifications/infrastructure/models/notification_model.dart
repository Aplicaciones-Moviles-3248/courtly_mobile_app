import '../../domain/entities/notification.dart';
import '../../domain/value_objects/notification_type.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.type,
    required super.isRead,
    required super.relatedEntityType,
    required super.relatedEntityId,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: NotificationTypeMapper.fromString(json['type'] ?? ''),
      isRead: json['read'] ?? json['isRead'] ?? false,
      relatedEntityType: json['relatedEntityType'],
      relatedEntityId: json['relatedEntityId']?.toString(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
