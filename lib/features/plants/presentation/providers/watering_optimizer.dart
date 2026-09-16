import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../profile/presentation/providers/care_schedule_providers.dart';
import 'plant_providers.dart';

// ============================================================================
//  Модели
// ============================================================================

class WateringOptimizationChange {
  const WateringOptimizationChange({
    required this.plant,
    required this.oldDate,
    required this.newDate,
  });

  final Plant plant;
  final DateTime oldDate;
  final DateTime newDate;

  int get shiftDays => newDate.difference(oldDate).inDays;
  bool get isForward => shiftDays > 0;
}

enum CannotFitReason {
  overdue('Просрочено — полить как можно скорее'),
  noFlexibility('Слишком чувствительно к срокам'),
  noVisitDay('Нет подходящего дня поездки'),
  noFrequency('Не задана частота полива');

  const CannotFitReason(this.label);
  final String label;
}

class CannotFit {
  const CannotFit({required this.plant, required this.reason});

  final Plant plant;
  final CannotFitReason reason;
}

class WateringOptimizationPlan {
  const WateringOptimizationPlan({
    required this.changes,
    required this.cannotFit,
    required this.totalPlants,
    required this.config,
  });

  final List<WateringOptimizationChange> changes;
  final List<CannotFit> cannotFit;
  final int totalPlants;
  final CareScheduleConfig config;

  bool get isEmpty => changes.isEmpty && cannotFit.isEmpty;
  bool get hasChanges => changes.isNotEmpty;

  int get alreadyFitCount => totalPlants - changes.length - cannotFit.length;
  int get willFitCount => alreadyFitCount + changes.length;
}

// ============================================================================
//  Провайдер
// ============================================================================

final wateringOptimizationPlanProvider =
    FutureProvider<WateringOptimizationPlan?>((ref) async {
      final config = await ref.watch(careScheduleProvider.future);
      if (config.mode == CareScheduleMode.free) return null;

      final plants = await ref.watch(userPlantsProvider.future);
      if (plants.isEmpty) {
        return WateringOptimizationPlan(
          changes: const [],
          cannotFit: const [],
          totalPlants: 0,
          config: config,
        );
      }

      final speciesRepo = ref.read(speciesRepositoryProvider);
      final allSpecies = await speciesRepo.getAll();
      final speciesById = {for (final s in allSpecies) s.id: s};

      return buildWateringOptimizationPlan(
        plants: plants,
        speciesById: speciesById,
        config: config,
      );
    });

// ============================================================================
//  Логика
// ============================================================================

/// Строит план оптимизации расписания.
///
/// ВАЖНО: база для каждого растения — **естественная дата**
/// (`lastWateredAt ?? createdAt + frequencyDays`), а не текущий
/// `nextWaterDue`. Это делает план стабильным: сколько раз ни
/// применяй оптимизацию, результат один и тот же. Иначе предыдущий
/// сдвиг мешает следующему.
WateringOptimizationPlan buildWateringOptimizationPlan({
  required List<Plant> plants,
  required Map<String, PlantSpecy> speciesById,
  required CareScheduleConfig config,
  DateTime? nowOverride,
}) {
  final now = nowOverride ?? DateTime.now();
  final today = _dateOnly(now);

  final changes = <WateringOptimizationChange>[];
  final cannotFit = <CannotFit>[];

  final horizon = today.add(const Duration(days: 180));
  final visitDays = _upcomingVisitDays(config, today, horizon);

  if (visitDays.isEmpty) {
    for (final p in plants) {
      cannotFit.add(CannotFit(plant: p, reason: CannotFitReason.noVisitDay));
    }
    return WateringOptimizationPlan(
      changes: const [],
      cannotFit: cannotFit,
      totalPlants: plants.length,
      config: config,
    );
  }

  for (final plant in plants) {
    final freq = plant.wateringFrequencyDays;
    final species = plant.speciesId != null
        ? speciesById[plant.speciesId]
        : null;

    if (freq == null || freq <= 0) {
      cannotFit.add(
        CannotFit(plant: plant, reason: CannotFitReason.noFrequency),
      );
      continue;
    }

    // Естественная дата — от последнего полива или создания,
    // шагаем вперёд до ближайшей будущей.
    final naturalDate = _naturalNextWatering(plant, freq, today);
    if (naturalDate == null) {
      // Просрочено — не трогаем.
      cannotFit.add(CannotFit(plant: plant, reason: CannotFitReason.overdue));
      continue;
    }

    final window = _flexibilityWindowDays(species, freq);

    if (window == 0) {
      cannotFit.add(
        CannotFit(plant: plant, reason: CannotFitReason.noFlexibility),
      );
      continue;
    }

    final earliest = naturalDate.subtract(Duration(days: window));
    final latest = naturalDate.add(Duration(days: window));
    final matching = visitDays
        .where((d) => !d.isBefore(earliest) && !d.isAfter(latest))
        .toList();

    if (matching.isEmpty) {
      cannotFit.add(
        CannotFit(plant: plant, reason: CannotFitReason.noVisitDay),
      );
      continue;
    }

    matching.sort(
      (a, b) => a
          .difference(naturalDate)
          .abs()
          .compareTo(b.difference(naturalDate).abs()),
    );
    final best = matching.first;

    if (_sameDay(best, naturalDate)) continue;

    changes.add(
      WateringOptimizationChange(
        plant: plant,
        oldDate: naturalDate,
        newDate: best,
      ),
    );
  }

  changes.sort((a, b) => a.newDate.compareTo(b.newDate));

  return WateringOptimizationPlan(
    changes: changes,
    cannotFit: cannotFit,
    totalPlants: plants.length,
    config: config,
  );
}

