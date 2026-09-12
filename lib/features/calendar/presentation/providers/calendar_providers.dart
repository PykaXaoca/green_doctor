import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';

/// Событие в календаре — либо запланированное, либо выполненное.
class CalendarEvent {
  const CalendarEvent({
    required this.date,
    required this.type,
    required this.plantId,
    required this.plantName,
    required this.isCompleted,
    this.careEventId,
    this.reminderId,
  });

  final DateTime date;
  final String type; // watering, fertilizing, misting, repotting
  final int plantId;
  final String plantName;
  final bool isCompleted;
  final int? careEventId;
  final int? reminderId;
}

/// Диапазон, который сейчас показан в календаре.
/// Меняется при переключении месяца.
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
final calendarEventsProvider =
    FutureProvider<Map<DateTime, List<CalendarEvent>>>((ref) async {
      final range = ref.watch(calendarRangeProvider);
      final plantRepo = ref.watch(plantRepositoryProvider);
      final careRepo = ref.watch(careEventRepositoryProvider);
      final reminderRepo = ref.watch(reminderRepositoryProvider);

      final plants = await plantRepo.getAllActive();
      final careEvents = await careRepo.getInRange(range.start, range.end);
      final reminders = await reminderRepo.getDueUntil(range.end);

      final plantsById = {for (final p in plants) p.id: p};

      final events = <CalendarEvent>[];

      // 1. Запланированный полив — из nextWaterDue.
      for (final plant in plants) {
        final due = plant.nextWaterDue;
        if (due == null) {
          continue;
        }
        if (due.isBefore(range.start) || due.isAfter(range.end)) {
          continue;
        }
        events.add(
          CalendarEvent(
            date: _dateOnly(due),
            type: 'watering',
            plantId: plant.id,
            plantName: plant.customName,
            isCompleted: false,
          ),
        );
      }

      // 2. Напоминания — из reminders.
      for (final r in reminders) {
        if (!r.isActive) {
          continue;
        }
        if (r.dueAt.isBefore(range.start) || r.dueAt.isAfter(range.end)) {
          continue;
        }
        if (r.type == 'watering') {
          continue;
        }
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

      // 3. Выполненные события.
      for (final e in careEvents) {
        final plant = plantsById[e.plantId];
        events.add(
          CalendarEvent(
            date: _dateOnly(e.performedAt),
            type: e.type,
            plantId: e.plantId,
            plantName: plant?.customName ?? 'Растение #${e.plantId}',
            isCompleted: true,
            careEventId: e.id,
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
          if (a.isCompleted == b.isCompleted) return 0;
          return a.isCompleted ? 1 : -1;
        });
      }
      return map;
    });

/// Оставляет только дату без времени.
DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
