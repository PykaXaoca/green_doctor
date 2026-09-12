import '../../core/database/database.dart';
import '../../domain/repositories/care_event_repository.dart';

class CareEventRepositoryImpl implements CareEventRepository {
  CareEventRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<CareEvent>> getByPlant(int plantId) =>
      _db.careEventDao.getByPlant(plantId);

  @override
  Future<List<CareEvent>> getByPlantInRange(
    int plantId,
    DateTime from,
    DateTime to,
  ) => _db.careEventDao.getByPlantInRange(plantId, from, to);

  @override
  Future<List<CareEvent>> getRecent(int limit) =>
      _db.careEventDao.getRecent(limit);

  @override
  Future<List<CareEvent>> getInRange(DateTime from, DateTime to) =>
      _db.careEventDao.getInRange(from, to);

  @override
  Future<int> add(CareEventsCompanion event) =>
      _db.careEventDao.insertEvent(event);

  @override
  Future<void> delete(int id) => _db.careEventDao.deleteEvent(id);

  @override
  Future<int> countByType(String type) => _db.careEventDao.countByType(type);
}
