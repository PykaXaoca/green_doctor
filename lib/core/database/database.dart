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

  /// Конструктор для тестов (in-memory).
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'pocket_botanist.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
