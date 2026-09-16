import '../database/database.dart';
import 'notification_service.dart';

/// Планировщик уведомлений о шагах лечения.
///
/// Единая точка работы с уведомлениями лечения: планирование,
/// отмена, пересчёт после завершения шага, синхронизация при старте.
class TreatmentScheduler {
  TreatmentScheduler(this._db, this._notifications);

  final AppDatabase _db;
  final NotificationService _notifications;

  /// Запланировать уведомления для всех незавершённых шагов диагноза.
  ///
  /// Поведение:
  ///  * если диагноз не найден или уже resolved — все его уведомления
  ///    отменяются;
  ///  * выполненные шаги — уведомление отменяется;
  ///  * просроченные шаги (dueAt в прошлом) — пропускаются;
  ///  * остальные — планируются.
  Future<void> scheduleForDiagnosis(int diagnosisId) async {
    final diagnosis = await _db.diagnosisDao.getById(diagnosisId);
    if (diagnosis == null) return;

    // Если диагноз закрыт — всё его лечение больше не должно напоминать.
    if (diagnosis.status != 'active') {
      await cancelForDiagnosis(diagnosisId);
      return;
    }

    final steps = await _db.diagnosisDao.getSteps(diagnosisId);
    if (steps.isEmpty) return;

    final diseaseName = await _diseaseName(diagnosis.diseaseId);
    final now = DateTime.now();

    for (final step in steps) {
      if (step.isCompleted) {
        await _notifications.cancelTreatmentStep(step.id);
        continue;
      }
      if (!step.dueAt.isAfter(now)) {
        // Просроченные не планируем — они уже неактуальны.
        await _notifications.cancelTreatmentStep(step.id);
        continue;
      }
      await _notifications.scheduleTreatmentStep(
        stepId: step.id,
        diagnosisId: diagnosisId,
        diseaseName: diseaseName,
        stepTitle: step.title,
        when: step.dueAt,
      );
    }
  }

  /// Отменить все уведомления, связанные с диагнозом.
  Future<void> cancelForDiagnosis(int diagnosisId) async {
    final steps = await _db.diagnosisDao.getSteps(diagnosisId);
    for (final step in steps) {
      await _notifications.cancelTreatmentStep(step.id);
    }
  }

  /// Пересчитать уведомления после завершения шага.
  ///
  /// Отменяет уведомление завершённого шага и пересчитывает все
  /// остальные шаги диагноза.
  Future<void> rescheduleAfterStepCompleted({
    required int diagnosisId,
    required int completedStepId,
  }) async {
    await _notifications.cancelTreatmentStep(completedStepId);
    await scheduleForDiagnosis(diagnosisId);
  }

  /// Синхронизировать уведомления всех активных диагнозов.
  ///
  /// Вызывается при старте приложения: пересчитывает уведомления
  /// с учётом текущего состояния БД.
  Future<void> syncAll() async {
    final diagnoses = await _db.diagnosisDao.getActive();
    for (final d in diagnoses) {
      await scheduleForDiagnosis(d.id);
    }
  }

  /// Получить название болезни по id (или fallback).
  Future<String> _diseaseName(String? diseaseId) async {
    if (diseaseId == null || diseaseId.isEmpty) return 'растение';
    final disease = await _db.diseaseDao.getById(diseaseId);
    return disease?.name ?? diseaseId;
  }
}
