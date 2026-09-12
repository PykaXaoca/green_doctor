import '../../core/database/database.dart';
import '../../domain/repositories/weather_repository.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  WeatherRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<WeatherCacheData?> getFresh(double lat, double lon) =>
      _db.weatherDao.getFresh(lat, lon);

  @override
  Future<int> cache(WeatherCacheCompanion data) =>
      _db.weatherDao.insertCache(data);

  @override
  Future<void> clearExpired() => _db.weatherDao.clearExpired();
}
