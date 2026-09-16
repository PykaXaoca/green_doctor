import 'package:drift/drift.dart';

import '../database/database.dart';
import '../services/achievement_checker.dart';
import '../services/care_scheduler.dart';
import '../services/gamification_service.dart';
import '../services/notification_service.dart';

/// Use case для выполнения события ухода.
class CompleteCareEvent {
  CompleteCareEvent(
    this._db,
    this._scheduler,
    this._notifications,
    this._gamification,
    this._achievements,
  );

  final AppDatabase _db;
  final CareScheduler _scheduler;
  final NotificationService _notifications;
  final GamificationService _gamification;
  final AchievementChecker _achievements;

  Future<CareResult> call({
    required int plantId,
    required int userId,
    required String type,
    DateTime? performedAt,
    String? notes,
  }) async {
    final now = performedAt ?? DateTime.now();

    // 1. Запись в журнал.
    final eventId = await _db.careEventDao.insertEvent(
      CareEventsCompanion(
        plantId: Value(plantId),
        type: Value(type),
        performedAt: Value(now),
        notes: Value(notes),
      ),
    );

    // 2. Обновляем растение.
    final plant = await _db.plantDao.getById(plantId);
    if (plant == null) {
      return CareResult(
        eventId: eventId,
        xpGained: 0,
        unlockedAchievements: [],
      );
    }

    if (type == 'watering') {
      final next = _scheduler.calculateNextWatering(
        lastWateredAt: now,
        from: plant.createdAt,
        frequencyDays: plant.wateringFrequencyDays,
      );
      await _db.plantDao.updatePlant(
        plantId,
        PlantsCompanion(lastWateredAt: Value(now), nextWaterDue: Value(next)),
      );
    } else if (type == 'fertilizing') {
      await _db.plantDao.updatePlant(
        plantId,
        PlantsCompanion(lastFertilizedAt: Value(now)),
      );
    } else if (type == 'misting') {
      await _db.plantDao.updatePlant(
        plantId,
        PlantsCompanion(lastMistedAt: Value(now)),
      );
    } else if (type == 'repotting') {
      await _db.plantDao.updatePlant(
        plantId,
        PlantsCompanion(lastRepottedAt: Value(now)),
      );
    }

    // 3. Деактивируем напоминания.
    final reminders = await _db.reminderDao.getByPlant(plantId);
    for (final r in reminders) {
      if (r.type == type && r.isActive) {
        await _db.reminderDao.deactivate(r.id);
        await _notifications.cancelReminder(r.id);
      }
    }

    // 4. Пересобираем расписание уведомлений о поливе —
    //    количество растений на сегодня могло уменьшиться.
    await _resyncWateringNotifications();

    // 5. Начисляем XP.
    final xp = _xpForAction(type);
    if (xp > 0) {
      await _gamification.addXp(userId: userId, amount: xp, reason: type);
    }

    // 6. Проверяем достижения.
    final unlocked = await _achievements.checkAll(userId);

    return CareResult(
      eventId: eventId,
      xpGained: xp,
      unlockedAchievements: unlocked,
    );
  }

  /// Пересчитывает групповые уведомления о поливе.
  Future<void> _resyncWateringNotifications() async {
    final plants = await _db.plantDao.getAllActive();
    await _notifications.syncAll(plants);
  }

  int _xpForAction(String type) {
    switch (type) {
      case 'watering':
        return XpReward.watering;
      case 'fertilizing':
        return XpReward.fertilizing;
      case 'misting':
        return XpReward.misting;
      case 'repotting':
        return XpReward.repotting;
      default:
        return 0;
    }
  }
}

class CareResult {
  const CareResult({
    required this.eventId,
    required this.xpGained,
    required this.unlockedAchievements,
  });

  final int eventId;
  final int xpGained;
  final List<String> unlockedAchievements;
}
