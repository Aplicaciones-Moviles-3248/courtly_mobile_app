import '../../../../shared/infrastructure/http/api_client.dart';
import '../models/notification_model.dart';

class NotificationRemoteDataSource {
  final ApiClient apiClient;

  NotificationRemoteDataSource(this.apiClient);

  Future<List<NotificationModel>> getMyNotifications() async {
    final list = await apiClient.getList('/notifications/me');
    return list
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
