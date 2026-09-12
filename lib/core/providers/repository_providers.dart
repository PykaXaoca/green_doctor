import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/achievement_repository_impl.dart';
import '../../data/repositories/care_event_repository_impl.dart';
import '../../data/repositories/diagnosis_repository_impl.dart';
import '../../data/repositories/plant_repository_impl.dart';
import '../../data/repositories/reminder_repository_impl.dart';
import '../../data/repositories/species_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../domain/repositories/achievement_repository.dart';
import '../../domain/repositories/care_event_repository.dart';
import '../../domain/repositories/diagnosis_repository.dart';
import '../../domain/repositories/plant_repository.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../domain/repositories/species_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/weather_repository.dart';
import '../services/image_storage_service.dart';
import '../services/species_importer.dart';
import 'database_providers.dart';

final plantRepositoryProvider = Provider<PlantRepository>(
  (ref) => PlantRepositoryImpl(ref.read(databaseProvider)),
);

final careEventRepositoryProvider = Provider<CareEventRepository>(
  (ref) => CareEventRepositoryImpl(ref.read(databaseProvider)),
);

final reminderRepositoryProvider = Provider<ReminderRepository>(
  (ref) => ReminderRepositoryImpl(ref.read(databaseProvider)),
);

final speciesRepositoryProvider = Provider<SpeciesRepository>(
  (ref) => SpeciesRepositoryImpl(ref.read(databaseProvider)),
);

final diagnosisRepositoryProvider = Provider<DiagnosisRepository>(
  (ref) => DiagnosisRepositoryImpl(ref.read(databaseProvider)),
);

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepositoryImpl(ref.read(databaseProvider)),
);

final weatherRepositoryProvider = Provider<WeatherRepository>(
  (ref) => WeatherRepositoryImpl(ref.read(databaseProvider)),
);

final achievementRepositoryProvider = Provider<AchievementRepository>(
  (ref) => AchievementRepositoryImpl(ref.read(databaseProvider)),
);

final speciesImporterProvider = Provider<SpeciesImporter>(
  (ref) => SpeciesImporter(ref.read(databaseProvider)),
);

final imageStorageServiceProvider = Provider<ImageStorageService>(
  (ref) => ImageStorageService(),
);
