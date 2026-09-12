import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_botanist/core/database/database.dart';
import 'package:pocket_botanist/core/services/care_scheduler.dart';

void main() {
  const scheduler = CareScheduler();

  Plant buildPlant({
    DateTime? nextWaterDue,
    int? frequencyDays,
    DateTime? createdAt,
    DateTime? lastWateredAt,
  }) {
    return Plant(
      id: 1,
      userId: 1,
      customName: 'Тест',
      wateringFrequencyDays: frequencyDays,
      nextWaterDue: nextWaterDue,
      createdAt: createdAt ?? DateTime(2026, 1, 1),
      lastWateredAt: lastWateredAt,
      isArchived: false,
    );
  }

  group('calculateNextWatering', () {
    test('возвращает null, если частота не задана', () {
      final result = scheduler.calculateNextWatering(
        from: DateTime(2026, 1, 1),
        frequencyDays: null,
      );
      expect(result, isNull);
    });

    test('от lastWateredAt + frequencyDays', () {
      final result = scheduler.calculateNextWatering(
        lastWateredAt: DateTime(2026, 5, 1),
        from: DateTime(2026, 1, 1),
        frequencyDays: 7,
      );
      expect(result, DateTime(2026, 5, 8));
    });

    test('от from, если lastWateredAt == null', () {
      final result = scheduler.calculateNextWatering(
        from: DateTime(2026, 5, 1),
        frequencyDays: 3,
      );
      expect(result, DateTime(2026, 5, 4));
    });
  });

  group('isWateringDue', () {
    test('true, если срок наступил сегодня', () {
      final now = DateTime(2026, 5, 10, 12);
      final plant = buildPlant(
        nextWaterDue: DateTime(2026, 5, 10, 9),
        frequencyDays: 7,
      );
      expect(scheduler.isWateringDue(plant, now: now), true);
    });

    test('true, если срок в прошлом (просрочено)', () {
      final now = DateTime(2026, 5, 10);
      final plant = buildPlant(nextWaterDue: DateTime(2026, 5, 5));
      expect(scheduler.isWateringDue(plant, now: now), true);
    });

    test('false, если срок в будущем', () {
      final now = DateTime(2026, 5, 10);
      final plant = buildPlant(nextWaterDue: DateTime(2026, 5, 15));
      expect(scheduler.isWateringDue(plant, now: now), false);
    });

    test('false, если nextWaterDue == null', () {
      final plant = buildPlant(nextWaterDue: null);
      expect(scheduler.isWateringDue(plant), false);
    });
  });

  group('isWateringOverdue', () {
    test('true, если срок раньше начала сегодня', () {
      final now = DateTime(2026, 5, 10, 12);
      final plant = buildPlant(nextWaterDue: DateTime(2026, 5, 9, 23, 59));
      expect(scheduler.isWateringOverdue(plant, now: now), true);
    });

    test('false, если срок сегодня', () {
      final now = DateTime(2026, 5, 10, 12);
      final plant = buildPlant(nextWaterDue: DateTime(2026, 5, 10, 9));
      expect(scheduler.isWateringOverdue(plant, now: now), false);
    });
  });

  group('daysUntilWatering', () {
    test('0 — сегодня', () {
      final now = DateTime(2026, 5, 10, 12);
      final plant = buildPlant(nextWaterDue: DateTime(2026, 5, 10, 9));
      expect(scheduler.daysUntilWatering(plant, now: now), 0);
    });

    test('отрицательное число — просрочено', () {
      final now = DateTime(2026, 5, 10, 12);
      final plant = buildPlant(nextWaterDue: DateTime(2026, 5, 7));
      expect(scheduler.daysUntilWatering(plant, now: now), -3);
    });

    test('положительное — сколько ждать', () {
      final now = DateTime(2026, 5, 10);
      final plant = buildPlant(nextWaterDue: DateTime(2026, 5, 14));
      expect(scheduler.daysUntilWatering(plant, now: now), 4);
    });
  });
}
