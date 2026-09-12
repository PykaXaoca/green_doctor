import '../../core/database/database.dart';
import '../../domain/repositories/diagnosis_repository.dart';

class DiagnosisRepositoryImpl implements DiagnosisRepository {
  DiagnosisRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<Diagnose>> getActive() => _db.diagnosisDao.getActive();

  @override
  Future<List<Diagnose>> getByPlant(int plantId) =>
      _db.diagnosisDao.getByPlant(plantId);

  @override
  Future<Diagnose?> getById(int id) => _db.diagnosisDao.getById(id);

  @override
  Future<int> create(DiagnosesCompanion diagnosis) =>
      _db.diagnosisDao.insertDiagnosis(diagnosis);

  @override
  Future<void> resolve(int id) => _db.diagnosisDao.resolve(id);

  @override
  Future<int> addStep(TreatmentStepsCompanion step) =>
      _db.diagnosisDao.insertStep(step);

  @override
  Future<List<TreatmentStep>> getSteps(int diagnosisId) =>
      _db.diagnosisDao.getSteps(diagnosisId);

  @override
  Future<void> completeStep(int stepId) =>
      _db.diagnosisDao.completeStep(stepId);
}
