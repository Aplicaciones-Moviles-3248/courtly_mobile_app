import '../../../../shared/infrastructure/http/api_client.dart';
import '../models/match_model.dart';

class MatchRemoteDataSource {
  final ApiClient apiClient;

  MatchRemoteDataSource(this.apiClient);

  Future<MatchModel> createMatch({
    required String title,
    required String description,
    required DateTime dateTime,
    required int maxPlayers,
    required int courtId,
    required int createdById,
  }) async {
    final body = MatchModel.toCreateJson(
      title: title,
      description: description,
      dateTime: dateTime,
      maxPlayers: maxPlayers,
      courtId: courtId,
      createdById: createdById,
    );

    final json = await apiClient.post('/matches', body);
    return MatchModel.fromJson(json);
  }

  Future<List<MatchModel>> getAllMatches() async {
    final list = await apiClient.getList('/matches');
    return list.map((e) => MatchModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<MatchModel> joinMatch(String matchId) async {
    final json = await apiClient.post('/matches/$matchId/join', {});
    return MatchModel.fromJson(json);
  }
}
