import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';

part 'species_dao.g.dart';

@DriftAccessor(tables: [PlantSpecies])
class SpeciesDao extends DatabaseAccessor<AppDatabase> with _$SpeciesDaoMixin {
  SpeciesDao(super.db);

  Future<List<PlantSpecy>> getAll() => select(plantSpecies).get();

  Future<List<PlantSpecy>> getNonPremium() =>
      (select(plantSpecies)..where((t) => t.isPremium.equals(false))).get();

  Future<PlantSpecy?> getById(String id) =>
      (select(plantSpecies)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<PlantSpecy>> searchByName(String query) =>
      (select(plantSpecies)..where((t) => t.commonName.like('%$query%'))).get();

  Future<void> insertAll(List<PlantSpeciesCompanion> items) async {
    await batch((b) => b.insertAllOnConflictUpdate(plantSpecies, items));
  }
}
