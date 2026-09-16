import '../../core/database/database.dart';
import '../models/treatment_step_with_diagnosis.dart';

abstract class DiagnosisRepository {
  // ---- Diagnoses ----
  Future<List<Diagnose>> getActive();
  Future<List<Diagnose>> getActiveByPlant(int plantId);
  Future<List<Diagnose>> getByPlant(int plantId);
  Future<Diagnose?> getById(int id);
  Future<int> create(DiagnosesCompanion diagnosis);
  Future<void> resolve(int id);
  Future<void> reactivate(int diagnosisId);
  Future<void> deleteDiagnosis(int diagnosisId);

  // ---- TreatmentSteps ----
  Future<int> addStep(TreatmentStepsCompanion step);
  Future<List<TreatmentStep>> getSteps(int diagnosisId);
  Future<TreatmentStep?> getCurrentStep(int diagnosisId);
  Future<List<TreatmentStep>> getStepsForDiagnoses(List<int> diagnosisIds);
  Future<List<TreatmentStep>> getStepsInRange(DateTime from, DateTime to);
  Future<List<TreatmentStepWithDiagnosis>> getStepsWithDiagnosisInRange(
    DateTime from,
    DateTime to,
  );
  Future<void> completeStep(int stepId);
  Future<void> uncompleteStep(int stepId);
}
