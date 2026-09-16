import '../../domain/models/treatment_step_draft.dart';
import '../database/database.dart';

/// Источник плана лечения.
///
/// Отвечает за формирование списка шагов для конкретного диагноза.
/// Само сохранение в БД — не его задача, это делает `StartTreatment`.
///
/// Сейчас единственная реализация — [StaticTreatmentPlanSource]:
/// она читает план из [PlantDisease.treatmentPlanJson].
///
/// ============================================================================
///  ПОДКЛЮЧЕНИЕ ИИ (будущее)
/// ============================================================================
///
/// Когда появится модель, формирующая индивидуальный план лечения,
/// добавьте вторую реализацию `AiTreatmentPlanSource`:
///
///   1. Создайте `lib/core/services/ai_treatment_plan_source.dart`,
///      реализующий этот же интерфейс.
///   2. Внутри `buildPlan` — вызовите модель, передав ей `diagnosis`,
///      `disease`, `plant` и, при желании, погоду/влажность.
///   3. В `lib/core/providers/service_providers.dart` замените
///      `StaticTreatmentPlanSource` на `AiTreatmentPlanSource` в
///      `treatmentPlanSourceProvider`.
///   4. `StartTreatment` менять не нужно — он работает через интерфейс.
///
/// Никаких других точек правок нет — специально, чтобы было видно,
/// где именно менять.
///
/// ============================================================================
///  ПРЕМИУМ (будущее)
/// ============================================================================
///
/// Сейчас в приложении всё бесплатно, поле [PlantDisease.isPremium]
/// игнорируется. Когда появится подписка, фильтрация должна быть
/// **здесь**, в источнике плана:
///
///   if (disease.isPremium && !user.hasActiveSubscription) {
///     return buildPreviewPlan(disease); // короткий превью-план
///   }
///
/// UI (`DiagnosisCard`, `HealthSection`) специально не знает про
/// премиум — он показывает то, что вернул источник. Это позволяет
/// менять правила доступа без правки интерфейса.
abstract class TreatmentPlanSource {
  /// Построить план лечения для диагноза.
  ///
  /// Возвращает список черновиков шагов. Пустой список означает
  /// «плана нет» — например, если у болезни не заполнен
  /// `treatmentPlanJson`.
  Future<List<TreatmentStepDraft>> buildPlan({
    required Diagnose diagnosis,
    required PlantDisease disease,
    Plant? plant,
  });
}
