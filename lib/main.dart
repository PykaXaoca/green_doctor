import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/database/database.dart';
import 'core/providers/repository_providers.dart';
import 'core/providers/service_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru', null);

  final container = ProviderContainer();

  // 1. Импорт справочника видов растений.
  await container.read(speciesImporterProvider).importIfNeeded();

  // 2. Импорт достижений.
  await container.read(achievementSeederProvider).seedIfNeeded();

  // 3. Импорт справочника болезней.
  await container.read(diseaseSeederProvider).seedIfNeeded();

  // 4. Создание дефолтного пользователя.
  final userRepo = container.read(userRepositoryProvider);
  final existing = await userRepo.getAll();
  if (existing.isEmpty) {
    await userRepo.create(
      const AppUsersCompanion(displayName: Value('Садовод')),
    );
  }

  // 5. Уведомления.
  final notifications = container.read(notificationServiceProvider);
  await notifications.initialize();

  final plantRepo = container.read(plantRepositoryProvider);
  final plants = await plantRepo.getAllActive();
  await notifications.syncAll(plants);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const PocketBotanistApp(),
    ),
  );
}
