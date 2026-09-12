// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_dao.dart';

// ignore_for_file: type=lint
mixin _$ReminderDaoMixin on DatabaseAccessor<AppDatabase> {
  $AppUsersTable get appUsers => attachedDatabase.appUsers;
  $PlantSpeciesTable get plantSpecies => attachedDatabase.plantSpecies;
  $PlantsTable get plants => attachedDatabase.plants;
  $RemindersTable get reminders => attachedDatabase.reminders;
  ReminderDaoManager get managers => ReminderDaoManager(this);
}

class ReminderDaoManager {
  final _$ReminderDaoMixin _db;
  ReminderDaoManager(this._db);
  $$AppUsersTableTableManager get appUsers =>
      $$AppUsersTableTableManager(_db.attachedDatabase, _db.appUsers);
  $$PlantSpeciesTableTableManager get plantSpecies =>
      $$PlantSpeciesTableTableManager(_db.attachedDatabase, _db.plantSpecies);
  $$PlantsTableTableManager get plants =>
      $$PlantsTableTableManager(_db.attachedDatabase, _db.plants);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db.attachedDatabase, _db.reminders);
}
