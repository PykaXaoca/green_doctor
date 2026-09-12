import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';

part 'disease_dao.g.dart';

@DriftAccessor(tables: [PlantDiseases])
class DiseaseDao extends DatabaseAccessor<AppDatabase> with _$DiseaseDaoMixin {
  DiseaseDao(super.db);

  Future<List<PlantDisease>> getAll() => select(plantDiseases).get();

  Future<PlantDisease?> getById(String id) =>
      (select(plantDiseases)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> insertAll(List<PlantDiseasesCompanion> items) async {
    await batch((b) => b.insertAllOnConflictUpdate(plantDiseases, items));
  }
}
