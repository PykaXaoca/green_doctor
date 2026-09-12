/// Конфигурация приложения.
///
/// Секреты (API-ключи, DSN) передаются через `--dart-define`, а не хранятся
/// в репозитории. Пример запуска:
///
///   flutter run \
///     --dart-define=OPENWEATHER_API_KEY=ваш_ключ
///
/// Для CI — через секреты GitHub Actions.
class AppConfig {
  AppConfig._();

  /// API-ключ OpenWeatherMap.
  ///
  /// Получить бесплатно: https://openweathermap.org/api
  /// Значение задаётся при сборке:
  ///   --dart-define=OPENWEATHER_API_KEY=...
  static const String openWeatherApiKey = String.fromEnvironment(
    'OPENWEATHER_API_KEY',
  );

  /// Базовый URL OpenWeatherMap.
  static const String openWeatherBaseUrl =
      'https://api.openweathermap.org/data/2.5';

  /// Время жизни кеша погоды.
  static const Duration weatherCacheTtl = Duration(hours: 3);

  /// Есть ли ключ погоды. Если false — сервис погоды работает только на кеше.
  static bool get hasWeatherKey => openWeatherApiKey.isNotEmpty;
}
