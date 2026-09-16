import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../../diagnosis/presentation/providers/diagnosis_providers.dart';
import '../../../plants/presentation/providers/plant_providers.dart';
import '../../../profile/presentation/providers/care_schedule_providers.dart';

/// Событие в календаре — либо запланированное, либо выполненное.
class CalendarEvent {
  const CalendarEvent({
    required this.date,
    required this.type,
    required this.plantName,
    required this.isCompleted,
    this.plantId,
    this.careEventId,
    this.reminderId,
    this.diagnosisId,
    this.stepId,
    this.title,
    this.fertilizerType,
  });

  final DateTime date;
  final String type;
  final int? plantId;
  final String plantName;
  final bool isCompleted;

  final int? careEventId;
  final int? reminderId;
  final int? diagnosisId;
  final int? stepId;
  final String? title;
  final String? fertilizerType;

  bool get isTreatment => diagnosisId != null && stepId != null;
}

/// Диапазон, который сейчас показан в календаре.
final calendarRangeProvider =
    NotifierProvider<CalendarRangeNotifier, DateTimeRange>(
      CalendarRangeNotifier.new,
    );

class CalendarRangeNotifier extends Notifier<DateTimeRange> {
  @override
  DateTimeRange build() {
    final now = DateTime.now();
    return DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
    );
  }

  void setRange(DateTimeRange range) {
    state = range;
  }
}

