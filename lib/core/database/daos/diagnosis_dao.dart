import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';

part 'diagnosis_dao.g.dart';

@DriftAccessor(tables: [Diagnoses, TreatmentSteps])
class DiagnosisDao extends DatabaseAccessor<AppDatabase>
    with _$DiagnosisDaoMixin {
  DiagnosisDao(super.db);

  Future<List<Diagnose>> getActive() =>
      (select(diagnoses)..where((t) => t.status.equals('active'))).get();

  Future<List<Diagnose>> getByPlant(int plantId) =>
      (select(diagnoses)..where((t) => t.plantId.equals(plantId))).get();

  Future<Diagnose?> getById(int id) =>
      (select(diagnoses)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertDiagnosis(DiagnosesCompanion d) =>
      into(diagnoses).insert(d);

  Future<int> resolve(int id) =>
      (update(diagnoses)..where((t) => t.id.equals(id))).write(
        DiagnosesCompanion(
          status: const Value('resolved'),
          resolvedAt: Value(DateTime.now()),
        ),
      );

  Future<int> insertStep(TreatmentStepsCompanion s) =>
      into(treatmentSteps).insert(s);

  Future<List<TreatmentStep>> getSteps(int diagnosisId) =>
      (select(treatmentSteps)
            ..where((t) => t.diagnosisId.equals(diagnosisId))
            ..orderBy([(t) => OrderingTerm.asc(t.stepNumber)]))
          .get();

  Future<int> completeStep(int stepId) =>
      (update(treatmentSteps)..where((t) => t.id.equals(stepId))).write(
        TreatmentStepsCompanion(
          isCompleted: const Value(true),
          completedAt: Value(DateTime.now()),
        ),
      );
}

