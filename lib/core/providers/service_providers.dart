import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' show Position;

import '../services/achievement_checker.dart';
import '../services/achievement_seeder.dart';
import '../services/analytics_service.dart';
import '../services/care_scheduler.dart';
import '../services/disease_identifier_service.dart';
import '../services/disease_seeder.dart';
import '../services/gamification_service.dart';
import '../services/notification_service.dart';
import '../services/permissions_status_service.dart';
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

/// Сервис проверки разрешений, от которых зависят уведомления.
///
/// Работает с тем же плагином, что и [notificationServiceProvider],
/// но предоставляет отдельные методы для UI.
final permissionsStatusServiceProvider = Provider<PermissionsStatusService>((
  ref,
) {
  final notifService = ref.read(notificationServiceProvider);
  return PermissionsStatusService(notifService.plugin);
});

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

/// Тихая проверка: выдано ли разрешение на геолокацию и включён ли GPS.
final hasLocationProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(weatherServiceProvider);
  return service.hasLocationAccess();
});

/// Провайдер координат. Кэшируется Riverpod'ом.
final currentPositionProvider = FutureProvider<Position?>((ref) async {
  final service = ref.read(weatherServiceProvider);
  final result = await service.getCurrentPositionDetailed();
  return result.position;
});

/// Провайдер текущей погоды.
final currentWeatherProvider = FutureProvider<WeatherSnapshot?>((ref) async {
  final position = await ref.watch(currentPositionProvider.future);
  if (position == null) return null;

  final service = ref.read(weatherServiceProvider);
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

/// Провайдер сервиса аналитики.
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});
