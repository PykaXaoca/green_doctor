/// Черновик шага лечения до сохранения в базу.
///
/// Используется [TreatmentPlanSource]: источник формирует список
/// черновиков, а `StartTreatment` их сохраняет как `TreatmentSteps`.
/// Такое разделение позволяет менять источник плана (статический
/// JSON, ИИ, ручной ввод) без правки логики сохранения.
class TreatmentStepDraft {
  const TreatmentStepDraft({
    required this.stepNumber,
    required this.title,
    required this.dueAt,
    this.description,
  });

  /// Порядковый номер шага (1, 2, 3, ...).
  final int stepNumber;

  /// Краткое название (например, «Обработать фунгицидом»).
  final String title;

  /// Подробное описание или null.
  final String? description;

  /// Когда шаг должен быть выполнен.
  final DateTime dueAt;
}
