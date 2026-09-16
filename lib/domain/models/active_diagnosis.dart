import '../../core/database/database.dart';

/// Сводка по активному диагнозу для UI.
///
/// Объединяет:
///  * [Diagnose] — запись о диагнозе (когда начат, статус, картинка);
///  * [PlantDisease] — данные справочника (название, описание, симптомы);
///  * [TreatmentStep] — текущий шаг и прогресс по шагам.
///
/// Используется в карточке растения (раздел «Здоровье») и в списке
/// активных лечений, чтобы экраны не собирали эти данные вручную.
class ActiveDiagnosis {
  const ActiveDiagnosis({
    required this.diagnosis,
    required this.disease,
    required this.currentStep,
    required this.totalSteps,
    required this.completedSteps,
  });

  final Diagnose diagnosis;

  /// Данные из справочника болезней.
  /// Может быть `null`, если запись удалена или id не найден.
  final PlantDisease? disease;

  /// Первый незавершённый шаг (по порядку `stepNumber`).
  /// `null`, если все шаги выполнены или шагов нет.
  final TreatmentStep? currentStep;

  final int totalSteps;
  final int completedSteps;

  int get diagnosisId => diagnosis.id;
  int? get plantId => diagnosis.plantId;
  String get diseaseId => diagnosis.diseaseId ?? '';

  /// Человекочитаемое название болезни (или fallback на id).
  String get diseaseName => disease?.name ?? diseaseId;

  String? get diseaseDescription => disease?.description;

  /// Прогресс от 0.0 до 1.0.
  double get progress {
    if (totalSteps <= 0) return 0.0;
    final value = completedSteps / totalSteps;
    if (value < 0) return 0;
    if (value > 1) return 1;
    return value;
  }

  /// Все шаги выполнены (лечение можно закрывать).
  bool get isFinished => totalSteps > 0 && completedSteps >= totalSteps;

  /// Номер текущего шага (1-based) — для отображения «Шаг 2 из 5».
  int get currentStepNumber => currentStep?.stepNumber ?? totalSteps;

  @override
  String toString() =>
      'ActiveDiagnosis(id: $diagnosisId, disease: $diseaseName, '
      'progress: $completedSteps/$totalSteps)';
}