/// Естественная дата следующего полива растения.
///
/// `lastWateredAt ?? createdAt + frequencyDays`. Если дата в прошлом —
/// шагаем вперёд на freq до ближайшей будущей (сегодня или позже).
/// Возвращает `null`, если растение уже просрочено (база в прошлом,
/// следующий шаг тоже в прошлом).
DateTime? _naturalNextWatering(Plant plant, int freq, DateTime today) {
  final base = plant.lastWateredAt ?? plant.createdAt;
  var next = _dateOnly(base).add(Duration(days: freq));
  // Если получилось в прошлом — идём вперёд.
  while (next.isBefore(today)) {
    next = next.add(Duration(days: freq));
  }
  return next;
}

// ============================================================================
//  Дни поездок
// ============================================================================

List<DateTime> _upcomingVisitDays(
  CareScheduleConfig config,
  DateTime from,
  DateTime to,
) {
  final days = <DateTime>[];
  final start = _dateOnly(from);
  final end = _dateOnly(to);

  switch (config.mode) {
    case CareScheduleMode.free:
      return const [];

    case CareScheduleMode.weekdays:
      var current = start;
      while (!current.isAfter(end)) {
        if (config.weekdays.contains(current.weekday)) {
          days.add(current);
        }
        current = current.add(const Duration(days: 1));
      }
      break;

    case CareScheduleMode.interval:
      final interval = config.intervalDays;
      if (interval <= 0) return const [];

      var base = _dateOnly(config.startDate ?? from);
      while (base.isBefore(start)) {
        base = base.add(Duration(days: interval));
      }
      while (!base.isAfter(end)) {
        days.add(base);
        base = base.add(Duration(days: interval));
      }
      break;
  }

  return days;
}

// ============================================================================
//  Безопасное окно
// ============================================================================

/// Безопасное окно сдвига в днях.
///
/// Окно пропорционально частоте и категории вида. Минимум 1 день —
/// чтобы не блокировать частые растения совсем. Максимум 14.
///
///  * влаголюбивые тропические (humidity_min >= 70) — окно 0;
///  * кактусы, суккуленты — 40% от частоты;
///  * хвойные, пальмы — 30%;
///  * ягодные, садовые — 25%;
///  * овощи, зелень — 15%;
///  * комнатные, прочие — 20%.
int _flexibilityWindowDays(PlantSpecy? species, int frequencyDays) {
  if (species == null) {
    return (frequencyDays * 0.2).floor().clamp(1, 14);
  }

  final humidityMin = species.humidityMin ?? 0;
  if (humidityMin >= 70) return 0;

  final category = species.category ?? '';
  final double ratio;
  switch (category) {
    case 'Кактус':
    case 'Суккулент':
      ratio = 0.4;
      break;
    case 'Хвойное':
    case 'Комнатная пальма':
      ratio = 0.3;
      break;
    case 'Ягодный кустарник':
    case 'Ягодное':
    case 'Ягодное дерево':
    case 'Садовое дерево':
    case 'Декоративный кустарник':
    case 'Ягодная лиана':
    case 'Вьющиеся':
    case 'Почвопокровное':
      ratio = 0.25;
      break;
    case 'Овощ':
    case 'Зелень и пряности':
      ratio = 0.15;
      break;
    default:
      ratio = 0.2;
  }

  return (frequencyDays * ratio).floor().clamp(1, 14);
}

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
