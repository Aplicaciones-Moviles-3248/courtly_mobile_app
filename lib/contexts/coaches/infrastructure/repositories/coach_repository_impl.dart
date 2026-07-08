import '../../domain/entities/coach.dart';
import '../../domain/repositories/coach_repository.dart';
import '../datasources/coach_remote_data_source.dart';

class CoachRepositoryImpl implements CoachRepository {
  final CoachRemoteDataSource dataSource;

  CoachRepositoryImpl(this.dataSource);

  @override
  Future<List<Coach>> getAvailableCoaches() {
    return dataSource.getAvailableCoaches();
  }
}