import '../../../../shared/infrastructure/http/api_client.dart';
import '../models/notification_count_model.dart';
import '../models/notification_model.dart';

class NotificationRemoteDataSource {
  final ApiClient apiClient;

  NotificationRemoteDataSource(this.apiClient);

  Future<List<NotificationModel>> getMyNotifications() async {
    final response = await apiClient.getList('/notifications/me');
    return response.map((json) => NotificationModel.fromJson(json)).toList();
  }

  Future<NotificationCountModel> getUnreadCount() async {
    final response =
    await apiClient.get('/notifications/me/unread-count');
    return NotificationCountModel.fromJson(response);
  }

  Future<void> markAsRead(String notificationId) async {
    await apiClient.post('/notifications/$notificationId/read', {},);
  }

  Future<void> deleteNotification(String notificationId) async {
    await apiClient.delete('/notifications/$notificationId',);
  }
}
