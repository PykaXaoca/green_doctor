import '../../core/database/database.dart';

abstract class CareEventRepository {
  Future<List<CareEvent>> getByPlant(int plantId);
  Future<List<CareEvent>> getByPlantInRange(
    int plantId,
    DateTime from,
    DateTime to,
  );
  Future<List<CareEvent>> getRecent(int limit);
  Future<List<CareEvent>> getInRange(DateTime from, DateTime to);
  Future<int> add(CareEventsCompanion event);
  Future<void> delete(int id);
  Future<int> countByType(String type);
}
