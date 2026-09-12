// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'disease_dao.dart';

// ignore_for_file: type=lint
mixin _$DiseaseDaoMixin on DatabaseAccessor<AppDatabase> {
  $PlantDiseasesTable get plantDiseases => attachedDatabase.plantDiseases;
  DiseaseDaoManager get managers => DiseaseDaoManager(this);
}

class DiseaseDaoManager {
  final _$DiseaseDaoMixin _db;
  DiseaseDaoManager(this._db);
  $$PlantDiseasesTableTableManager get plantDiseases =>
      $$PlantDiseasesTableTableManager(_db.attachedDatabase, _db.plantDiseases);
}
