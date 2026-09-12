import '../../core/database/database.dart';

abstract class WeatherRepository {
  Future<WeatherCacheData?> getFresh(double lat, double lon);
  Future<int> cache(WeatherCacheCompanion data);
  Future<void> clearExpired();
}
