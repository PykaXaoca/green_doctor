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
  int get schemaVersion => 3;

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
      //
      // Служит базой отсчёта для следующей пересадки. Если null —
      // в расчёте используется `createdAt`. Существующие растения
      // получают null, что эквивалентно старому поведению.
      if (from < 3) {
        await m.addColumn(plants, plants.lastRepottedAt);
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
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'pocket_botanist.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
