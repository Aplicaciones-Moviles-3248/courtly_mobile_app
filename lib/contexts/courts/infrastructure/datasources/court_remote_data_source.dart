import '../../../../shared/infrastructure/http/api_client.dart';
import '../models/court_model.dart';

class CourtRemoteDataSource {
  final ApiClient apiClient;

  CourtRemoteDataSource(this.apiClient);

  Future<List<CourtModel>> getCourts() async {
    final jsonList = await apiClient.getList('/courts');

    return jsonList
        .map((json) => CourtModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<CourtModel> getCourtById(String courtId) async {
    final json = await apiClient.get('/courts/$courtId');

    return CourtModel.fromJson(json);
  }
}