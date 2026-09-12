// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnosis_dao.dart';

// ignore_for_file: type=lint
mixin _$DiagnosisDaoMixin on DatabaseAccessor<AppDatabase> {
  $AppUsersTable get appUsers => attachedDatabase.appUsers;
  $PlantSpeciesTable get plantSpecies => attachedDatabase.plantSpecies;
  $PlantsTable get plants => attachedDatabase.plants;
  $PlantDiseasesTable get plantDiseases => attachedDatabase.plantDiseases;
  $DiagnosesTable get diagnoses => attachedDatabase.diagnoses;
  $TreatmentStepsTable get treatmentSteps => attachedDatabase.treatmentSteps;
  DiagnosisDaoManager get managers => DiagnosisDaoManager(this);
}

class DiagnosisDaoManager {
  final _$DiagnosisDaoMixin _db;
  DiagnosisDaoManager(this._db);
  $$AppUsersTableTableManager get appUsers =>
      $$AppUsersTableTableManager(_db.attachedDatabase, _db.appUsers);
  $$PlantSpeciesTableTableManager get plantSpecies =>
      $$PlantSpeciesTableTableManager(_db.attachedDatabase, _db.plantSpecies);
  $$PlantsTableTableManager get plants =>
      $$PlantsTableTableManager(_db.attachedDatabase, _db.plants);
  $$PlantDiseasesTableTableManager get plantDiseases =>
      $$PlantDiseasesTableTableManager(_db.attachedDatabase, _db.plantDiseases);
  $$DiagnosesTableTableManager get diagnoses =>
      $$DiagnosesTableTableManager(_db.attachedDatabase, _db.diagnoses);
  $$TreatmentStepsTableTableManager get treatmentSteps =>
      $$TreatmentStepsTableTableManager(
        _db.attachedDatabase,
        _db.treatmentSteps,
      );
}
