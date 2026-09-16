import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../core/services/gamification_service.dart';
import '../../../../core/usecases/complete_care_event.dart';
import '../../../calendar/presentation/providers/calendar_providers.dart';
import '../../../diagnosis/presentation/providers/diagnosis_providers.dart';

final currentUserIdProvider = Provider<int>((ref) => 1);

final userPlantsProvider = FutureProvider<List<Plant>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final repo = ref.watch(plantRepositoryProvider);
  return repo.getByUser(userId);
});

final archivedPlantsProvider = FutureProvider<List<Plant>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final repo = ref.watch(plantRepositoryProvider);
  return repo.getArchivedByUser(userId);
});

final plantByIdProvider = FutureProvider.family<Plant?, int>((ref, id) async {
  final repo = ref.watch(plantRepositoryProvider);
  return repo.getById(id);
});

final allSpeciesProvider = FutureProvider<List<PlantSpecy>>((ref) async {
  final repo = ref.watch(speciesRepositoryProvider);
  return repo.getAll();
});

final freeSpeciesProvider = FutureProvider<List<PlantSpecy>>((ref) async {
  final repo = ref.watch(speciesRepositoryProvider);
  return repo.getNonPremium();
});

final plantsDueForWateringProvider = FutureProvider<List<Plant>>((ref) async {
  final repo = ref.watch(plantRepositoryProvider);
  final now = DateTime.now();
  final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
  return repo.getDueForWatering(endOfDay);
});

final plantCareEventsProvider = FutureProvider.family<List<CareEvent>, int>((
  ref,
  plantId,
) async {
  final repo = ref.watch(careEventRepositoryProvider);
  return repo.getByPlant(plantId);
});

// =========================================================================
//  Пересадка
// =========================================================================

class RepottingStatus {
  const RepottingStatus({
    required this.plant,
    required this.monthsSinceRepotting,
    required this.monthsUntilDue,
    required this.repottingFrequencyMonths,
  });

  final Plant plant;
  final int monthsSinceRepotting;
  final int monthsUntilDue;
  final int repottingFrequencyMonths;

  bool get isOverdue => monthsUntilDue < 0;
  bool get isSoon => monthsUntilDue >= 0 && monthsUntilDue <= 1;
}

final plantsNeedingRepottingProvider = FutureProvider<List<RepottingStatus>>((
  ref,
) async {
  final plants = await ref.watch(userPlantsProvider.future);
  if (plants.isEmpty) return const <RepottingStatus>[];

  final speciesRepo = ref.read(speciesRepositoryProvider);
  final allSpecies = await speciesRepo.getAll();
  final speciesById = {for (final s in allSpecies) s.id: s};

  final now = DateTime.now();
  final result = <RepottingStatus>[];

  for (final p in plants) {
    if (p.speciesId == null) continue;

    final species = speciesById[p.speciesId];
    final freq = species?.repottingFrequencyMonths;
    if (freq == null || freq <= 0) continue;

    final base = p.lastRepottedAt ?? p.createdAt;
    final daysSince = now.difference(base).inDays;
    final monthsSince = daysSince ~/ 30;
    final monthsUntil = freq - monthsSince;

    if (monthsUntil <= 1) {
      result.add(
        RepottingStatus(
          plant: p,
          monthsSinceRepotting: monthsSince,
          monthsUntilDue: monthsUntil,
          repottingFrequencyMonths: freq,
        ),
      );
    }
  }

  result.sort((a, b) => a.monthsUntilDue.compareTo(b.monthsUntilDue));
  return result;
});

final repottingStatusForPlantProvider =
    FutureProvider.family<RepottingStatus?, int>((ref, plantId) async {
      final list = await ref.watch(plantsNeedingRepottingProvider.future);
      for (final status in list) {
        if (status.plant.id == plantId) return status;
      }
      return null;
    });

// =========================================================================
//  Контроллер растения
// =========================================================================

