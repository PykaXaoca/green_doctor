import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

import '../config/app_config.dart';
import '../database/database.dart';

/// Сервис получения погоды через Open-Meteo с кешированием.
///
/// Open-Meteo — бесплатный API без ключа и регистрации.
/// Документация: https://open-meteo.com/en/docs
class WeatherService {
  WeatherService(this._db, {Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(seconds: 10)
      ..sendTimeout = const Duration(seconds: 10);
  }

  final AppDatabase _db;
  final Dio _dio;

  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  /// Получить текущие координаты (с запросом разрешения).
  Future<Position?> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    );
  }

  /// Получить погоду для координат. Сначала проверяет кеш.
  Future<WeatherSnapshot?> getWeather({
    required double lat,
    required double lon,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = await _db.weatherDao.getFresh(lat, lon);
      if (cached != null) {
        return _parseOpenMeteo(cached.payloadJson);
      }
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _baseUrl,
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'current':
              'temperature_2m,relative_humidity_2m,apparent_temperature,'
              'is_day,precipitation,weather_code,cloud_cover,'
              'pressure_msl,wind_speed_10m,wind_direction_10m,uv_index',
          'daily':
              'temperature_2m_max,temperature_2m_min,weather_code,'
              'precipitation_probability_max,precipitation_sum,'
              'sunrise,sunset,uv_index_max,'
              'wind_speed_10m_max,wind_direction_10m_dominant',
          'timezone': 'auto',
          'forecast_days': 7,
          'wind_speed_unit': 'ms',
        },
      );

      final data = response.data;
      if (data == null) return await _getLatestCached();

      final now = DateTime.now();
      await _db.weatherDao.insertCache(
        WeatherCacheCompanion.insert(
          latitude: lat,
          longitude: lon,
          payloadJson: jsonEncode(data),
          expiresAt: now.add(AppConfig.weatherCacheTtl),
        ),
      );

      return _parseOpenMeteo(jsonEncode(data));
    } catch (_) {
      return await _getLatestCached();
    }
  }

  /// Очистить старый кеш.
  Future<void> clearExpired() => _db.weatherDao.clearExpired();

  /// Последний по времени кеш из БД (без проверки на свежесть).
  Future<WeatherSnapshot?> _getLatestCached() async {
    final all = await _db.weatherDao.getAll();
    if (all.isEmpty) return null;
    final latest = all.reduce(
      (a, b) => a.fetchedAt.isAfter(b.fetchedAt) ? a : b,
    );
    return _parseOpenMeteo(latest.payloadJson);
  }

  WeatherSnapshot? _parseOpenMeteo(String json) {
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;

      final current = map['current'] as Map<String, dynamic>?;
      if (current == null) return null;

      final currentTemp = _toDouble(current['temperature_2m']) ?? 0.0;
      final currentHumidity = _toInt(current['relative_humidity_2m']) ?? 0;
      final apparentTemp =
          _toDouble(current['apparent_temperature']) ?? currentTemp;
      final weatherCode = _toInt(current['weather_code']) ?? 0;
      final isDayRaw = _toInt(current['is_day']);
      final isDay = isDayRaw == null ? true : isDayRaw == 1;
      final precipitation = _toDouble(current['precipitation']) ?? 0.0;
      final cloudCover = _toInt(current['cloud_cover']) ?? 0;
      final pressure = _toDouble(current['pressure_msl']) ?? 0.0;
      final windSpeed = _toDouble(current['wind_speed_10m']) ?? 0.0;
      final windDirection = _toInt(current['wind_direction_10m']) ?? 0;
      final uvIndex = _toDouble(current['uv_index']);

      final currentTimeStr = current['time'] as String?;
      final currentDt = currentTimeStr != null
          ? DateTime.tryParse(currentTimeStr) ?? DateTime.now()
          : DateTime.now();

      final daily = map['daily'] as Map<String, dynamic>?;
      final dailyForecasts = <DailyForecast>[];
      if (daily != null) {
        final times = daily['time'] as List?;
        final maxes = daily['temperature_2m_max'] as List?;
        final mins = daily['temperature_2m_min'] as List?;
        final codes = daily['weather_code'] as List?;
        final pops = daily['precipitation_probability_max'] as List?;
        final precipSums = daily['precipitation_sum'] as List?;
        final sunrises = daily['sunrise'] as List?;
        final sunsets = daily['sunset'] as List?;
        final uvMaxes = daily['uv_index_max'] as List?;
        final windMaxes = daily['wind_speed_10m_max'] as List?;
        final windDirs = daily['wind_direction_10m_dominant'] as List?;

        if (times != null) {
          for (var i = 0; i < times.length; i++) {
            final dateStr = _at<String>(times, i);
            final date = dateStr != null ? DateTime.tryParse(dateStr) : null;
            if (date == null) continue;

            final popRaw = _toDouble(_at<num>(pops, i));
            final pop = ((popRaw ?? 0.0) / 100.0).clamp(0.0, 1.0);

            final code = _toInt(_at<num>(codes, i)) ?? 0;

            dailyForecasts.add(
              DailyForecast(
                date: DateTime(date.year, date.month, date.day),
                tempMin: _toDouble(_at<num>(mins, i)) ?? 0.0,
                tempMax: _toDouble(_at<num>(maxes, i)) ?? 0.0,
                precipitationProbability: pop,
                precipitationSum: _toDouble(_at<num>(precipSums, i)) ?? 0.0,
                weatherCode: code,
                icon: _iconForCode(code),
                description: _descriptionForCode(code),
                sunrise: _parseDateTime(_at<String>(sunrises, i)),
                sunset: _parseDateTime(_at<String>(sunsets, i)),
                uvIndexMax: _toDouble(_at<num>(uvMaxes, i)),
                windSpeedMax: _toDouble(_at<num>(windMaxes, i)),
                windDirectionDominant: _toInt(_at<num>(windDirs, i)),
              ),
            );
          }
        }
      }

      return WeatherSnapshot(
        fetchedAt: DateTime.now(),
        currentTemp: currentTemp,
        currentHumidity: currentHumidity,
        currentDescription: _descriptionForCode(weatherCode),
        currentIcon: _iconForCode(weatherCode),
        currentDt: currentDt,
        daily: dailyForecasts,
        apparentTemp: apparentTemp,
        isDay: isDay,
        precipitation: precipitation,
        cloudCover: cloudCover,
        pressure: pressure,
        windSpeed: windSpeed,
        windDirection: windDirection,
        uvIndex: uvIndex,
      );
    } catch (_) {
      return null;
    }
  }

  // -----------------------------------------------------------------
  //  Вспомогательные парсеры
  // -----------------------------------------------------------------

  double? _toDouble(Object? v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return null;
  }

  int? _toInt(Object? v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    return null;
  }

  T? _at<T>(List? list, int i) {
    if (list == null || i < 0 || i >= list.length) return null;
    final v = list[i];
    return v is T ? v : null;
  }

  DateTime? _parseDateTime(String? s) {
    if (s == null) return null;
    return DateTime.tryParse(s);
  }

  /// WMO weather code → текстовое описание на русском.
  String _descriptionForCode(int code) {
    switch (code) {
      case 0:
        return 'Ясно';
      case 1:
        return 'Преимущественно ясно';
      case 2:
        return 'Переменная облачность';
      case 3:
        return 'Пасмурно';
      case 45:
      case 48:
        return 'Туман';
      case 51:
      case 53:
      case 55:
        return 'Морось';
      case 56:
      case 57:
        return 'Ледяная морось';
      case 61:
        return 'Небольшой дождь';
      case 63:
        return 'Дождь';
      case 65:
        return 'Сильный дождь';
      case 66:
      case 67:
        return 'Ледяной дождь';
      case 71:
        return 'Небольшой снег';
      case 73:
        return 'Снег';
      case 75:
        return 'Сильный снег';
      case 77:
        return 'Снежная крупа';
      case 80:
      case 81:
      case 82:
        return 'Ливень';
      case 85:
      case 86:
        return 'Снегопад';
      case 95:
        return 'Гроза';
      case 96:
      case 99:
        return 'Гроза с градом';
      default:
        return 'Погода';
    }
  }

  /// WMO weather code → код иконки, совместимый с `_weatherIcon`
  /// (`01`, `02`, `04`, `09`, `10`, `11`, `13`, `50`).
  String _iconForCode(int code) {
    if (code == 0) return '01';
    if (code == 1 || code == 2) return '02';
    if (code == 3) return '04';
    if (code == 45 || code == 48) return '50';
    if (code >= 51 && code <= 57) return '09';
    if (code >= 61 && code <= 67) return '10';
    if (code >= 71 && code <= 77) return '13';
    if (code >= 80 && code <= 82) return '09';
    if (code >= 85 && code <= 86) return '13';
    if (code >= 95) return '11';
    return '03';
  }
}

