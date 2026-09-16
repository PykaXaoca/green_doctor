import '../../core/database/database.dart';

abstract class PlantRepository {
  Future<List<Plant>> getByUser(int userId);
  Future<List<Plant>> getArchivedByUser(int userId);
  Future<List<Plant>> getAllActive();
  Future<Plant?> getById(int id);
  Future<int> create(PlantsCompanion plant);
  Future<void> update(int id, PlantsCompanion plant);
  Future<void> archive(int id);
  Future<void> unarchive(int id);
  Future<void> delete(int id);
  Future<List<Plant>> getDueForWatering(DateTime until);
}
