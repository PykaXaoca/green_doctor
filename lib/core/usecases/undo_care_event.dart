import 'package:drift/drift.dart';

import '../database/database.dart';
import '../services/care_scheduler.dart';
import '../services/notification_service.dart';

/// Use case отмены выполненного события ухода.
class UndoCareEvent {
  UndoCareEvent(this._db, this._scheduler, this._notifications);

  final AppDatabase _db;
  final CareScheduler _scheduler;
  final NotificationService _notifications;

  Future<void> call({required int eventId}) async {
    // 1. Находим событие.
    final event = await _db.careEventDao.getById(eventId);
    if (event == null) return;

    // 2. Удаляем из журнала.
    await _db.careEventDao.deleteEvent(eventId);

    // 3. Пересчитываем растение.
    final plant = await _db.plantDao.getById(event.plantId);
    if (plant == null) return;

    if (event.type == 'watering') {
      final previous = await _db.careEventDao.getLastByPlantAndType(
        event.plantId,
        'watering',
      );
      final lastWateredAt = previous?.performedAt;

      final nextDue = _scheduler.calculateNextWatering(
        lastWateredAt: lastWateredAt,
        from: plant.createdAt,
        frequencyDays: plant.wateringFrequencyDays,
      );

      await _db.plantDao.updatePlant(
        plant.id,
        PlantsCompanion(
          lastWateredAt: Value(lastWateredAt),
          nextWaterDue: Value(nextDue),
        ),
      );
    } else if (event.type == 'fertilizing') {
      final previous = await _db.careEventDao.getLastByPlantAndType(
        event.plantId,
        'fertilizing',
      );
      await _db.plantDao.updatePlant(
        plant.id,
        PlantsCompanion(lastFertilizedAt: Value(previous?.performedAt)),
      );
    } else if (event.type == 'repotting') {
      final previous = await _db.careEventDao.getLastByPlantAndType(
        event.plantId,
        'repotting',
        before: event.performedAt,
      );
      await _db.plantDao.updatePlant(
        plant.id,
        PlantsCompanion(lastRepottedAt: Value(previous?.performedAt)),
      );
    }

    // 4. Пересобираем расписание уведомлений о поливе —
    //    растение могло снова попасть в сегодняшний день.
    await _resyncWateringNotifications();
  }

  Future<void> _resyncWateringNotifications() async {
    final plants = await _db.plantDao.getAllActive();
    await _notifications.syncAll(plants);
  }
}
