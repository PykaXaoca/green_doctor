import '../../core/database/database.dart';
import '../../domain/models/treatment_step_with_diagnosis.dart';
import '../../domain/repositories/diagnosis_repository.dart';

class DiagnosisRepositoryImpl implements DiagnosisRepository {
  DiagnosisRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<Diagnose>> getActive() => _db.diagnosisDao.getActive();

  @override
  Future<List<Diagnose>> getActiveByPlant(int plantId) =>
      _db.diagnosisDao.getActiveByPlant(plantId);

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
  Future<void> reactivate(int diagnosisId) =>
      _db.diagnosisDao.reactivate(diagnosisId);

  @override
  Future<void> deleteDiagnosis(int diagnosisId) async {
    await _db.transaction(() async {
      await _db.diagnosisDao.deleteStepsForDiagnosis(diagnosisId);
      await _db.diagnosisDao.deleteDiagnosis(diagnosisId);
    });
  }

  @override
  Future<int> addStep(TreatmentStepsCompanion step) =>
      _db.diagnosisDao.insertStep(step);

  @override
  Future<List<TreatmentStep>> getSteps(int diagnosisId) =>
      _db.diagnosisDao.getSteps(diagnosisId);

  @override
  Future<TreatmentStep?> getCurrentStep(int diagnosisId) =>
      _db.diagnosisDao.getCurrentStep(diagnosisId);

  @override
  Future<List<TreatmentStep>> getStepsForDiagnoses(List<int> diagnosisIds) =>
      _db.diagnosisDao.getStepsForDiagnoses(diagnosisIds);

  @override
  Future<List<TreatmentStep>> getStepsInRange(DateTime from, DateTime to) =>
      _db.diagnosisDao.getStepsInRange(from, to);

  @override
  Future<List<TreatmentStepWithDiagnosis>> getStepsWithDiagnosisInRange(
    DateTime from,
    DateTime to,
  ) => _db.diagnosisDao.getStepsWithDiagnosisInRange(from, to);

  @override
  Future<void> completeStep(int stepId) =>
      _db.diagnosisDao.completeStep(stepId);

  @override
  Future<void> uncompleteStep(int stepId) =>
      _db.diagnosisDao.uncompleteStep(stepId);
}
