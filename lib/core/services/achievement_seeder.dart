import 'package:drift/drift.dart';

import '../data/achievements_catalog.dart';
import '../database/database.dart';

/// Сервис первичного заполнения таблицы achievements.
class AchievementSeeder {
  AchievementSeeder(this._db);

  final AppDatabase _db;

  static const String _metaKey = 'achievements_imported';

  Future<int> seedIfNeeded() async {
    final done = await _db.appMetaDao.getValue(_metaKey);
    if (done == 'true') return 0;
    return seed();
  }

  Future<int> seed() async {
    final companions = AchievementsCatalog.all.map((def) {
      return AchievementsCompanion(
        code: Value(def.code),
        name: Value(def.name),
        description: Value(def.description),
        iconAsset: Value(def.iconAsset),
        rewardXp: Value(def.rewardXp),
      );
    }).toList();

    await _db.achievementDao.insertAll(companions);
    await _db.appMetaDao.setValue(_metaKey, 'true');
    return companions.length;
  }
}
