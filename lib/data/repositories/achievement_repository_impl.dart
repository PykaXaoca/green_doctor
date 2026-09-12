import '../../core/database/database.dart';
import '../../domain/repositories/achievement_repository.dart';

class AchievementRepositoryImpl implements AchievementRepository {
  AchievementRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<Achievement>> getAll() => _db.achievementDao.getAll();

  @override
  Future<Achievement?> getByCode(String code) =>
      _db.achievementDao.getByCode(code);

  @override
  Future<void> insertAll(List<AchievementsCompanion> items) =>
      _db.achievementDao.insertAll(items);
}
