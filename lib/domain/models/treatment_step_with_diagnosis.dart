import '../../core/database/database.dart';

/// Шаг лечения вместе с диагнозом, к которому он относится.
///
/// Используется в календаре: для одной записи нужен и сам шаг
/// (дата, название действия), и диагноз (какое растение, какая болезнь).
class TreatmentStepWithDiagnosis {
  const TreatmentStepWithDiagnosis({
    required this.step,
    required this.diagnosis,
  });

  final TreatmentStep step;
  final Diagnose diagnosis;

  int? get plantId => diagnosis.plantId;
  String? get diseaseId => diagnosis.diseaseId;
}
