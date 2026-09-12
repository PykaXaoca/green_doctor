import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

import '../config/app_config.dart';
import '../database/database.dart';

/// Сервис получения погоды через OpenWeatherMap с кешированием.
class WeatherService {
  WeatherService(this._db, {Dio? dio}) : _dio = dio ?? Dio() {
    // Ключ OpenWeatherMap передаётся в query-параметрах. Чтобы он случайно
    // не попал в логи или в Sentry, отключаем логирование тела/URL.
    _dio.options
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(seconds: 10)
      ..sendTimeout = const Duration(seconds: 10);
  }

  final AppDatabase _db;
  final Dio _dio;

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
  /// Если кеша нет — загружает через сеть.
  ///
  /// Если API-ключ не задан при сборке (--dart-define=OPENWEATHER_API_KEY),
  /// сервис работает в offline-режиме: отдаёт самый свежий кеш или null.
  Future<WeatherSnapshot?> getWeather({
    required double lat,
    required double lon,
    bool forceRefresh = false,
  }) async {
    // Без ключа сеть не трогаем — отдаём кеш.
    if (!AppConfig.hasWeatherKey) {
      return await _getLatestCached();
    }

    if (!forceRefresh) {
      final cached = await _db.weatherDao.getFresh(lat, lon);
      if (cached != null) {
        return _parseSnapshot(cached.payloadJson);
      }
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '${AppConfig.openWeatherBaseUrl}/forecast',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': AppConfig.openWeatherApiKey,
          'units': 'metric',
          'lang': 'ru',
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

      return _parseSnapshot(jsonEncode(data));
    } catch (_) {
      // Сеть упала или ключ невалиден — отдаём кеш.
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
    return _parseSnapshot(latest.payloadJson);
  }

  WeatherSnapshot? _parseSnapshot(String json) {
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      final list = (map['list'] as List).cast<Map<String, dynamic>>();
      if (list.isEmpty) return null;

      final current = list.first;
      final currentMain = current['main'] as Map<String, dynamic>;
      final currentWeather =
          (current['weather'] as List).first as Map<String, dynamic>;
      final currentDt = DateTime.fromMillisecondsSinceEpoch(
        (current['dt'] as int) * 1000,
      );

      final byDay = <DateTime, List<Map<String, dynamic>>>{};
      for (final item in list) {
        final dt = DateTime.fromMillisecondsSinceEpoch(
          (item['dt'] as int) * 1000,
        );
        final day = DateTime(dt.year, dt.month, dt.day);
        byDay.putIfAbsent(day, () => []).add(item);
      }

      final daily = byDay.entries.map((e) {
        final temps = e.value
            .map((i) => (i['main'] as Map)['temp'] as num)
            .toList();
        final pops = e.value
            .map((i) => ((i['pop'] as num?) ?? 0).toDouble())
            .toList();
        return DailyForecast(
          date: e.key,
          tempMin: temps.reduce((a, b) => a < b ? a : b).toDouble(),
          tempMax: temps.reduce((a, b) => a > b ? a : b).toDouble(),
          precipitationProbability: pops
              .reduce((a, b) => a > b ? a : b)
              .clamp(0.0, 1.0),
        );
      }).toList()..sort((a, b) => a.date.compareTo(b.date));

      return WeatherSnapshot(
        fetchedAt: DateTime.now(),
        currentTemp: (currentMain['temp'] as num).toDouble(),
        currentHumidity: (currentMain['humidity'] as num).toInt(),
        currentDescription: (currentWeather['description'] as String?) ?? '',
        currentIcon: (currentWeather['icon'] as String?) ?? '',
        currentDt: currentDt,
        daily: daily,
      );
    } catch (_) {
      return null;
    }
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
