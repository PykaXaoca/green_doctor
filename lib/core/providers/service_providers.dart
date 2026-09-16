import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/achievement_checker.dart';
import '../services/achievement_seeder.dart';
import '../services/care_scheduler.dart';
import '../services/disease_identifier_service.dart';
import '../services/disease_seeder.dart';
import '../services/gamification_service.dart';
import '../services/notification_service.dart';
import '../services/static_treatment_plan_source.dart';
import '../services/treatment_plan_source.dart';
import '../services/treatment_scheduler.dart';
import '../services/watering_advisor.dart';
import '../services/weather_service.dart';
import '../usecases/complete_care_event.dart';
import '../usecases/start_treatment.dart';
import '../usecases/undo_care_event.dart';
import 'database_providers.dart';
import 'repository_providers.dart';

final careSchedulerProvider = Provider<CareScheduler>(
  (ref) => const CareScheduler(),
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

final treatmentSchedulerProvider = Provider<TreatmentScheduler>(
  (ref) => TreatmentScheduler(
    ref.read(databaseProvider),
    ref.read(notificationServiceProvider),
  ),
);

final treatmentPlanSourceProvider = Provider<TreatmentPlanSource>(
  (ref) => const StaticTreatmentPlanSource(),
);

final gamificationServiceProvider = Provider<GamificationService>(
  (ref) => GamificationService(ref.read(databaseProvider)),
);

final achievementSeederProvider = Provider<AchievementSeeder>(
  (ref) => AchievementSeeder(ref.read(databaseProvider)),
);

final achievementCheckerProvider = Provider<AchievementChecker>(
  (ref) => AchievementChecker(
    ref.read(databaseProvider),
    ref.read(gamificationServiceProvider),
  ),
);

final completeCareEventProvider = Provider<CompleteCareEvent>(
  (ref) => CompleteCareEvent(
    ref.read(databaseProvider),
    ref.read(careSchedulerProvider),
    ref.read(notificationServiceProvider),
    ref.read(gamificationServiceProvider),
    ref.read(achievementCheckerProvider),
  ),
);

final undoCareEventProvider = Provider<UndoCareEvent>(
  (ref) => UndoCareEvent(
    ref.read(databaseProvider),
    ref.read(careSchedulerProvider),
    ref.read(notificationServiceProvider),
  ),
);

final weatherServiceProvider = Provider<WeatherService>(
  (ref) => WeatherService(ref.read(databaseProvider)),
);

final wateringAdvisorProvider = Provider<WateringAdvisor>(
  (ref) => const WateringAdvisor(),
);

final currentWeatherProvider = FutureProvider<WeatherSnapshot?>((ref) async {
  final service = ref.read(weatherServiceProvider);
  final position = await service.getCurrentPosition();
  if (position == null) return null;
  return service.getWeather(lat: position.latitude, lon: position.longitude);
});

final diseaseIdentifierProvider = Provider<DiseaseIdentifierService>(
  (ref) => DiseaseIdentifierService(),
);

final diseaseSeederProvider = Provider<DiseaseSeeder>(
  (ref) => DiseaseSeeder(ref.read(databaseProvider)),
);

final startTreatmentProvider = Provider<StartTreatment>(
  (ref) => StartTreatment(
    ref.read(databaseProvider),
    ref.read(treatmentPlanSourceProvider),
    ref.read(treatmentSchedulerProvider),
    ref.read(gamificationServiceProvider),
    ref.read(imageStorageServiceProvider),
  ),
);
