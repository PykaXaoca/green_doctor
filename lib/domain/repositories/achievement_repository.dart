import '../../core/database/database.dart';

abstract class AchievementRepository {
  Future<List<Achievement>> getAll();
  Future<Achievement?> getByCode(String code);
  Future<void> insertAll(List<AchievementsCompanion> items);
}
