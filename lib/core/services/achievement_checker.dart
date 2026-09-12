import 'package:drift/drift.dart';

import '../data/achievements_catalog.dart';
import '../database/database.dart';
import 'gamification_service.dart';

/// Сервис проверки и разблокировки достижений для пользователя.
class AchievementChecker {
  AchievementChecker(this._db, this._gamification);

  final AppDatabase _db;
  final GamificationService _gamification;

  /// Проверяет все достижения и разблокирует те, условия которых выполнены.
  /// Возвращает список кодов только что разблокированных достижений.
  Future<List<String>> checkAll(int userId) async {
    final unlocked = <String>[];

    // Текущее состояние.
    final plants = await _db.plantDao.getByUser(userId);
    final allEvents = await _db.careEventDao.getRecent(10000);
    final user = await _db.userDao.getUserById(userId);
    final existing = await _db.userDao.getUserAchievements(userId);
    final existingCodes = existing.map((e) => e.achievementCode).toSet();

    final wateringCount = allEvents.where((e) => e.type == 'watering').length;
    final fertilizingCount = allEvents
        .where((e) => e.type == 'fertilizing')
        .length;
    final mistingCount = allEvents.where((e) => e.type == 'misting').length;
    final totalEvents = allEvents.length;
    final plantCount = plants.length;
    final level = user?.level ?? 1;

    Future<void> tryUnlock(
      AchievementCriterion criterion,
      bool Function() test,
    ) async {
      final def = AchievementsCatalog.all.firstWhere(
        (d) => d.criterion == criterion,
      );
      if (existingCodes.contains(def.code)) return;
      if (!test()) return;

      await _db.userDao.unlockAchievement(
        UserAchievementsCompanion(
          userId: Value(userId),
          achievementCode: Value(def.code),
        ),
      );
      existingCodes.add(def.code);
      unlocked.add(def.code);

      // Начисляем награду.
      await _gamification.addXp(
        userId: userId,
        amount: def.rewardXp,
        reason: 'achievement:${def.code}',
      );
    }

    await tryUnlock(AchievementCriterion.firstPlant, () => plantCount >= 1);
    await tryUnlock(AchievementCriterion.fivePlants, () => plantCount >= 5);
    await tryUnlock(AchievementCriterion.tenPlants, () => plantCount >= 10);
    await tryUnlock(AchievementCriterion.greenThumb, () => wateringCount >= 10);
    await tryUnlock(
      AchievementCriterion.waterMaster,
      () => wateringCount >= 50,
    );
    await tryUnlock(
      AchievementCriterion.fertilizerPro,
      () => fertilizingCount >= 10,
    );
    await tryUnlock(AchievementCriterion.mister, () => mistingCount >= 20);
    await tryUnlock(
      AchievementCriterion.hundredActions,
      () => totalEvents >= 100,
    );
    await tryUnlock(AchievementCriterion.level5, () => level >= 5);
    await tryUnlock(AchievementCriterion.level10, () => level >= 10);

    return unlocked;
  }
}