/// Снимок погоды.
class WeatherSnapshot {
  const WeatherSnapshot({
    required this.fetchedAt,
    required this.currentTemp,
    required this.currentHumidity,
    required this.currentDescription,
    required this.currentIcon,
    required this.currentDt,
    required this.daily,
    this.apparentTemp,
    this.isDay = true,
    this.precipitation = 0.0,
    this.cloudCover = 0,
    this.pressure = 0.0,
    this.windSpeed = 0.0,
    this.windDirection = 0,
    this.uvIndex,
  });

  final DateTime fetchedAt;
  final double currentTemp;
  final int currentHumidity;
  final String currentDescription;
  final String currentIcon;
  final DateTime currentDt;
  final List<DailyForecast> daily;

  /// Ощущаемая температура.
  final double? apparentTemp;

  /// День/ночь по данным API.
  final bool isDay;

  /// Осадки за последний час, мм.
  final double precipitation;

  /// Облачность, %.
  final int cloudCover;

  /// Давление на уровне моря, гПа.
  final double pressure;

  /// Скорость ветра, м/с.
  final double windSpeed;

  /// Направление ветра, градусы (0–360).
  final int windDirection;

  /// UV-индекс, может отсутствовать.
  final double? uvIndex;

  /// Прогноз на завтра (если есть).
  DailyForecast? get tomorrow {
    final tomorrowDate = DateTime.now().add(const Duration(days: 1));
    final target = DateTime(
      tomorrowDate.year,
      tomorrowDate.month,
      tomorrowDate.day,
    );
    for (final d in daily) {
      if (d.date == target) return d;
    }
    return daily.length > 1 ? daily[1] : null;
  }

  /// Прогноз на сегодня (если есть).
  DailyForecast? get today {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day);
    for (final d in daily) {
      if (d.date == target) return d;
    }
    return daily.isNotEmpty ? daily.first : null;
  }
}

/// Прогноз на один день.
class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.precipitationProbability,
    this.precipitationSum = 0.0,
    this.weatherCode = 0,
    this.icon = '02',
    this.description = '',
    this.sunrise,
    this.sunset,
    this.uvIndexMax,
    this.windSpeedMax,
    this.windDirectionDominant,
  });

  final DateTime date;
  final double tempMin;
  final double tempMax;

  /// Вероятность осадков 0.0 – 1.0.
  final double precipitationProbability;

  /// Сумма осадков за день, мм.
  final double precipitationSum;

  /// WMO-код.
  final int weatherCode;

  /// Двузначный код иконки, совместимый с `_weatherIcon`.
  final String icon;

  /// Текстовое описание.
  final String description;

  final DateTime? sunrise;
  final DateTime? sunset;
  final double? uvIndexMax;
  final double? windSpeedMax;
  final int? windDirectionDominant;

  double get averageTemp => (tempMin + tempMax) / 2;
}
