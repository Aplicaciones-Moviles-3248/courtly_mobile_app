import '../../domain/entities/court.dart';
import '../../domain/repositories/court_repository.dart';
import '../datasources/court_remote_data_source.dart';

class CourtRepositoryImpl implements CourtRepository {
  final CourtRemoteDataSource dataSource;

  CourtRepositoryImpl(this.dataSource);

  @override
  Future<List<Court>> getCourts() {
    return dataSource.getCourts();
  }

  @override
  Future<Court> getCourtById(String courtId) {
    return dataSource.getCourtById(courtId);
  }
}