import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_botanist/core/database/database.dart';
import 'package:pocket_botanist/core/services/achievement_checker.dart';
import 'package:pocket_botanist/core/services/achievement_seeder.dart';
import 'package:pocket_botanist/core/services/gamification_service.dart';

void main() {
  late AppDatabase db;
  late GamificationService gamification;
  late AchievementChecker checker;
  late AchievementSeeder seeder;
  late int userId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    gamification = GamificationService(db);
    checker = AchievementChecker(db, gamification);
    seeder = AchievementSeeder(db);
    userId = await db.userDao.insertUser(
      const AppUsersCompanion(displayName: Value('Тест')),
    );
    await seeder.seed();
  });

  tearDown(() async => db.close());

  test(
    'Достижение "first_plant" разблокируется после добавления растения',
    () async {
      // Никаких растений — ничего не разблокируется.
      var unlocked = await checker.checkAll(userId);
      expect(unlocked, isEmpty);

      // Добавляем растение.
      await db.plantDao.insertPlant(
        PlantsCompanion(
          userId: Value(userId),
          customName: const Value('Тестовое'),
        ),
      );

      unlocked = await checker.checkAll(userId);
      expect(unlocked.contains('first_plant'), true);
    },
  );

  test('Достижение не разблокируется повторно', () async {
    await db.plantDao.insertPlant(
      PlantsCompanion(
        userId: Value(userId),
        customName: const Value('Тестовое'),
      ),
    );

    final first = await checker.checkAll(userId);
    expect(first.contains('first_plant'), true);

    final second = await checker.checkAll(userId);
    expect(second.contains('first_plant'), false);
  });

  test('Достижение "level_5" не разблокируется при 1 уровне', () async {
    final unlocked = await checker.checkAll(userId);
    expect(unlocked.contains('level_5'), false);
  });

  test('Каталог достижений загружается в БД', () async {
    final all = await db.achievementDao.getAll();
    expect(all.length, greaterThanOrEqualTo(10));
  });
}