/// Провайдер всех событий в выбранном диапазоне.
///
/// Полив генерируется по правилам выбранного режима:
///  * **Свободный** — по индивидуальной частоте каждого растения;
///  * **Раз в N дней** — только на дни поездок (шаг N от `startDate`);
///  * **По дням недели** — только на выбранные дни недели.
///
/// Это значит: если пользователь выбрал «Раз в 3 дня», в календаре
/// не будет 30 разных дат полива — будут только дни поездок.
final calendarEventsProvider =
    FutureProvider<Map<DateTime, List<CalendarEvent>>>((ref) async {
      final range = ref.watch(calendarRangeProvider);

      // Триггеры пересчёта.
      await ref.watch(userPlantsProvider.future);
      await ref.watch(activeDiagnosesProvider.future);
      final config = await ref.watch(careScheduleProvider.future);

      final plantRepo = ref.watch(plantRepositoryProvider);
      final careRepo = ref.watch(careEventRepositoryProvider);
      final reminderRepo = ref.watch(reminderRepositoryProvider);
      final diagnosisRepo = ref.watch(diagnosisRepositoryProvider);
      final speciesRepo = ref.watch(speciesRepositoryProvider);

      final plants = await plantRepo.getAllActive();
      final careEvents = await careRepo.getInRange(range.start, range.end);
      final reminders = await reminderRepo.getDueUntil(range.end);
      final treatmentSteps = await diagnosisRepo.getStepsWithDiagnosisInRange(
        range.start,
        range.end,
      );
      final allSpecies = await speciesRepo.getAll();

      final plantsById = {for (final p in plants) p.id: p};
      final speciesById = {for (final s in allSpecies) s.id: s};

      final events = <CalendarEvent>[];

      // ------------------------------------------------------------------
      // 1. Полив
      // ------------------------------------------------------------------
      if (config.mode == CareScheduleMode.free) {
        // Свободный режим — индивидуальный график каждого растения.
        for (final plant in plants) {
          final firstDue = plant.nextWaterDue;
          final freq = plant.wateringFrequencyDays;
          if (firstDue == null || freq == null || freq <= 0) continue;

          var date = firstDue;
          while (date.isBefore(range.start)) {
            date = date.add(Duration(days: freq));
          }
          while (!date.isAfter(range.end)) {
            events.add(
              CalendarEvent(
                date: _dateOnly(date),
                type: 'watering',
                plantId: plant.id,
                plantName: plant.customName,
                isCompleted: false,
              ),
            );
            date = date.add(Duration(days: freq));
          }
        }
      } else {
        // Режим дачника — только дни поездок.
        final visitDays = _visitDaysInRange(config, range.start, range.end);

        for (final plant in plants) {
          final freq = plant.wateringFrequencyDays;
          if (freq == null || freq <= 0) continue;

          // База — последний полив или дата создания.
          final base = plant.lastWateredAt ?? plant.createdAt;
          var nextDue = _dateOnly(base).add(Duration(days: freq));

          // Толерантность для «прилипания» к ближайшему дню поездки.
          // Чем выше частота, тем шире допуск.
          final tolerance = Duration(days: freq >= 4 ? 2 : 1);

          for (final vd in visitDays) {
            if (vd.isAfter(range.end)) break;
            // Слишком рано — пропускаем.
            if (vd.isBefore(nextDue.subtract(tolerance))) continue;

            events.add(
              CalendarEvent(
                date: vd,
                type: 'watering',
                plantId: plant.id,
                plantName: plant.customName,
                isCompleted: false,
              ),
            );

            // Следующий полив — не раньше, чем через freq после этого дня.
            nextDue = vd.add(Duration(days: freq));
          }
        }
      }

      // ------------------------------------------------------------------
      // 2. Удобрение — серия дат + тип удобрения из вида.
      // ------------------------------------------------------------------
      for (final plant in plants) {
        final freq = plant.fertilizingFrequencyDays;
        if (freq == null || freq <= 0) continue;

        final base = plant.lastFertilizedAt ?? plant.createdAt;
        var date = base.add(Duration(days: freq));

        final species = plant.speciesId != null
            ? speciesById[plant.speciesId]
            : null;
        final fertilizerType = species?.fertilizerType;

        while (date.isBefore(range.start)) {
          date = date.add(Duration(days: freq));
        }
        while (!date.isAfter(range.end)) {
          events.add(
            CalendarEvent(
              date: _dateOnly(date),
              type: 'fertilizing',
              plantId: plant.id,
              plantName: plant.customName,
              isCompleted: false,
              fertilizerType: fertilizerType,
            ),
          );
          date = date.add(Duration(days: freq));
        }
      }

      // ------------------------------------------------------------------
      // 3. Напоминания — из Reminders (кроме полива и удобрения).
      // ------------------------------------------------------------------
      for (final r in reminders) {
        if (!r.isActive) continue;
        if (r.dueAt.isBefore(range.start) || r.dueAt.isAfter(range.end)) {
          continue;
        }
        if (r.type == 'watering' || r.type == 'fertilizing') continue;
        final plant = plantsById[r.plantId];
        events.add(
          CalendarEvent(
            date: _dateOnly(r.dueAt),
            type: r.type,
            plantId: r.plantId,
            plantName: plant?.customName ?? 'Растение #${r.plantId}',
            isCompleted: false,
            reminderId: r.id,
          ),
        );
      }

      // ------------------------------------------------------------------
      // 4. Выполненные события ухода.
      // ------------------------------------------------------------------
      for (final e in careEvents) {
        final plant = plantsById[e.plantId];
        final species = plant?.speciesId != null
            ? speciesById[plant!.speciesId]
            : null;
        events.add(
          CalendarEvent(
            date: _dateOnly(e.performedAt),
            type: e.type,
            plantId: e.plantId,
            plantName: plant?.customName ?? 'Растение #${e.plantId}',
            isCompleted: true,
            careEventId: e.id,
            fertilizerType: e.type == 'fertilizing'
                ? species?.fertilizerType
                : null,
          ),
        );
      }

      // ------------------------------------------------------------------
      // 5. Шаги лечения.
      // ------------------------------------------------------------------
      for (final s in treatmentSteps) {
        final plantId = s.diagnosis.plantId;
        final plantName = plantId != null
            ? (plantsById[plantId]?.customName ?? 'Растение #$plantId')
            : 'Без растения';
        events.add(
          CalendarEvent(
            date: _dateOnly(s.step.dueAt),
            type: 'treatment',
            plantId: plantId,
            plantName: plantName,
            isCompleted: s.step.isCompleted,
            diagnosisId: s.diagnosis.id,
            stepId: s.step.id,
            title: s.step.title,
          ),
        );
      }

      // Группируем по дням.
      final map = <DateTime, List<CalendarEvent>>{};
      for (final ev in events) {
        map.putIfAbsent(ev.date, () => []).add(ev);
      }
      for (final entry in map.entries) {
        entry.value.sort((a, b) {
          if (a.isTreatment != b.isTreatment) {
            return a.isTreatment ? -1 : 1;
          }
          if (a.isCompleted != b.isCompleted) {
            return a.isCompleted ? 1 : -1;
          }
          return 0;
        });
      }
      return map;
    });

// ============================================================================
//  Дни поездок
// ============================================================================

/// Возвращает список дней поездок в диапазоне.
///
/// Для режима «Свободный» возвращает пустой список — вызывающий код
/// не должен его использовать в этом режиме.
List<DateTime> _visitDaysInRange(
  CareScheduleConfig config,
  DateTime from,
  DateTime to,
) {
  final days = <DateTime>[];
  final start = _dateOnly(from);
  final end = _dateOnly(to);

  switch (config.mode) {
    case CareScheduleMode.free:
      return days;

    case CareScheduleMode.weekdays:
      var cur = start;
      while (!cur.isAfter(end)) {
        if (config.weekdays.contains(cur.weekday)) {
          days.add(cur);
        }
        cur = cur.add(const Duration(days: 1));
      }
      break;

    case CareScheduleMode.interval:
      final interval = config.intervalDays;
      if (interval <= 0) return days;

      // Стартовая точка — дата старта режима (или начало диапазона).
      var base = _dateOnly(config.startDate ?? from);
      // Догоняем до начала диапазона.
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

/// Оставляет только дату без времени.
DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
