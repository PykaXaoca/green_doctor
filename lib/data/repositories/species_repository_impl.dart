import '../../core/database/database.dart';
import '../../domain/repositories/species_repository.dart';

class SpeciesRepositoryImpl implements SpeciesRepository {
  SpeciesRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<PlantSpecy>> getAll() => _db.speciesDao.getAll();

  @override
  Future<List<PlantSpecy>> getNonPremium() => _db.speciesDao.getNonPremium();

  @override
  Future<PlantSpecy?> getById(String id) => _db.speciesDao.getById(id);

  @override
  Future<List<PlantSpecy>> searchByName(String query) =>
      _db.speciesDao.searchByName(query);

  @override
  Future<void> insertAll(List<PlantSpeciesCompanion> items) =>
      _db.speciesDao.insertAll(items);
}
