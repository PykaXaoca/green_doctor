import 'dart:convert';

import '../../domain/models/treatment_step_draft.dart';
import '../database/database.dart';
import 'treatment_plan_source.dart';

/// Текущая реализация источника плана лечения.
///
/// Читает план из [PlantDisease.treatmentPlanJson] — JSON-массива
/// объектов вида:
///
/// ```json
/// [
///   {"step": 1, "title": "Изолировать растение",
///    "description": "Отодвинуть от других растений на 2 метра",
///    "due_offset_days": 0},
///   {"step": 2, "title": "Обработать фунгицидом",
///    "description": "Опрыскать листья и стебель",
///    "due_offset_days": 2}
/// ]
/// ```
///
/// `due_offset_days` считается от момента создания диагноза.
///
/// Если JSON пустой, сломанный или не соответствует формату —
/// возвращается пустой список, `StartTreatment` создаст диагноз
/// без шагов. UI покажет «Шаги лечения не заданы».
///
/// Этот класс — точка расширения под ИИ. Когда подключите модель,
/// создайте рядом `AiTreatmentPlanSource` и переключите провайдер.
class StaticTreatmentPlanSource implements TreatmentPlanSource {
  const StaticTreatmentPlanSource();

  @override
  Future<List<TreatmentStepDraft>> buildPlan({
    required Diagnose diagnosis,
    required PlantDisease disease,
    Plant? plant,
  }) async {
    final planJson = disease.treatmentPlanJson;
    if (planJson == null || planJson.isEmpty || planJson == '[]') {
      return const <TreatmentStepDraft>[];
    }

    try {
      final decoded = jsonDecode(planJson);
      if (decoded is! List) return const <TreatmentStepDraft>[];

      final now = DateTime.now();
      final drafts = <TreatmentStepDraft>[];

      for (final item in decoded) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);

        final stepNumber = (map['step'] as int?) ?? (drafts.length + 1);
        final title = (map['title'] as String?)?.trim();
        if (title == null || title.isEmpty) continue;

        final description = map['description'] as String?;
        final offsetDays = (map['due_offset_days'] as int?) ?? 0;

        drafts.add(
          TreatmentStepDraft(
            stepNumber: stepNumber,
            title: title,
            description: description,
            dueAt: now.add(Duration(days: offsetDays)),
          ),
        );
      }

      // Сортируем по номеру шага — на случай, если в JSON порядок другой.
      drafts.sort((a, b) => a.stepNumber.compareTo(b.stepNumber));
      return drafts;
    } catch (_) {
      // Сломанный JSON — не роняем приложение, работаем без шагов.
      return const <TreatmentStepDraft>[];
    }
  }
}
