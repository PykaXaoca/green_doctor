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
///
/// Просроченные события (срок был в прошлом) тоже попадают сюда —
/// они отображаются в блоке «Сегодня» вместе с обычными.
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
/// `mistingFrequencyDays` > 0. Просроченные тоже попадают сюда.
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
///
/// Просроченные шаги тоже попадают сюда.
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
/// Каждый список — растения (или шаги лечения), у которых **ближайшее**
/// следующее событие попадает ровно в завтрашний день (00:00–23:59).
///
/// Просроченные события (срок был в прошлом) сюда **не попадают** —
/// они отображаются в разделе «Планы на сегодня» с пометкой
/// «просрочено». Здесь же только те, у кого **первая** дата следующего
/// действия — завтра.
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
///
/// Логика: берём **первую** дату следующего события (для полива —
/// `nextWaterDue`, для удобрения/опрыскивания — `lastAction + frequency`).
/// Если эта дата попадает в диапазон «завтра», растение показывается в
/// соответствующем блоке. Если дата в прошлом (просрочено) или в будущем
/// дальше завтра — не показываем.
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

  /// Дата попадает в «завтрашний» диапазон.
  bool inTomorrow(DateTime d) =>
      !d.isBefore(tomorrowStart) && !d.isAfter(tomorrowEnd);

  final plants = await ref.watch(userPlantsProvider.future);

  // --- Полив на завтра ---
  // Только если ближайшая дата полива — завтра. Просроченные
  // (nextWaterDue в прошлом) сюда не попадают — они в «Сегодня».
  final watering = <Plant>[];
  for (final p in plants) {
    final due = p.nextWaterDue;
    final freq = p.wateringFrequencyDays;
    if (due == null || freq == null || freq <= 0) continue;
    if (inTomorrow(due)) watering.add(p);
  }

  // --- Удобрение на завтра ---
  // Только если первая расчётная дата следующего удобрения — завтра.
  final fertilizing = <Plant>[];
  for (final p in plants) {
    final freq = p.fertilizingFrequencyDays;
    if (freq == null || freq <= 0) continue;

    final base = p.lastFertilizedAt ?? p.createdAt;
    final next = base.add(Duration(days: freq));
    if (inTomorrow(next)) fertilizing.add(p);
  }

  // --- Опрыскивание на завтра ---
  final misting = <Plant>[];
  for (final p in plants) {
    final freq = p.mistingFrequencyDays;
    if (freq == null || freq <= 0) continue;

    final base = p.lastMistedAt ?? p.createdAt;
    final next = base.add(Duration(days: freq));
    if (inTomorrow(next)) misting.add(p);
  }

  // --- Лечение на завтра ---
  // Берём все незавершённые шаги до конца завтра и фильтруем те,
  // чей dueAt попадает именно в завтрашний день.
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
