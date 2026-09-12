import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';

part 'achievement_dao.g.dart';

@DriftAccessor(tables: [Achievements])
class AchievementDao extends DatabaseAccessor<AppDatabase>
    with _$AchievementDaoMixin {
  AchievementDao(super.db);

  Future<List<Achievement>> getAll() => select(achievements).get();

  Future<Achievement?> getByCode(String code) => (select(
    achievements,
  )..where((t) => t.code.equals(code))).getSingleOrNull();

  Future<void> insertAll(List<AchievementsCompanion> items) async {
    await batch((b) => b.insertAllOnConflictUpdate(achievements, items));
  }
}
