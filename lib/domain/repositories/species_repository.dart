import '../../core/database/database.dart';

abstract class SpeciesRepository {
  Future<List<PlantSpecy>> getAll();
  Future<List<PlantSpecy>> getNonPremium();
  Future<PlantSpecy?> getById(String id);
  Future<List<PlantSpecy>> searchByName(String query);
  Future<void> insertAll(List<PlantSpeciesCompanion> items);
}
