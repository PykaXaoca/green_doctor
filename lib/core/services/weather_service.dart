import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../config/app_config.dart';
import '../database/database.dart';

/// Тип ошибки геолокации — используется UI, чтобы показать
/// пользователю правильное сообщение и кнопку действия.
enum LocationError {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeout,
  unknown,
}

/// Результат попытки получить текущую позицию.
class LocationResult {
  const LocationResult._({this.position, this.error, this.fromCache = false});

  final Position? position;
  final LocationError? error;
  final bool fromCache;

  bool get isSuccess => position != null;

  factory LocationResult.success(Position position, {bool fromCache = false}) =>
      LocationResult._(position: position, fromCache: fromCache);

  factory LocationResult.failure(LocationError error) =>
      LocationResult._(error: error);
}

/// Сервис получения погоды через Meteosource с кешированием.
///
/// Meteosource — погодный API, работающий в РФ без VPN.
/// Документация: https://www.meteosource.com/api/v1/free/point
///
/// **Free-план** отдаёт: температуру, ветер, осадки, облачность,
/// прогноз на 7 дней. **Не отдаёт**: влажность, давление, UV,
/// ощущаемую температуру, sunrise/sunset. Соответствующие поля
/// в [WeatherSnapshot] и [DailyForecast] — nullable.
class WeatherService {
  WeatherService(this._db, {Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options
      ..connectTimeout = const Duration(seconds: 30)
      ..receiveTimeout = const Duration(seconds: 30)
      ..sendTimeout = const Duration(seconds: 30)
      ..validateStatus = (status) => status != null && status < 500;

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: false,
          requestBody: false,
          responseHeader: false,
          responseBody: false,
          error: true,
          logPrint: (o) => debugPrint('[Dio] $o'),
        ),
      );
    }
  }

  final AppDatabase _db;
  final Dio _dio;

  static const String _baseUrl = '${AppConfig.meteosourceBaseUrl}/point';

  static const Duration _locationTimeout = Duration(seconds: 30);
  static const Duration _cacheFreshness = Duration(minutes: 10);

  // ===========================================================================
  //  Геолокация
  // ===========================================================================

  Future<LocationResult> getCurrentPositionDetailed({
    bool requestIfDenied = false,
  }) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      log('isLocationServiceEnabled: $serviceEnabled');
      if (!serviceEnabled) {
        return LocationResult.failure(LocationError.serviceDisabled);
      }

      var permission = await Geolocator.checkPermission();
      log('checkPermission (до запроса): $permission');

      if (permission == LocationPermission.denied && requestIfDenied) {
        log('requestPermission...');
        permission = await Geolocator.requestPermission();
        log('requestPermission (результат): $permission');
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult.failure(LocationError.permissionDeniedForever);
      }
      if (permission == LocationPermission.denied) {
        return LocationResult.failure(LocationError.permissionDenied);
      }

      Position? lastKnown;
      try {
        lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          final age = DateTime.now().difference(lastKnown.timestamp);
          log(
            'getLastKnownPosition: lat=${lastKnown.latitude}, '
            'lon=${lastKnown.longitude}, accuracy=${lastKnown.accuracy}, '
            'age=${age.inSeconds} с',
          );
          if (age <= _cacheFreshness) {
            log('  → используем кеш (свежий)');
            return LocationResult.success(lastKnown, fromCache: true);
          }
          log('  → кеш устарел, нужен свежий запрос');
        } else {
          log('getLastKnownPosition: null');
        }
      } catch (e) {
        log('getLastKnownPosition упал: $e');
      }

      log('getCurrentPosition (таймаут ${_locationTimeout.inSeconds} с)...');
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: _locationTimeout,
          ),
        );
        log(
          'position (свежая): lat=${position.latitude}, '
          'lon=${position.longitude}, accuracy=${position.accuracy}',
        );
        return LocationResult.success(position);
      } on TimeoutException {
        log('TimeoutException свежего запроса');
        if (lastKnown != null) {
          log('  → фолбэк на last known');
          return LocationResult.success(lastKnown, fromCache: true);
        }
        return LocationResult.failure(LocationError.timeout);
      }
    } on LocationServiceDisabledException catch (e) {
      log('LocationServiceDisabledException: $e');
      return LocationResult.failure(LocationError.serviceDisabled);
    } on PermissionDeniedException catch (e) {
      log('PermissionDeniedException: $e');
      return LocationResult.failure(LocationError.permissionDenied);
    } catch (e, st) {
      log('Неизвестная ошибка геолокации: $e\n$st');
      return LocationResult.failure(LocationError.unknown);
    }
  }

  Future<Position?> getCurrentPosition({bool requestIfDenied = false}) async {
    final result = await getCurrentPositionDetailed(
      requestIfDenied: requestIfDenied,
    );
    return result.position;
  }

  // ===========================================================================
  //  Погода
  // ===========================================================================

  Future<WeatherSnapshot?> getWeather({
    required double lat,
    required double lon,
    bool forceRefresh = false,
  }) async {
    log('getWeather: lat=$lat, lon=$lon, forceRefresh=$forceRefresh');

    if (!forceRefresh) {
      try {
        final cached = await _db.weatherDao.getFresh(lat, lon);
        log('getFresh: ${cached == null ? "null" : "есть запись"}');
        if (cached != null) {
          final parsed = _parseMeteosource(cached.payloadJson);
          log('парсинг из кеша: ${parsed == null ? "null" : "OK"}');
          if (parsed != null) return parsed;
        }
      } catch (e, st) {
        log('getFresh упал: $e\n$st');
      }
    }

    if (!AppConfig.hasWeatherKey) {
      log('METEOSOURCE_API_KEY не задан — работаем только на кеше');
      return await _getLatestCached();
    }

    try {
      log('HTTP GET $_baseUrl');
      final sw = Stopwatch()..start();
      final response = await _dio.get<Map<String, dynamic>>(
        _baseUrl,
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'sections': 'current,daily',
          'timezone': 'auto',
          'language': 'en',
          'units': 'metric',
        },
        options: Options(headers: {'X-API-Key': AppConfig.meteosourceApiKey}),
      );
      sw.stop();
      log(
        'HTTP статус: ${response.statusCode} за ${sw.elapsedMilliseconds} мс',
      );

      final data = response.data;
      if (data == null) {
        log('response.data == null, пробую кеш');
        return await _getLatestCached();
      }

      log('response.data keys: ${data.keys.toList()}');

      try {
        final now = DateTime.now();
        await _db.weatherDao.insertCache(
          WeatherCacheCompanion.insert(
            latitude: lat,
            longitude: lon,
            payloadJson: jsonEncode(data),
            expiresAt: now.add(AppConfig.weatherCacheTtl),
          ),
        );
        log('insertCache: OK');
      } catch (e, st) {
        log('insertCache упал: $e\n$st');
      }

      final parsed = _parseMeteosource(jsonEncode(data));
      log('парсинг ответа: ${parsed == null ? "null" : "OK"}');
      return parsed;
    } on DioException catch (e) {
      log('DioException: type=${e.type}');
      log('  message=${e.message}');
      log('  uri=${e.requestOptions.uri}');
      log('  statusCode=${e.response?.statusCode}');
      if (e.response?.data != null) {
        log('  response.data=${e.response!.data}');
      }
      return await _getLatestCached();
    } catch (e, st) {
      log('HTTP-запрос упал (не DioException): $e\n$st');
      return await _getLatestCached();
    }
  }

  Future<void> clearExpired() => _db.weatherDao.clearExpired();

  Future<WeatherSnapshot?> _getLatestCached() async {
    try {
      final all = await _db.weatherDao.getAll();
      log('_getLatestCached: записей в БД ${all.length}');
      if (all.isEmpty) return null;
      final latest = all.reduce(
        (a, b) => a.fetchedAt.isAfter(b.fetchedAt) ? a : b,
      );
      final parsed = _parseMeteosource(latest.payloadJson);
      log('_getLatestCached: парсинг ${parsed == null ? "null" : "OK"}');
      return parsed;
    } catch (e, st) {
      log('_getLatestCached упал: $e\n$st');
      return null;
    }
  }

  // ===========================================================================
  //  Парсинг Meteosource
  // ===========================================================================

  WeatherSnapshot? _parseMeteosource(String json) {
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;

      // --- current ---
      final current = map['current'] as Map<String, dynamic>?;
      if (current == null) {
        log('_parseMeteosource: current == null');
        return null;
      }

      final currentTemp = _toDouble(current['temperature']) ?? 0.0;
      final iconNum = _toInt(current['icon_num']);
      final summary = current['summary'] as String? ?? '';

      final windMap = current['wind'] as Map<String, dynamic>?;
      final windSpeed = _toDouble(windMap?['speed']) ?? 0.0;
      final windAngle = _toInt(windMap?['angle']) ?? 0;

      final precipMap = current['precipitation'] as Map<String, dynamic>?;
      final precipitation = _toDouble(precipMap?['total']) ?? 0.0;

      final cloudCover = _toInt(current['cloud_cover']) ?? 0;

      // --- daily ---
      final dailyRoot = map['daily'] as Map<String, dynamic>?;
      final dailyData = dailyRoot?['data'] as List?;
      final dailyForecasts = <DailyForecast>[];
      if (dailyData != null) {
        for (final item in dailyData) {
          if (item is! Map<String, dynamic>) continue;
          final dateStr = item['day'] as String?;
          final date = dateStr != null ? DateTime.tryParse(dateStr) : null;
          if (date == null) continue;

          final allDay = item['all_day'] as Map<String, dynamic>?;
          final temp = _toDouble(allDay?['temperature']) ?? 0.0;
          final tempMin = _toDouble(allDay?['temperature_min']) ?? temp;
          final tempMax = _toDouble(allDay?['temperature_max']) ?? temp;
          final dayIconNum = _toInt(item['icon']) ?? 0;
          final daySummary = item['summary'] as String? ?? '';

          final dayPrecipMap =
              allDay?['precipitation'] as Map<String, dynamic>?;
          final dayPrecip = _toDouble(dayPrecipMap?['total']) ?? 0.0;

          final dayWindMap = allDay?['wind'] as Map<String, dynamic>?;
          final dayWindSpeed = _toDouble(dayWindMap?['speed']);
          final dayWindAngle = _toInt(dayWindMap?['angle']);

          dailyForecasts.add(
            DailyForecast(
              date: DateTime(date.year, date.month, date.day),
              tempMin: tempMin,
              tempMax: tempMax,
              // Meteosource Free не отдаёт вероятность осадков —
              // используем оценку: если осадки > 0.5 мм, считаем высокой.
              precipitationProbability: dayPrecip > 0.5 ? 0.8 : 0.1,
              precipitationSum: dayPrecip,
              weatherCode: dayIconNum,
              icon: _iconFromMeteosourceCode(dayIconNum),
              description: daySummary.isNotEmpty
                  ? daySummary
                  : _descriptionFromMeteosourceCode(dayIconNum),
              windSpeedMax: dayWindSpeed,
              windDirectionDominant: dayWindAngle,
            ),
          );
        }
      }

      return WeatherSnapshot(
        fetchedAt: DateTime.now(),
        currentTemp: currentTemp,
        // Free-план Meteosource не отдаёт влажность.
        currentHumidity: null,
        currentDescription: summary.isNotEmpty
            ? summary
            : _descriptionFromMeteosourceCode(iconNum ?? 0),
        currentIcon: _iconFromMeteosourceCode(iconNum ?? 0),
        currentDt: DateTime.now(),
        daily: dailyForecasts,
        // Free-план не отдаёт ощущаемую температуру.
        apparentTemp: null,
        // is_day в ответе есть не всегда.
        isDay: true,
        precipitation: precipitation,
        cloudCover: cloudCover,
        // Free-план не отдаёт давление и UV.
        pressure: null,
        windSpeed: windSpeed,
        windDirection: windAngle,
        uvIndex: null,
      );
    } catch (e, st) {
      log('_parseMeteosource упал: $e\n$st');
      return null;
    }
  }

  /// Числовой код иконки Meteosource → строка вида `01`, `02`, ..., `50`.
  ///
  /// Мы используем ту же двухзначную схему, что была у Open-Meteo,
  /// чтобы не менять `_weatherIcon()` в UI.
  String _iconFromMeteosourceCode(int code) {
    switch (code) {
      // Ясно / малооблачно / переменная облачность / облачно
      case 2:
        return '01'; // sunny
      case 3:
        return '02'; // mostly_sunny
      case 4:
        return '02'; // partly_sunny
      case 5:
        return '03'; // mostly_cloudy
      case 6:
        return '04'; // cloudy
      case 7:
      case 8:
        return '04'; // overcast
      case 9:
        return '50'; // fog
      // Дождь
      case 10:
      case 11:
      case 12:
        return '10'; // light_rain / rain / psbl_rain
      case 13:
        return '09'; // rain_shower
      // Гроза
      case 14:
      case 15:
        return '11';
      // Снег
      case 16:
      case 17:
      case 18:
        return '13';
      case 19:
        return '13'; // snow_shower
      // Дождь со снегом
      case 20:
      case 21:
      case 22:
        return '13';
      case 23:
      case 24:
        return '10'; // freezing rain
      case 25:
        return '13'; // hail
      // Ночные варианты — те же иконки
      case 26:
        return '01'; // clear (night)
      case 27:
        return '02';
      case 28:
        return '02';
      case 29:
        return '03';
      case 30:
        return '04';
      case 31:
        return '04';
      case 32:
        return '09';
      case 33:
        return '11';
      case 34:
        return '13';
      case 35:
        return '13';
      case 36:
        return '10';
      default:
        return '03';
    }
  }

  /// Числовой код иконки Meteosource → текстовое описание на русском.
  String _descriptionFromMeteosourceCode(int code) {
    switch (code) {
      case 1:
        return 'Нет данных';
      case 2:
        return 'Ясно';
      case 3:
        return 'Преимущественно ясно';
      case 4:
        return 'Переменная облачность';
      case 5:
        return 'Преимущественно облачно';
      case 6:
        return 'Облачно';
      case 7:
      case 8:
        return 'Пасмурно';
      case 9:
        return 'Туман';
      case 10:
        return 'Небольшой дождь';
      case 11:
        return 'Дождь';
      case 12:
        return 'Возможен дождь';
      case 13:
        return 'Ливень';
      case 14:
      case 15:
        return 'Гроза';
      case 16:
        return 'Небольшой снег';
      case 17:
        return 'Снег';
      case 18:
        return 'Возможен снег';
      case 19:
        return 'Снегопад';
      case 20:
      case 21:
      case 22:
        return 'Дождь со снегом';
      case 23:
      case 24:
        return 'Ледяной дождь';
      case 25:
        return 'Град';
      case 26:
        return 'Ясно';
      case 27:
        return 'Преимущественно ясно';
      case 28:
        return 'Переменная облачность';
      case 29:
        return 'Преимущественно облачно';
      case 30:
        return 'Облачно';
      case 31:
        return 'Пасмурно';
      case 32:
        return 'Ливень';
      case 33:
        return 'Гроза';
      case 34:
        return 'Снегопад';
      case 35:
        return 'Дождь со снегом';
      case 36:
        return 'Ледяной дождь';
      default:
        return 'Погода';
    }
  }

  // ===========================================================================
  //  Вспомогательные парсеры
  // ===========================================================================

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

  void log(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[WeatherService] $message');
    }
  }
}

