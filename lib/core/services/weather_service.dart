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
          'current': 'temperature_2m,relative_humidity_2m,weather_code',
          'daily':
              'temperature_2m_max,temperature_2m_min,'
              'precipitation_probability_max',
          'timezone': 'auto',
          'forecast_days': 5,
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

      final currentTemp = (current['temperature_2m'] as num).toDouble();
      final currentHumidity =
          (current['relative_humidity_2m'] as num?)?.toInt() ?? 0;
      final weatherCode = (current['weather_code'] as num?)?.toInt() ?? 0;
      final currentTimeStr = current['time'] as String?;
      final currentDt = currentTimeStr != null
          ? DateTime.tryParse(currentTimeStr) ?? DateTime.now()
          : DateTime.now();

      final daily = map['daily'] as Map<String, dynamic>?;
      final dailyForecasts = <DailyForecast>[];
      if (daily != null) {
        final times = (daily['time'] as List).cast<String>();
        final maxes = (daily['temperature_2m_max'] as List).cast<num>();
        final mins = (daily['temperature_2m_min'] as List).cast<num>();
        final pops = daily['precipitation_probability_max'] is List
            ? (daily['precipitation_probability_max'] as List)
            : const [];

        for (var i = 0; i < times.length; i++) {
          final date = DateTime.tryParse(times[i]);
          if (date == null) continue;
          final popValue = i < pops.length && pops[i] != null
              ? (pops[i] as num).toDouble() / 100.0
              : 0.0;
          dailyForecasts.add(
            DailyForecast(
              date: DateTime(date.year, date.month, date.day),
              tempMin: mins[i].toDouble(),
              tempMax: maxes[i].toDouble(),
              precipitationProbability: popValue.clamp(0.0, 1.0),
            ),
          );
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
      );
    } catch (_) {
      return null;
    }
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

  /// WMO weather code → код иконки, совместимый с тем, что уже
  /// использует `WeatherHeader._weatherIcon` (`01`, `02`, `04`, `09`,
  /// `10`, `11`, `13`, `50`).
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
  });

  final DateTime fetchedAt;
  final double currentTemp;
  final int currentHumidity;
  final String currentDescription;
  final String currentIcon;
  final DateTime currentDt;
  final List<DailyForecast> daily;

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
  });

  final DateTime date;
  final double tempMin;
  final double tempMax;

  /// Вероятность осадков 0.0 – 1.0.
  final double precipitationProbability;

  double get averageTemp => (tempMin + tempMax) / 2;
}
