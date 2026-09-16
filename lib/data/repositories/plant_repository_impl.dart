import '../../core/database/database.dart';
import '../../domain/repositories/plant_repository.dart';

class PlantRepositoryImpl implements PlantRepository {
  PlantRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<Plant>> getByUser(int userId) => _db.plantDao.getByUser(userId);

  @override
  Future<List<Plant>> getArchivedByUser(int userId) =>
      _db.plantDao.getArchivedByUser(userId);

  @override
  Future<List<Plant>> getAllActive() => _db.plantDao.getAllActive();

  @override
  Future<Plant?> getById(int id) => _db.plantDao.getById(id);

  @override
  Future<int> create(PlantsCompanion plant) => _db.plantDao.insertPlant(plant);

  @override
  Future<void> update(int id, PlantsCompanion plant) =>
      _db.plantDao.updatePlant(id, plant);

  @override
  Future<void> archive(int id) => _db.plantDao.archivePlant(id);

  @override
  Future<void> unarchive(int id) => _db.plantDao.unarchivePlant(id);

  @override
  Future<void> delete(int id) => _db.plantDao.deletePlant(id);

  @override
  Future<List<Plant>> getDueForWatering(DateTime until) =>
      _db.plantDao.getPlantsDueForWatering(until);
}
