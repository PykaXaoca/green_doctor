/// Конфигурация приложения.
///
/// Секреты (API-ключи, DSN) передаются через `--dart-define`, а не хранятся
/// в репозитории. Пример запуска:
///
///   flutter run \
///     --dart-define=METEOSOURCE_API_KEY=ваш_ключ
///
/// Для CI — через секреты GitHub Actions.
class AppConfig {
  AppConfig._();

  // ===========================================================================
  //  Погода — Meteosource
  // ===========================================================================

  /// API-ключ Meteosource.
  ///
  /// Получить бесплатно: https://www.meteosource.com/client
  /// Значение задаётся при сборке:
  ///   --dart-define=METEOSOURCE_API_KEY=...
  static const String meteosourceApiKey = String.fromEnvironment(
    'METEOSOURCE_API_KEY',
  );

  /// Базовый URL Meteosource (Free plan).
  static const String meteosourceBaseUrl =
      'https://www.meteosource.com/api/v1/free';

  /// Время жизни кеша погоды.
  static const Duration weatherCacheTtl = Duration(hours: 3);

  /// Есть ли ключ погоды.
  /// Если false — сервис погоды работает только на кеше.
  static bool get hasWeatherKey => meteosourceApiKey.isNotEmpty;

  // ===========================================================================
  //  Устаревшее — OpenWeatherMap
  // ===========================================================================
  // Поля оставлены для обратной совместимости: старые сборки могли
  // использовать их. Удалим, когда убедимся, что нигде не используются.

  /// @Deprecated — перешли на Meteosource.
  static const String openWeatherApiKey = String.fromEnvironment(
    'OPENWEATHER_API_KEY',
  );

  /// @Deprecated — перешли на Meteosource.
  static const String openWeatherBaseUrl =
      'https://api.openweathermap.org/data/2.5';
}