import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/repository_providers.dart';
import 'core/providers/service_providers.dart';
import 'core/providers/settings_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Корневой виджет приложения.
class PocketBotanistApp extends ConsumerStatefulWidget {
  const PocketBotanistApp({super.key});

  @override
  ConsumerState<PocketBotanistApp> createState() => _PocketBotanistAppState();
}

class _PocketBotanistAppState extends ConsumerState<PocketBotanistApp> {
  /// Флаг защиты от параллельного запуска синхронизации настроек.
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _initNotificationHandling(),
    );
  }

  /// Инициализация обработки уведомлений.
  ///
  /// Не должна ронять приложение, если плагин недоступен: в тестах,
  /// на неподдерживаемых платформах или при отозванном разрешении
  /// просто пропускаем инициализацию.
  Future<void> _initNotificationHandling() async {
    try {
      final notifications = ref.read(notificationServiceProvider);

      notifications.onNotificationTap = _handlePayload;

      final launchPayload = await notifications.getLaunchPayload();
      if (launchPayload != null && launchPayload.isNotEmpty) {
        _handlePayload(launchPayload);
      }
    } catch (e, st) {
      debugPrint('Не удалось инициализировать уведомления: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  /// Синхронизирует настройки уведомлений с сервисом и **пересоздаёт**
  /// все запланированные уведомления.
  ///
  /// Вызывается только при **реальных** изменениях настроек после
  /// старта приложения. На старте синхронизацию делает [main], поэтому
  /// первый переход `loading → data` в [ref.listen] пропускается.
  Future<void> _syncSettingsToServices() async {
    if (_syncing) return;
    _syncing = true;
    try {
      final settings = ref.read(notificationSettingsSyncProvider);
      final notifications = ref.read(notificationServiceProvider);

      notifications.updateSettings(settings);

      final plantRepo = ref.read(plantRepositoryProvider);
      final plants = await plantRepo.getAllActive();
      await notifications.syncAll(plants);

      final treatmentScheduler = ref.read(treatmentSchedulerProvider);
      await treatmentScheduler.syncAll();
    } catch (e, st) {
      debugPrint('Ошибка пересинхронизации уведомлений: $e');
      debugPrintStack(stackTrace: st);
    } finally {
      _syncing = false;
    }
  }

  /// Обработка изменения настроек уведомлений.
  ///
  /// Отсеивает:
  ///  * первый переход `AsyncLoading → AsyncData` при старте (там
  ///    синхронизация уже сделана из `main.dart`);
  ///  * повторные срабатывания с тем же значением (Riverpod может
  ///    пересобирать провайдер без изменения данных).
  void _onSettingsChanged(
    NotificationSettings? previous,
    NotificationSettings? next,
  ) {
    // Первый переход loading → data при старте — пропускаем.
    if (previous == null) return;

    // Нет нового значения — пропускаем.
    if (next == null) return;

    // Значения идентичны — пропускаем.
    if (previous.enabled == next.enabled &&
        previous.summaryHour == next.summaryHour &&
        previous.groupByDay == next.groupByDay &&
        previous.treatmentEnabled == next.treatmentEnabled) {
      return;
    }

    _syncSettingsToServices();
  }

  void _handlePayload(String? payload) {
    if (payload == null || payload.isEmpty) return;

    final parts = payload.split(':');
    if (parts.isEmpty) return;

    switch (parts[0]) {
      case 'watering_summary':
        AppRouter.router.go('/today');
        break;
      case 'treatment':
        if (parts.length >= 2) {
          final diagnosisId = int.tryParse(parts[1]);
          if (diagnosisId != null) {
            AppRouter.router.go('/diagnosis/treatment/$diagnosisId');
          }
        }
        break;
      case 'plant':
        if (parts.length >= 2) {
          final plantId = int.tryParse(parts[1]);
          if (plantId != null) {
            AppRouter.router.go('/plants/$plantId');
          }
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Слушаем изменения настроек. Реагируем только на реальные
    // изменения после старта приложения.
    ref.listen<AsyncValue<NotificationSettings>>(notificationSettingsProvider, (
      previous,
      next,
    ) {
      _onSettingsChanged(previous?.asData?.value, next.asData?.value);
    });

    final themeModeAsync = ref.watch(appThemeModeProvider);
    final themeMode =
        themeModeAsync.asData?.value.toThemeMode() ?? ThemeMode.system;

    return MaterialApp.router(
      title: 'Карманный ботаник',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: AppRouter.router,

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ru'), Locale('en')],
      locale: const Locale('ru'),
    );
  }
}
