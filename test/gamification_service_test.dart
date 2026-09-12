import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_botanist/core/database/database.dart';
import 'package:pocket_botanist/core/services/gamification_service.dart';

void main() {
  late AppDatabase db;
  late GamificationService service;
  late int userId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    service = GamificationService(db);
    userId = await db.userDao.insertUser(
      const AppUsersCompanion(displayName: Value('Тест')),
    );
  });

  tearDown(() async => db.close());

  group('calculateLevel', () {
    test('0 XP → 1 уровень', () {
      expect(service.calculateLevel(0), 1);
    });

    test('99 XP → 1 уровень', () {
      expect(service.calculateLevel(99), 1);
    });

    test('100 XP → 2 уровень', () {
      expect(service.calculateLevel(100), 2);
    });

    test('400 XP → 3 уровень', () {
      expect(service.calculateLevel(400), 3);
    });

    test('900 XP → 4 уровень', () {
      expect(service.calculateLevel(900), 4);
    });

    test('10000 XP → 11 уровень', () {
      expect(service.calculateLevel(10000), 11);
    });
  });

  group('xpRequiredForLevel', () {
    test('уровень 1 → 0', () => expect(service.xpRequiredForLevel(1), 0));
    test('уровень 2 → 100', () => expect(service.xpRequiredForLevel(2), 100));
    test('уровень 3 → 400', () => expect(service.xpRequiredForLevel(3), 400));
    test('уровень 4 → 900', () => expect(service.xpRequiredForLevel(4), 900));
  });

  group('progressToNextLevel', () {
    test('0% при 0 XP (уровень 1)', () {
      expect(service.progressToNextLevel(xp: 0, level: 1), 0.0);
    });
    test('50% при 50 XP (уровень 1)', () {
      expect(service.progressToNextLevel(xp: 50, level: 1), 0.5);
    });
  });

  group('addXp', () {
    test('добавляет XP и создаёт запись в истории', () async {
      final result = await service.addXp(
        userId: userId,
        amount: 10,
        reason: 'watering',
      );
      expect(result.addedXp, 10);
      expect(result.totalXp, 10);
      expect(result.level, 1);
      expect(result.levelUp, false);

      final history = await service.getHistory(userId);
      expect(history.length, 1);
      expect(history.first.amount, 10);
      expect(history.first.reason, 'watering');
    });

    test('повышает уровень при достижении порога', () async {
      await service.addXp(userId: userId, amount: 99, reason: 'test');
      final result = await service.addXp(
        userId: userId,
        amount: 1,
        reason: 'test',
      );
      expect(result.totalXp, 100);
      expect(result.level, 2);
      expect(result.levelUp, true);
    });

    test('игнорирует неположительные значения', () async {
      final result = await service.addXp(
        userId: userId,
        amount: 0,
        reason: 'test',
      );
      expect(result.addedXp, 0);
      final history = await service.getHistory(userId);
      expect(history, isEmpty);
    });
  });
}
