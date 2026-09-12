import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_botanist/core/database/database.dart';
import 'package:pocket_botanist/data/repositories/care_event_repository_impl.dart';
import 'package:pocket_botanist/data/repositories/plant_repository_impl.dart';
import 'package:pocket_botanist/data/repositories/user_repository_impl.dart';

void main() {
  late AppDatabase db;
  late UserRepositoryImpl userRepo;
  late PlantRepositoryImpl plantRepo;
  late CareEventRepositoryImpl careRepo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    userRepo = UserRepositoryImpl(db);
    plantRepo = PlantRepositoryImpl(db);
    careRepo = CareEventRepositoryImpl(db);
  });

  tearDown(() async => db.close());

  test('PlantRepository: создание и получение растения', () async {
    final userId = await userRepo.create(
      const AppUsersCompanion(displayName: Value('A')),
    );

    final plantId = await plantRepo.create(
      PlantsCompanion(
        userId: Value(userId),
        customName: const Value('Монстера'),
      ),
    );

    final plant = await plantRepo.getById(plantId);
    expect(plant, isNotNull);
    expect(plant!.customName, 'Монстера');
  });

  test('PlantRepository: архив растения исключает из активных', () async {
    final userId = await userRepo.create(
      const AppUsersCompanion(displayName: Value('A')),
    );
    final plantId = await plantRepo.create(
      PlantsCompanion(userId: Value(userId), customName: const Value('X')),
    );

    await plantRepo.archive(plantId);
    final active = await plantRepo.getAllActive();

    expect(active.where((p) => p.id == plantId), isEmpty);
  });

  test('CareEventRepository: подсчёт событий по типу', () async {
    final userId = await userRepo.create(
      const AppUsersCompanion(displayName: Value('A')),
    );
    final plantId = await plantRepo.create(
      PlantsCompanion(userId: Value(userId), customName: const Value('Y')),
    );

    await careRepo.add(
      CareEventsCompanion(
        plantId: Value(plantId),
        type: const Value('watering'),
      ),
    );
    await careRepo.add(
      CareEventsCompanion(
        plantId: Value(plantId),
        type: const Value('watering'),
      ),
    );
    await careRepo.add(
      CareEventsCompanion(
        plantId: Value(plantId),
        type: const Value('fertilizing'),
      ),
    );

    expect(await careRepo.countByType('watering'), 2);
    expect(await careRepo.countByType('fertilizing'), 1);
  });

  test('UserRepository: XP-события пишутся в историю', () async {
    final userId = await userRepo.create(
      const AppUsersCompanion(displayName: Value('B')),
    );

    await userRepo.addXpEvent(
      UserXpEventsCompanion(
        userId: Value(userId),
        amount: const Value(10),
        reason: const Value('watering'),
      ),
    );
    await userRepo.addXpEvent(
      UserXpEventsCompanion(
        userId: Value(userId),
        amount: const Value(50),
        reason: const Value('diagnosis'),
      ),
    );

    final history = await userRepo.getXpHistory(userId);
    expect(history.length, 2);
    expect(history.map((e) => e.amount).reduce((a, b) => a + b), 60);
  });
}
