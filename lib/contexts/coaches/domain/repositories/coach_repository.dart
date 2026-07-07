import '../entities/coach.dart';

abstract class CoachRepository {
  Future<List<Coach>> getAvailableCoaches();
}