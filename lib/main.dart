import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/database/database.dart';
import 'core/providers/repository_providers.dart';
import 'core/providers/service_providers.dart';
import 'core/providers/settings_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru', null);

  final container = ProviderContainer();

  // 1. Импорт справочника видов растений.
  await _safeSeed(
    label: 'species',
    action: () => container.read(speciesImporterProvider).importIfNeeded(),
  );

  // 2. Импорт достижений.
  await _safeSeed(
    label: 'achievements',
    action: () => container.read(achievementSeederProvider).seedIfNeeded(),
  );

  // 3. Импорт справочника болезней.
  await _safeSeed(
    label: 'diseases',
    action: () => container.read(diseaseSeederProvider).seedIfNeeded(),
  );

  // 4. Создание дефолтного пользователя.
  final userRepo = container.read(userRepositoryProvider);
  final existing = await userRepo.getAll();
  if (existing.isEmpty) {
    await userRepo.create(
      const AppUsersCompanion(displayName: Value('Садовод')),
    );
  }

  // 4.5. Аналитика и краш-репорты (AppMetrica).
  // Если APPMETRICA_API_KEY не задан через --dart-define,
  // сервис молча отключается (см. AnalyticsService.initialize).
  await container.read(analyticsServiceProvider).initialize();

  // 5. Уведомления — инициализация и передача настроек.
  final notifications = container.read(notificationServiceProvider);
  await notifications.initialize();

  final notifSettings = await container.read(
    notificationSettingsProvider.future,
  );
  notifications.updateSettings(notifSettings);

  final plantRepo = container.read(plantRepositoryProvider);
  final plants = await plantRepo.getAllActive();
  await notifications.syncAll(plants);

  // 6. Синхронизация уведомлений о шагах лечения.
  final treatmentScheduler = container.read(treatmentSchedulerProvider);
  await treatmentScheduler.syncAll();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const PocketBotanistApp(),
    ),
  );
}

/// Безопасно выполняет сидер: при ошибке логирует и продолжает запуск.
Future<void> _safeSeed({
  required String label,
  required Future<void> Function() action,
}) async {
  try {
    await action();
  } catch (e, st) {
    if (kDebugMode) {
      debugPrint('[main] Сидер "$label" упал: $e\n$st');
    }
  }
}
