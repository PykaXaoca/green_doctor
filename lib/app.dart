import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _initNotificationHandling(),
    );
  }

  Future<void> _initNotificationHandling() async {
    final notifications = ref.read(notificationServiceProvider);

    notifications.onNotificationTap = _handlePayload;

    final launchPayload = await notifications.getLaunchPayload();
    if (launchPayload != null && launchPayload.isNotEmpty) {
      _handlePayload(launchPayload);
    }
  }

  /// Следит за изменениями темы и настроек уведомлений.
  void _syncSettingsToServices() {
    final settings = ref.read(notificationSettingsSyncProvider);
    ref.read(notificationServiceProvider).updateSettings(settings);
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
    // Слушаем изменения настроек и передаём в сервис уведомлений.
    ref.listen(notificationSettingsProvider, (_, _) {
      _syncSettingsToServices();
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
    );
  }
}
