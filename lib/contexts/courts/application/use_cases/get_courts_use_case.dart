import '../../domain/entities/court.dart';
import '../../domain/repositories/court_repository.dart';

class GetCourtsUseCase {
  final CourtRepository repository;

  GetCourtsUseCase(this.repository);

  Future<List<Court>> execute() {
    return repository.getCourts();
  }
}