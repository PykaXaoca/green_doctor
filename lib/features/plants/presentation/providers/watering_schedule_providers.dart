import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import 'plant_providers.dart';

/// Горизонт планирования — 14 дней вперёд.
const int kScheduleDaysAhead = 14;

/// Расписание поливов на ближайшие [kScheduleDaysAhead] дней.
class WateringScheduleData {
  const WateringScheduleData({
    required this.overdue,
    required this.byDay,
    required this.startDate,
    required this.endDate,
  });

  /// Растения, у которых `nextWaterDue` в прошлом.
  final List<Plant> overdue;

  /// Ключ — дата без времени. Значение — растения, которые
  /// нужно полить в этот день.
  final Map<DateTime, List<Plant>> byDay;

  final DateTime startDate;
  final DateTime endDate;

  int countFor(DateTime day) => byDay[_dateOnly(day)]?.length ?? 0;
  int get todayCount => countFor(DateTime.now());

  /// Общее количество запланированных поливов за горизонт.
  int get totalScheduled =>
      byDay.values.fold(0, (sum, list) => sum + list.length);

  /// Расписание полностью пустое (нет ни просроченных, ни будущих).
  bool get isEmpty => overdue.isEmpty && byDay.isEmpty;

  /// Список всех дней в горизонте — для рендера.
  List<DateTime> get days {
    final result = <DateTime>[];
    final total = endDate.difference(startDate).inDays;
    for (var i = 0; i <= total; i++) {
      result.add(startDate.add(Duration(days: i)));
    }
    return result;
  }
}

final wateringScheduleProvider = FutureProvider<WateringScheduleData>((
  ref,
) async {
  final plants = await ref.watch(userPlantsProvider.future);

  final today = _dateOnly(DateTime.now());
  final endDate = today.add(const Duration(days: kScheduleDaysAhead));

  final overdue = <Plant>[];
  final byDay = <DateTime, List<Plant>>{};

  for (final plant in plants) {
    final due = plant.nextWaterDue;
    final freq = plant.wateringFrequencyDays;
    if (due == null || freq == null || freq <= 0) continue;

    final dueDay = _dateOnly(due);

    // Просроченные — в отдельный список.
    if (dueDay.isBefore(today)) {
      overdue.add(plant);
      continue;
    }

    // Будущие — до конца горизонта с шагом frequencyDays.
    var date = dueDay;
    while (!date.isAfter(endDate)) {
      byDay.putIfAbsent(date, () => <Plant>[]).add(plant);
      date = date.add(Duration(days: freq));
    }
  }

  // Сортировка по имени.
  overdue.sort(
    (a, b) => a.customName.toLowerCase().compareTo(b.customName.toLowerCase()),
  );
  for (final list in byDay.values) {
    list.sort(
      (a, b) =>
          a.customName.toLowerCase().compareTo(b.customName.toLowerCase()),
    );
  }

  return WateringScheduleData(
    overdue: overdue,
    byDay: byDay,
    startDate: today,
    endDate: endDate,
  );
});

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
