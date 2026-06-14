import '../entities/court.dart';

abstract class CourtRepository {
  Future<List<Court>> getCourts();

  Future<Court> getCourtById(String courtId);
}