import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_botanist/core/database/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('Создание пользователя и чтение', () async {
    final id = await db.userDao.insertUser(
      const AppUsersCompanion(displayName: Value('Тест')),
    );
    final user = await db.userDao.getUserById(id);
    expect(user, isNotNull);
    expect(user!.displayName, 'Тест');
    expect(user.xp, 0);
    expect(user.level, 1);
    expect(user.subscriptionTier, 'free');
  });

  test('Создание растения с полями семян', () async {
    final userId = await db.userDao.insertUser(
      const AppUsersCompanion(displayName: Value('Садовод')),
    );

    final plantId = await db.plantDao.insertPlant(
      PlantsCompanion(
        userId: Value(userId),
        customName: const Value('Помидор'),
        seedVarietyName: const Value('Черри'),
        plantingLocation: const Value('Теплица №1'),
        seedlingPlantingDate: Value(DateTime(2026, 5, 1)),
      ),
    );

    final plant = await db.plantDao.getById(plantId);
    expect(plant, isNotNull);
    expect(plant!.customName, 'Помидор');
    expect(plant.seedVarietyName, 'Черри');
    expect(plant.plantingLocation, 'Теплица №1');
    expect(plant.seedlingPlantingDate, DateTime(2026, 5, 1));
  });

  test('Событие ухода сохраняется', () async {
    final userId = await db.userDao.insertUser(
      const AppUsersCompanion(displayName: Value('A')),
    );
    final plantId = await db.plantDao.insertPlant(
      PlantsCompanion(userId: Value(userId), customName: const Value('Фикус')),
    );

    await db.careEventDao.insertEvent(
      CareEventsCompanion(
        plantId: Value(plantId),
        type: const Value('watering'),
      ),
    );

    final events = await db.careEventDao.getByPlant(plantId);
    expect(events.length, 1);
    expect(events.first.type, 'watering');
  });

  test('AppMeta: запись и чтение', () async {
    await db.appMetaDao.setValue('import_done', 'true');
    final value = await db.appMetaDao.getValue('import_done');
    expect(value, 'true');
  });
}
