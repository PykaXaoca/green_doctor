// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_dao.dart';

// ignore_for_file: type=lint
mixin _$WeatherDaoMixin on DatabaseAccessor<AppDatabase> {
  $WeatherCacheTable get weatherCache => attachedDatabase.weatherCache;
  WeatherDaoManager get managers => WeatherDaoManager(this);
}

class WeatherDaoManager {
  final _$WeatherDaoMixin _db;
  WeatherDaoManager(this._db);
  $$WeatherCacheTableTableManager get weatherCache =>
      $$WeatherCacheTableTableManager(_db.attachedDatabase, _db.weatherCache);
}