final plantControllerProvider = Provider<PlantController>((ref) {
  return PlantController(ref);
});

const int _defaultWateringDays = 7;
const int _defaultFertilizingDays = 30;

class PlantController {
  PlantController(this._ref);

  final Ref _ref;

  Future<void> _resyncNotifications() async {
    final repo = _ref.read(plantRepositoryProvider);
    final notifications = _ref.read(notificationServiceProvider);
    final plants = await repo.getAllActive();
    await notifications.syncAll(plants);
  }

  void _invalidateAll() {
    _ref.invalidate(userPlantsProvider);
    _ref.invalidate(archivedPlantsProvider);
    _ref.invalidate(plantsDueForWateringProvider);
    _ref.invalidate(plantsNeedingRepottingProvider);
    _ref.invalidate(calendarEventsProvider);
  }

  Future<int> create(PlantsCompanion plant) async {
    final repo = _ref.read(plantRepositoryProvider);
    final speciesRepo = _ref.read(speciesRepositoryProvider);
    final scheduler = _ref.read(careSchedulerProvider);
    final gamification = _ref.read(gamificationServiceProvider);
    final achievements = _ref.read(achievementCheckerProvider);
    final userId = _ref.read(currentUserIdProvider);

    int? wateringDays = plant.wateringFrequencyDays.value;
    if (wateringDays == null && plant.speciesId.present) {
      final speciesId = plant.speciesId.value;
      if (speciesId != null) {
        final species = await speciesRepo.getById(speciesId);
        wateringDays = species?.defaultWateringDays;
      }
    }
    wateringDays ??= _defaultWateringDays;

    int? fertilizingDays = plant.fertilizingFrequencyDays.value;
    fertilizingDays ??= _defaultFertilizingDays;

    PlantsCompanion enriched = plant.copyWith(
      wateringFrequencyDays: plant.wateringFrequencyDays.present
          ? plant.wateringFrequencyDays
          : Value(wateringDays),
      fertilizingFrequencyDays: plant.fertilizingFrequencyDays.present
          ? plant.fertilizingFrequencyDays
          : Value(fertilizingDays),
    );

    if (!enriched.nextWaterDue.present) {
      final next = scheduler.calculateInitialWatering(
        createdAt: DateTime.now(),
        frequencyDays: wateringDays,
      );
      enriched = enriched.copyWith(nextWaterDue: Value(next));
    }

    final id = await repo.create(enriched);
    _invalidateAll();

    await _resyncNotifications();

    await gamification.addXp(
      userId: userId,
      amount: XpReward.addPlant,
      reason: 'add_plant',
    );

    await achievements.checkAll(userId);

    return id;
  }

  Future<void> update(int id, PlantsCompanion plant) async {
    final repo = _ref.read(plantRepositoryProvider);

    final current = await repo.getById(id);
    if (current == null) return;

    await repo.update(id, plant);

    final saved = await repo.getById(id);
    if (saved != null) {
      final newFrequency = saved.wateringFrequencyDays;
      if (newFrequency != null && newFrequency > 0) {
        final base = saved.lastWateredAt ?? saved.createdAt;
        final nextDue = base.add(Duration(days: newFrequency));
        if (nextDue != saved.nextWaterDue) {
          await repo.update(id, PlantsCompanion(nextWaterDue: Value(nextDue)));
        }
      }
    }

    _invalidateAll();
    _ref.invalidate(plantByIdProvider(id));

    await _resyncNotifications();
  }

  Future<void> archive(int id) async {
    final repo = _ref.read(plantRepositoryProvider);
    await repo.archive(id);
    _invalidateAll();
    await _resyncNotifications();
  }

  Future<void> unarchive(int id) async {
    final repo = _ref.read(plantRepositoryProvider);
    await repo.unarchive(id);
    _invalidateAll();
    _ref.invalidate(plantByIdProvider(id));
    await _resyncNotifications();
  }

