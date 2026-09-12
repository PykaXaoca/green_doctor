// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'care_event_dao.dart';

// ignore_for_file: type=lint
mixin _$CareEventDaoMixin on DatabaseAccessor<AppDatabase> {
  $AppUsersTable get appUsers => attachedDatabase.appUsers;
  $PlantSpeciesTable get plantSpecies => attachedDatabase.plantSpecies;
  $PlantsTable get plants => attachedDatabase.plants;
  $CareEventsTable get careEvents => attachedDatabase.careEvents;
  CareEventDaoManager get managers => CareEventDaoManager(this);
}

class CareEventDaoManager {
  final _$CareEventDaoMixin _db;
  CareEventDaoManager(this._db);
  $$AppUsersTableTableManager get appUsers =>
      $$AppUsersTableTableManager(_db.attachedDatabase, _db.appUsers);
  $$PlantSpeciesTableTableManager get plantSpecies =>
      $$PlantSpeciesTableTableManager(_db.attachedDatabase, _db.plantSpecies);
  $$PlantsTableTableManager get plants =>
      $$PlantsTableTableManager(_db.attachedDatabase, _db.plants);
  $$CareEventsTableTableManager get careEvents =>
      $$CareEventsTableTableManager(_db.attachedDatabase, _db.careEvents);
}
