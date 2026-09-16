import 'package:drift/drift.dart';

import '../../../domain/models/treatment_step_with_diagnosis.dart';
import '../database.dart';
import '../tables.dart';

part 'diagnosis_dao.g.dart';

@DriftAccessor(tables: [Diagnoses, TreatmentSteps])
class DiagnosisDao extends DatabaseAccessor<AppDatabase>
    with _$DiagnosisDaoMixin {
  DiagnosisDao(super.db);

  // -----------------------------------------------------------------
  // Diagnoses
  // -----------------------------------------------------------------

  Future<List<Diagnose>> getActive() =>
      (select(diagnoses)..where((t) => t.status.equals('active'))).get();

  Future<List<Diagnose>> getByPlant(int plantId) =>
      (select(diagnoses)..where((t) => t.plantId.equals(plantId))).get();

  Future<List<Diagnose>> getActiveByPlant(int plantId) =>
      (select(diagnoses)
            ..where(
              (t) => t.plantId.equals(plantId) & t.status.equals('active'),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
          .get();

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

  Future<int> reactivate(int id) =>
      (update(diagnoses)..where((t) => t.id.equals(id))).write(
        const DiagnosesCompanion(
          status: Value('active'),
          resolvedAt: Value(null),
        ),
      );

  Future<int> deleteDiagnosis(int id) =>
      (delete(diagnoses)..where((t) => t.id.equals(id))).go();

  // -----------------------------------------------------------------
  // TreatmentSteps
  // -----------------------------------------------------------------

  Future<int> insertStep(TreatmentStepsCompanion s) =>
      into(treatmentSteps).insert(s);

  Future<List<TreatmentStep>> getSteps(int diagnosisId) =>
      (select(treatmentSteps)
            ..where((t) => t.diagnosisId.equals(diagnosisId))
            ..orderBy([(t) => OrderingTerm.asc(t.stepNumber)]))
          .get();

  Future<TreatmentStep?> getCurrentStep(int diagnosisId) =>
      (select(treatmentSteps)
            ..where(
              (t) =>
                  t.diagnosisId.equals(diagnosisId) &
                  t.isCompleted.equals(false),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.stepNumber)])
            ..limit(1))
          .getSingleOrNull();

  Future<List<TreatmentStep>> getStepsForDiagnoses(List<int> diagnosisIds) {
    if (diagnosisIds.isEmpty) return Future.value(const []);
    return (select(treatmentSteps)
          ..where((t) => t.diagnosisId.isIn(diagnosisIds))
          ..orderBy([
            (t) => OrderingTerm.asc(t.diagnosisId),
            (t) => OrderingTerm.asc(t.stepNumber),
          ]))
        .get();
  }

  Future<List<TreatmentStep>> getStepsInRange(DateTime from, DateTime to) =>
      (select(treatmentSteps)
            ..where((t) => t.dueAt.isBetweenValues(from, to))
            ..orderBy([(t) => OrderingTerm.asc(t.dueAt)]))
          .get();

  Future<List<TreatmentStepWithDiagnosis>> getStepsWithDiagnosisInRange(
    DateTime from,
    DateTime to,
  ) async {
    final query =
        select(treatmentSteps).join([
            innerJoin(
              diagnoses,
              diagnoses.id.equalsExp(treatmentSteps.diagnosisId),
            ),
          ])
          ..where(treatmentSteps.dueAt.isBetweenValues(from, to))
          ..orderBy([OrderingTerm.asc(treatmentSteps.dueAt)]);

    final rows = await query.get();
    return rows
        .map(
          (row) => TreatmentStepWithDiagnosis(
            step: row.readTable(treatmentSteps),
            diagnosis: row.readTable(diagnoses),
          ),
        )
        .toList(growable: false);
  }

  /// Незавершённые шаги лечения, у которых `dueAt <= until`.
  ///
  /// Используется на экране «Сегодня»: показать всё, что нужно
  /// сделать сегодня или просрочено, вместе с диагнозом и растением.
  Future<List<TreatmentStepWithDiagnosis>> getPendingStepsWithDiagnosisUntil(
    DateTime until,
  ) async {
    final query =
        select(treatmentSteps).join([
            innerJoin(
              diagnoses,
              diagnoses.id.equalsExp(treatmentSteps.diagnosisId),
            ),
          ])
          ..where(treatmentSteps.dueAt.isSmallerOrEqualValue(until))
          ..where(treatmentSteps.isCompleted.equals(false))
          ..orderBy([OrderingTerm.asc(treatmentSteps.dueAt)]);

    final rows = await query.get();
    return rows
        .map(
          (row) => TreatmentStepWithDiagnosis(
            step: row.readTable(treatmentSteps),
            diagnosis: row.readTable(diagnoses),
          ),
        )
        .toList(growable: false);
  }

  Future<int> completeStep(int stepId) =>
      (update(treatmentSteps)..where((t) => t.id.equals(stepId))).write(
        TreatmentStepsCompanion(
          isCompleted: const Value(true),
          completedAt: Value(DateTime.now()),
        ),
      );

  Future<int> uncompleteStep(int stepId) =>
      (update(treatmentSteps)..where((t) => t.id.equals(stepId))).write(
        const TreatmentStepsCompanion(
          isCompleted: Value(false),
          completedAt: Value(null),
        ),
      );

  /// Удалить все шаги диагноза. Вызывается перед удалением самого
  /// диагноза — иначе foreign key не даст удалить запись.
  Future<int> deleteStepsForDiagnosis(int diagnosisId) => (delete(
    treatmentSteps,
  )..where((t) => t.diagnosisId.equals(diagnosisId))).go();
}
