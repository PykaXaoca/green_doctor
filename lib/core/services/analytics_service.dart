import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/foundation.dart';

/// Сервис аналитики и краш-репортов на базе Yandex AppMetrica.
///
/// Заменяет Sentry. Регистрация бесплатна: https://appmetrica.yandex.ru
/// API-ключ передаётся через --dart-define=APPMETRICA_API_KEY=...
///
/// Если ключ не задан — сервис работает в режиме «no-op»:
/// все методы просто логируют и ничего не отправляют.
class AnalyticsService {
  AnalyticsService();

  bool _initialized = false;

  /// Инициализация AppMetrica. Вызывается один раз при старте приложения.
  Future<void> initialize() async {
    if (_initialized) return;

    const apiKey = String.fromEnvironment('APPMETRICA_API_KEY');
    if (apiKey.isEmpty) {
      debugPrint(
        '[AnalyticsService] APPMETRICA_API_KEY не задан. '
        'Аналитика отключена.',
      );
      return;
    }

    try {
      await AppMetrica.activate(
        const AppMetricaConfig(
          apiKey,
          crashReporting: true,
          flutterCrashReporting: true,
          logs: kDebugMode,
        ),
      );
      _initialized = true;
      debugPrint('[AnalyticsService] AppMetrica активирована.');
    } catch (e) {
      debugPrint('[AnalyticsService] Ошибка активации: $e');
    }
  }

  /// Отправить пользовательское событие без параметров.
  void reportEvent(String name) {
    if (!_initialized) return;
    try {
      AppMetrica.reportEvent(name);
    } catch (e) {
      debugPrint('[AnalyticsService] reportEvent ошибка: $e');
    }
  }

  /// Отправить пользовательское событие с параметрами.
  /// Использует `reportEventWithMap`, так как `reportEvent`
  /// в версии 4.1.0 не принимает параметры.
  void reportEventWithParams(String name, Map<String, Object>? params) {
    if (!_initialized) return;
    try {
      AppMetrica.reportEventWithMap(name, params);
    } catch (e) {
      debugPrint('[AnalyticsService] reportEventWithMap ошибка: $e');
    }
  }

  /// Сообщить об ошибке вручную.
  /// В версии 4.1.0 используется именованный параметр `message`.
  void reportError(String message, {StackTrace? stackTrace}) {
    if (!_initialized) return;
    try {
      AppMetrica.reportError(
        message: message,
        errorDescription: stackTrace != null
            ? AppMetricaErrorDescription(stackTrace)
            : null,
      );
    } catch (e) {
      debugPrint('[AnalyticsService] reportError ошибка: $e');
    }
  }

  /// Установить идентификатор пользователя (например, ID из твоей БД).
  void setUserProfileId(String id) {
    if (!_initialized) return;
    try {
      AppMetrica.setUserProfileID(id);
    } catch (e) {
      debugPrint('[AnalyticsService] setUserProfileID ошибка: $e');
    }
  }
}
