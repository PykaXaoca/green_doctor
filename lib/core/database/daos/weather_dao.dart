import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';

part 'weather_dao.g.dart';

@DriftAccessor(tables: [WeatherCache])
class WeatherDao extends DatabaseAccessor<AppDatabase> with _$WeatherDaoMixin {
  WeatherDao(super.db);

  Future<WeatherCacheData?> getFresh(double lat, double lon) =>
      (select(weatherCache)
            ..where(
              (t) =>
                  t.latitude.equals(lat) &
                  t.longitude.equals(lon) &
                  t.expiresAt.isBiggerThanValue(DateTime.now()),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.fetchedAt)])
            ..limit(1))
          .getSingleOrNull();

  Future<List<WeatherCacheData>> getAll() => (select(
    weatherCache,
  )..orderBy([(t) => OrderingTerm.desc(t.fetchedAt)])).get();

  Future<int> insertCache(WeatherCacheCompanion c) =>
      into(weatherCache).insert(c);

  Future<int> clearExpired() => (delete(
    weatherCache,
  )..where((t) => t.expiresAt.isSmallerThanValue(DateTime.now()))).go();
}
