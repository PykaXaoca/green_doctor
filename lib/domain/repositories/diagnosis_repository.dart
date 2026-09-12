import '../../core/database/database.dart';

abstract class DiagnosisRepository {
  Future<List<Diagnose>> getActive();
  Future<List<Diagnose>> getByPlant(int plantId);
  Future<Diagnose?> getById(int id);
  Future<int> create(DiagnosesCompanion diagnosis);
  Future<void> resolve(int id);
  Future<int> addStep(TreatmentStepsCompanion step);
  Future<List<TreatmentStep>> getSteps(int diagnosisId);
  Future<void> completeStep(int stepId);
}
