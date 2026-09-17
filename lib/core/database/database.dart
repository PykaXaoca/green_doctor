import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/achievement_dao.dart';
import 'daos/app_meta_dao.dart';
import 'daos/care_event_dao.dart';
import 'daos/diagnosis_dao.dart';
import 'daos/disease_dao.dart';
import 'daos/plant_dao.dart';
import 'daos/reminder_dao.dart';
import 'daos/species_dao.dart';
import 'daos/user_dao.dart';
import 'daos/weather_dao.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    AppUsers,
    PlantSpecies,
    Plants,
    CareEvents,
    Reminders,
    WeatherCache,
    PlantDiseases,
    Diagnoses,
    TreatmentSteps,
    Achievements,
    UserAchievements,
    UserXpEvents,
    AppMeta,
  ],
  daos: [
    UserDao,
    SpeciesDao,
    PlantDao,
    CareEventDao,
    ReminderDao,
    WeatherDao,
    DiseaseDao,
    DiagnosisDao,
    AchievementDao,
    AppMetaDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // v1 → v2: расширение справочника видов растений.
      if (from < 2) {
        await m.addColumn(plantSpecies, plantSpecies.category);
        await m.addColumn(plantSpecies, plantSpecies.fertilizingFrequencyDays);
        await m.addColumn(plantSpecies, plantSpecies.fertilizerType);
        await m.addColumn(plantSpecies, plantSpecies.soilMoisture);
        await m.addColumn(plantSpecies, plantSpecies.repottingFrequencyMonths);
        await m.addColumn(plantSpecies, plantSpecies.pruningInfo);

        await customStatement(
          "DELETE FROM app_meta WHERE key = 'species_imported'",
        );
      }

      // v2 → v3: поле `lastRepottedAt` у растения.
      if (from < 3) {
        await m.addColumn(plants, plants.lastRepottedAt);
      }

      // v3 → v4: опрыскивание — частота и дата последнего.
      if (from < 4) {
        await m.addColumn(plants, plants.mistingFrequencyDays);
        await m.addColumn(plants, plants.lastMistedAt);
      }

      // v4 → v5: расширенный профиль — город и био.
      if (from < 5) {
        await m.addColumn(appUsers, appUsers.city);
        await m.addColumn(appUsers, appUsers.bio);
      }

      // v5 → v6: садовые растения — сезонный уход и стадии роста.
      if (from < 6) {
        // Справочник видов: признак «комнатное» + JSON сезонных
        // рекомендаций. Старые записи получат `isIndoor = true`,
        // но при следующем запуске справочник переимпортируется
        // (мы сбрасываем флаг ниже) и значения перезапишутся
        // корректно.
        await m.addColumn(plantSpecies, plantSpecies.isIndoor);
        await m.addColumn(plantSpecies, plantSpecies.seasonalCareJson);

        // Растение пользователя: дата посадки и текущая стадия роста.
        await m.addColumn(plants, plants.plantedAt);
        await m.addColumn(plants, plants.growthStage);

        // Форсируем переимпорт справочника при следующем запуске,
        // чтобы заполнились новые поля.
        await customStatement(
          "DELETE FROM app_meta WHERE key = 'species_imported'",
        );
      }
    },
  );

  /// Каскадное удаление растения.
  Future<void> deletePlantCascade(int plantId) async {
    await transaction(() async {
      final diagnosisRows = await (select(
        diagnoses,
      )..where((t) => t.plantId.equals(plantId))).get();
      final diagnosisIds = diagnosisRows.map((d) => d.id).toList();

      if (diagnosisIds.isNotEmpty) {
        await (delete(
          treatmentSteps,
        )..where((t) => t.diagnosisId.isIn(diagnosisIds))).go();
      }

      await (delete(diagnoses)..where((t) => t.plantId.equals(plantId))).go();
      await (delete(careEvents)..where((t) => t.plantId.equals(plantId))).go();
      await (delete(reminders)..where((t) => t.plantId.equals(plantId))).go();
      await (delete(plants)..where((t) => t.id.equals(plantId))).go();
    });
  }

  /// Полная очистка данных пользователя: растения, события, диагнозы,
  /// напоминания, достижения и XP. Пользователь остаётся, но его
  /// прогресс обнуляется.
  Future<void> resetUserData(int userId) async {
    await transaction(() async {
      await delete(careEvents).go();
      await delete(treatmentSteps).go();
      await delete(diagnoses).go();
      await delete(reminders).go();
      await delete(plants).go();
      await (delete(
        userAchievements,
      )..where((t) => t.userId.equals(userId))).go();
      await (delete(userXpEvents)..where((t) => t.userId.equals(userId))).go();
      await (update(appUsers)..where((t) => t.id.equals(userId))).write(
        const AppUsersCompanion(xp: Value(0), level: Value(1)),
      );
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'pocket_botanist.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
