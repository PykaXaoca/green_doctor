// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant_dao.dart';

// ignore_for_file: type=lint
mixin _$PlantDaoMixin on DatabaseAccessor<AppDatabase> {
  $AppUsersTable get appUsers => attachedDatabase.appUsers;
  $PlantSpeciesTable get plantSpecies => attachedDatabase.plantSpecies;
  $PlantsTable get plants => attachedDatabase.plants;
  PlantDaoManager get managers => PlantDaoManager(this);
}

class PlantDaoManager {
  final _$PlantDaoMixin _db;
  PlantDaoManager(this._db);
  $$AppUsersTableTableManager get appUsers =>
      $$AppUsersTableTableManager(_db.attachedDatabase, _db.appUsers);
  $$PlantSpeciesTableTableManager get plantSpecies =>
      $$PlantSpeciesTableTableManager(_db.attachedDatabase, _db.plantSpecies);
  $$PlantsTableTableManager get plants =>
      $$PlantsTableTableManager(_db.attachedDatabase, _db.plants);
}