// ===========================================================================
//  Модели
// ===========================================================================

/// Снимок погоды.
///
/// Поля, которых нет в Meteosource Free (влажность, давление, UV,
/// ощущаемая температура), сделаны nullable.
class WeatherSnapshot {
  const WeatherSnapshot({
    required this.fetchedAt,
    required this.currentTemp,
    required this.currentDescription,
    required this.currentIcon,
    required this.currentDt,
    required this.daily,
    this.currentHumidity,
    this.apparentTemp,
    this.isDay = true,
    this.precipitation = 0.0,
    this.cloudCover = 0,
    this.pressure,
    this.windSpeed = 0.0,
    this.windDirection = 0,
    this.uvIndex,
  });

  final DateTime fetchedAt;
  final double currentTemp;

  /// Влажность, %. Meteosource Free не отдаёт → null.
  final int? currentHumidity;

  final String currentDescription;
  final String currentIcon;
  final DateTime currentDt;
  final List<DailyForecast> daily;

  /// Ощущаемая температура. Free не отдаёт → null.
  final double? apparentTemp;

  final bool isDay;
  final double precipitation;
  final int cloudCover;

  /// Давление, гПа. Free не отдаёт → null.
  final double? pressure;

  final double windSpeed;
  final int windDirection;

  /// UV-индекс. Free не отдаёт → null.
  final double? uvIndex;

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

  /// Оценка вероятности осадков 0.0 – 1.0.
  ///
  /// Meteosource Free не отдаёт это поле — оно рассчитывается
  /// из суммы осадков: > 0.5 мм → 0.8, иначе 0.1.
  final double precipitationProbability;

  final double precipitationSum;
  final int weatherCode;
  final String icon;
  final String description;

  /// Восход. Free не отдаёт → null.
  final DateTime? sunrise;

  /// Закат. Free не отдаёт → null.
  final DateTime? sunset;

  /// UV-индекс. Free не отдаёт → null.
  final double? uvIndexMax;

  final double? windSpeedMax;
  final int? windDirectionDominant;

  double get averageTemp => (tempMin + tempMax) / 2;
}
