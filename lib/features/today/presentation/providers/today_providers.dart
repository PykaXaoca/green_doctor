import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../domain/models/treatment_step_with_diagnosis.dart';
import '../../../plants/presentation/providers/plant_providers.dart';

// =========================================================================
//  Полив на сегодня — уже есть в plant_providers.dart
// =========================================================================

// =========================================================================
//  Удобрение сегодня
// =========================================================================

/// Растения, которым пора удобрять: `lastFertilizedAt + frequency <= конец
/// сегодняшнего дня`. Если `lastFertilizedAt` пусто — берётся `createdAt`.
final fertilizingDueProvider = FutureProvider<List<Plant>>((ref) async {
  final plants = await ref.watch(userPlantsProvider.future);
  final now = DateTime.now();
  final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

  final result = <Plant>[];
  for (final p in plants) {
    final freq = p.fertilizingFrequencyDays;
    if (freq == null || freq <= 0) continue;

    final base = p.lastFertilizedAt ?? p.createdAt;
    final next = base.add(Duration(days: freq));
    if (!next.isAfter(endOfDay)) result.add(p);
  }

  result.sort(
    (a, b) => a.customName.toLowerCase().compareTo(b.customName.toLowerCase()),
  );
  return result;
});

// =========================================================================
//  Опрыскивание сегодня
// =========================================================================

/// Растения, которым пора опрыскивать.
///
/// Растение попадает в список, только если у него задано поле
/// `mistingFrequencyDays` > 0.
final mistingDueProvider = FutureProvider<List<Plant>>((ref) async {
  final plants = await ref.watch(userPlantsProvider.future);
  final now = DateTime.now();
  final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

  final result = <Plant>[];
  for (final p in plants) {
    final freq = p.mistingFrequencyDays;
    if (freq == null || freq <= 0) continue;

    final base = p.lastMistedAt ?? p.createdAt;
    final next = base.add(Duration(days: freq));
    if (!next.isAfter(endOfDay)) result.add(p);
  }

  result.sort(
    (a, b) => a.customName.toLowerCase().compareTo(b.customName.toLowerCase()),
  );
  return result;
});

// =========================================================================
//  Лечение сегодня
// =========================================================================

/// Незавершённые шаги лечения с `dueAt` не позже конца сегодняшнего дня.
final treatmentDueProvider = FutureProvider<List<TreatmentStepWithDiagnosis>>((
  ref,
) async {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
  return db.diagnosisDao.getPendingStepsWithDiagnosisUntil(endOfDay);
});

// =========================================================================
//  Планы на завтра
// =========================================================================

/// Что запланировано на завтра: полив, удобрение, опрыскивание, лечение.
///
/// Каждый список — растения (или шаги лечения), у которых событие
/// попадает в завтрашний день (00:00–23:59). Полив берётся из
/// [wateringScheduleProvider], остальное считается по частоте и
/// дате последнего действия.
class TomorrowPlans {
  const TomorrowPlans({
    required this.date,
    required this.wateringPlants,
    required this.fertilizingPlants,
    required this.mistingPlants,
    required this.treatmentSteps,
  });

  final DateTime date;
  final List<Plant> wateringPlants;
  final List<Plant> fertilizingPlants;
  final List<Plant> mistingPlants;
  final List<TreatmentStepWithDiagnosis> treatmentSteps;

  bool get isEmpty =>
      wateringPlants.isEmpty &&
      fertilizingPlants.isEmpty &&
      mistingPlants.isEmpty &&
      treatmentSteps.isEmpty;

  int get totalCount =>
      wateringPlants.length +
      fertilizingPlants.length +
      mistingPlants.length +
      treatmentSteps.length;
}

/// План на завтра.
final tomorrowPlansProvider = FutureProvider<TomorrowPlans>((ref) async {
  final now = DateTime.now();
  final tomorrowStart = DateTime(
    now.year,
    now.month,
    now.day,
  ).add(const Duration(days: 1));
  final tomorrowEnd = DateTime(
    tomorrowStart.year,
    tomorrowStart.month,
    tomorrowStart.day,
    23,
    59,
    59,
  );

  final plants = await ref.watch(userPlantsProvider.future);

  // --- Полив на завтра ---
  // Переиспользуем логику из plant_providers: у нас нет отдельного
  // провайдера полива «на дату», поэтому считаем так же, как в
  // watering_schedule_providers, но с фильтром на один день.
  final watering = <Plant>[];
  for (final p in plants) {
    final due = p.nextWaterDue;
    final freq = p.wateringFrequencyDays;
    if (due == null || freq == null || freq <= 0) continue;

    // Шагаем вперёд от nextWaterDue, пока не попадём в завтра
    // или не перешагнём его.
    var date = due;
    while (date.isBefore(tomorrowStart)) {
      date = date.add(Duration(days: freq));
    }
    if (!date.isAfter(tomorrowEnd)) {
      watering.add(p);
    }
  }

  // --- Удобрение на завтра ---
  final fertilizing = <Plant>[];
  for (final p in plants) {
    final freq = p.fertilizingFrequencyDays;
    if (freq == null || freq <= 0) continue;

    final base = p.lastFertilizedAt ?? p.createdAt;
    var date = base.add(Duration(days: freq));
    // Сдвигаемся вперёд, если дата ещё до завтра (например,
    // просрочено или уже прошло).
    while (date.isBefore(tomorrowStart)) {
      date = date.add(Duration(days: freq));
    }
    if (!date.isAfter(tomorrowEnd)) {
      fertilizing.add(p);
    }
  }

  // --- Опрыскивание на завтра ---
  final misting = <Plant>[];
  for (final p in plants) {
    final freq = p.mistingFrequencyDays;
    if (freq == null || freq <= 0) continue;

    final base = p.lastMistedAt ?? p.createdAt;
    var date = base.add(Duration(days: freq));
    while (date.isBefore(tomorrowStart)) {
      date = date.add(Duration(days: freq));
    }
    if (!date.isAfter(tomorrowEnd)) {
      misting.add(p);
    }
  }

  // --- Лечение на завтра ---
  // Берём все незавершённые шаги до конца завтра и фильтруем те,
  // чей dueAt попадает в завтрашний день.
  final db = ref.watch(databaseProvider);
  final pendingUntilTomorrow = await db.diagnosisDao
      .getPendingStepsWithDiagnosisUntil(tomorrowEnd);
  final treatment = pendingUntilTomorrow
      .where((s) => !s.step.dueAt.isBefore(tomorrowStart))
      .toList(growable: false);

  // Сортировка по имени растения.
  int byName(Plant a, Plant b) =>
      a.customName.toLowerCase().compareTo(b.customName.toLowerCase());
  watering.sort(byName);
  fertilizing.sort(byName);
  misting.sort(byName);

  return TomorrowPlans(
    date: tomorrowStart,
    wateringPlants: watering,
    fertilizingPlants: fertilizing,
    mistingPlants: misting,
    treatmentSteps: treatment,
  );
});
