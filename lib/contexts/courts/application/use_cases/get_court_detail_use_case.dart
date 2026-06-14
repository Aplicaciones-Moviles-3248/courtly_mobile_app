import '../../domain/entities/court.dart';
import '../../domain/repositories/court_repository.dart';

class GetCourtDetailUseCase {
  final CourtRepository repository;

  GetCourtDetailUseCase(this.repository);

  Future<Court> execute(String courtId) {
    return repository.getCourtById(courtId);
  }
}