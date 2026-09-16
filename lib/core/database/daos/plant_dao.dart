import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';

part 'plant_dao.g.dart';

@DriftAccessor(tables: [Plants])
class PlantDao extends DatabaseAccessor<AppDatabase> with _$PlantDaoMixin {
  PlantDao(super.db);

  Future<List<Plant>> getByUser(int userId) => (select(
    plants,
  )..where((t) => t.userId.equals(userId) & t.isArchived.equals(false))).get();

  /// Архивные растения пользователя — для раздела «В архиве».
  Future<List<Plant>> getArchivedByUser(int userId) =>
      (select(plants)
            ..where((t) => t.userId.equals(userId) & t.isArchived.equals(true))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Future<List<Plant>> getAllActive() =>
      (select(plants)..where((t) => t.isArchived.equals(false))).get();

  Future<Plant?> getById(int id) =>
      (select(plants)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertPlant(PlantsCompanion plant) => into(plants).insert(plant);

  Future<int> updatePlant(int id, PlantsCompanion plant) =>
      (update(plants)..where((t) => t.id.equals(id))).write(plant);

  Future<int> archivePlant(int id) =>
      (update(plants)..where((t) => t.id.equals(id))).write(
        const PlantsCompanion(isArchived: Value(true)),
      );

  /// Вернуть растение из архива.
  Future<int> unarchivePlant(int id) =>
      (update(plants)..where((t) => t.id.equals(id))).write(
        const PlantsCompanion(isArchived: Value(false)),
      );

  Future<int> deletePlant(int id) =>
      (delete(plants)..where((t) => t.id.equals(id))).go();

  Future<List<Plant>> getPlantsDueForWatering(DateTime until) =>
      (select(plants)..where(
            (t) =>
                t.isArchived.equals(false) &
                t.nextWaterDue.isSmallerOrEqualValue(until),
          ))
          .get();
}