  Future<void> delete(int id) async {
    final db = _ref.read(databaseProvider);
    final notifications = _ref.read(notificationServiceProvider);
    final treatmentScheduler = _ref.read(treatmentSchedulerProvider);
    final diagnosisRepo = _ref.read(diagnosisRepositoryProvider);

    final diagnoses = await diagnosisRepo.getByPlant(id);
    for (final d in diagnoses) {
      await treatmentScheduler.cancelForDiagnosis(d.id);
    }

    await db.deletePlantCascade(id);
    await notifications.cancelForPlant(id);

    _invalidateAll();
    _ref.invalidate(activeDiagnosesProvider);
    _ref.invalidate(activeDiagnosesForPlantProvider);

    await _resyncNotifications();
  }

  Future<void> applyScheduleChanges(
    List<({int plantId, DateTime newDate})> changes,
  ) async {
    if (changes.isEmpty) return;

    final repo = _ref.read(plantRepositoryProvider);

    for (final c in changes) {
      await repo.update(
        c.plantId,
        PlantsCompanion(nextWaterDue: Value(c.newDate)),
      );
    }

    _invalidateAll();
    for (final c in changes) {
      _ref.invalidate(plantByIdProvider(c.plantId));
    }

    await _resyncNotifications();
  }

  /// Сбрасывает расписание полива к «естественному».
  ///
  /// Для каждого активного растения:
  ///  * `nextWaterDue = (lastWateredAt ?? createdAt) + frequencyDays`;
  ///  * если дата в прошлом — идём вперёд шагом frequencyDays
  ///    до ближайшей будущей.
  ///
  /// Используется кнопкой «Сбросить расписание» в режиме дачника.
  Future<int> resetWateringSchedule() async {
    final repo = _ref.read(plantRepositoryProvider);
    final plants = await repo.getAllActive();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    var changed = 0;

    for (final plant in plants) {
      final freq = plant.wateringFrequencyDays;
      if (freq == null || freq <= 0) continue;

      final base = plant.lastWateredAt ?? plant.createdAt;
      var next = DateTime(
        base.year,
        base.month,
        base.day,
      ).add(Duration(days: freq));

      // Если получилось в прошлом — шагаем вперёд до будущей даты.
      while (next.isBefore(today)) {
        next = next.add(Duration(days: freq));
      }

      if (next != plant.nextWaterDue) {
        await repo.update(plant.id, PlantsCompanion(nextWaterDue: Value(next)));
        changed++;
      }
    }

    _invalidateAll();
    await _resyncNotifications();
    return changed;
  }
}

final careActionControllerProvider = Provider<CareActionController>((ref) {
  return CareActionController(ref);
});

class CareActionController {
  CareActionController(this._ref);

  final Ref _ref;

  Future<CareResult> perform({
    required int plantId,
    required String type,
    String? notes,
  }) async {
    final useCase = _ref.read(completeCareEventProvider);
    final userId = _ref.read(currentUserIdProvider);

    final result = await useCase(
      plantId: plantId,
      userId: userId,
      type: type,
      notes: notes,
    );

    _ref.invalidate(plantByIdProvider(plantId));
    _ref.invalidate(userPlantsProvider);
    _ref.invalidate(archivedPlantsProvider);
    _ref.invalidate(plantsDueForWateringProvider);
    _ref.invalidate(plantCareEventsProvider(plantId));
    _ref.invalidate(plantsNeedingRepottingProvider);
    _ref.invalidate(calendarEventsProvider);

    return result;
  }

  Future<void> undo(int eventId) async {
    final useCase = _ref.read(undoCareEventProvider);
    await useCase(eventId: eventId);

    _ref.invalidate(userPlantsProvider);
    _ref.invalidate(archivedPlantsProvider);
    _ref.invalidate(plantsDueForWateringProvider);
    _ref.invalidate(plantsNeedingRepottingProvider);
    _ref.invalidate(calendarEventsProvider);
  }
}
