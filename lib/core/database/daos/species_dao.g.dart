// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'species_dao.dart';

// ignore_for_file: type=lint
mixin _$SpeciesDaoMixin on DatabaseAccessor<AppDatabase> {
  $PlantSpeciesTable get plantSpecies => attachedDatabase.plantSpecies;
  SpeciesDaoManager get managers => SpeciesDaoManager(this);
}

class SpeciesDaoManager {
  final _$SpeciesDaoMixin _db;
  SpeciesDaoManager(this._db);
  $$PlantSpeciesTableTableManager get plantSpecies =>
      $$PlantSpeciesTableTableManager(_db.attachedDatabase, _db.plantSpecies);
}
