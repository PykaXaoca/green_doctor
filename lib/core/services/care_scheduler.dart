import '../database/database.dart';

/// Сервис для расчёта графика ухода за растением.
class CareScheduler {
  const CareScheduler();

  /// Вычисляет дату следующего полива.
  ///
  /// Если [lastWateredAt] задан — прибавляем [frequencyDays].
  /// Иначе — от [from] (обычно createdAt).
  DateTime? calculateNextWatering({
    DateTime? lastWateredAt,
    required DateTime from,
    int? frequencyDays,
  }) {
    if (frequencyDays == null || frequencyDays <= 0) return null;
    final base = lastWateredAt ?? from;
    return base.add(Duration(days: frequencyDays));
  }

  /// Расчёт nextWaterDue при создании растения (lastWateredAt == null).
  DateTime? calculateInitialWatering({
    required DateTime createdAt,
    int? frequencyDays,
  }) {
    return calculateNextWatering(
      lastWateredAt: null,
      from: createdAt,
      frequencyDays: frequencyDays,
    );
  }

  /// Проверяет, требует ли растение полива сегодня или просрочено.
  bool isWateringDue(Plant plant, {DateTime? now}) {
    final due = plant.nextWaterDue;
    if (due == null) return false;
    final current = now ?? DateTime.now();
    final endOfDay = DateTime(
      current.year,
      current.month,
      current.day,
      23,
      59,
      59,
    );
    return !due.isAfter(endOfDay);
  }

  /// Проверяет, просрочен ли полив (дата в прошлом, не считая сегодня).
  bool isWateringOverdue(Plant plant, {DateTime? now}) {
    final due = plant.nextWaterDue;
    if (due == null) return false;
    final current = now ?? DateTime.now();
    final startOfToday = DateTime(current.year, current.month, current.day);
    return due.isBefore(startOfToday);
  }

  /// Возвращает количество дней до следующего полива.
  /// Отрицательное значение — просрочено.
  int? daysUntilWatering(Plant plant, {DateTime? now}) {
    final due = plant.nextWaterDue;
    if (due == null) return null;
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    final dueDay = DateTime(due.year, due.month, due.day);
    return dueDay.difference(today).inDays;
  }
}
