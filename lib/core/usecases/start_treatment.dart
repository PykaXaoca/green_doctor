import 'dart:io';

import 'package:drift/drift.dart';

import '../database/database.dart';
import '../services/gamification_service.dart';
import '../services/image_storage_service.dart';
import '../services/treatment_plan_source.dart';
import '../services/treatment_scheduler.dart';

/// Use case начала лечения растения.
///
/// Логика:
///  1. Копирует фото диагноза в постоянную папку приложения
///     (иначе image_picker может очистить временный файл).
///  2. Создаёт запись диагноза в БД.
///  3. Запрашивает план лечения у [TreatmentPlanSource] —
///     сейчас это статический JSON, в будущем может быть ИИ.
///  4. Сохраняет шаги плана.
///  5. Планирует уведомления через [TreatmentScheduler].
///  6. Начисляет XP.
class StartTreatment {
  StartTreatment(
    this._db,
    this._planSource,
    this._treatmentScheduler,
    this._gamification,
    this._imageStorage,
  );

  final AppDatabase _db;
  final TreatmentPlanSource _planSource;
  final TreatmentScheduler _treatmentScheduler;
  final GamificationService _gamification;
  final ImageStorageService _imageStorage;

  Future<int> call({
    required String diseaseId,
    required int userId,
    int? plantId,
    String? imagePath,
    double? confidence,
  }) async {
    final disease = await _db.diseaseDao.getById(diseaseId);
    if (disease == null) {
      throw Exception('Болезнь не найдена: $diseaseId');
    }

    // Сохраняем фото диагноза в постоянную папку приложения.
    final savedImagePath = await _persistDiagnosisImage(imagePath);

    final diagnosisId = await _db.diagnosisDao.insertDiagnosis(
      DiagnosesCompanion(
        plantId: Value(plantId),
        diseaseId: Value(diseaseId),
        imagePath: Value(savedImagePath),
        confidence: Value(confidence),
        status: const Value('active'),
      ),
    );

    final diagnosis = await _db.diagnosisDao.getById(diagnosisId);
    if (diagnosis != null) {
      Plant? plant;
      if (plantId != null) {
        plant = await _db.plantDao.getById(plantId);
      }

      final drafts = await _planSource.buildPlan(
        diagnosis: diagnosis,
        disease: disease,
        plant: plant,
      );

      for (final draft in drafts) {
        await _db.diagnosisDao.insertStep(
          TreatmentStepsCompanion(
            diagnosisId: Value(diagnosisId),
            stepNumber: Value(draft.stepNumber),
            title: Value(draft.title),
            description: Value(draft.description),
            dueAt: Value(draft.dueAt),
          ),
        );
      }
    }

    await _treatmentScheduler.scheduleForDiagnosis(diagnosisId);

    await _gamification.addXp(
      userId: userId,
      amount: XpReward.diagnosis,
      reason: 'diagnosis',
    );

    return diagnosisId;
  }

  /// Копирует фото в постоянную папку. Возвращает путь к сохранённому
  /// файлу. Если фото нет или оно уже в нашей папке — возвращает
  /// исходный путь без копирования.
  ///
  /// Ошибки при копировании не блокируют создание диагноза:
  /// в этом случае возвращается исходный путь (может стать недоступным
  /// после перезапуска, но хотя бы диагноз сохранится).
  Future<String?> _persistDiagnosisImage(String? sourcePath) async {
    if (sourcePath == null || sourcePath.isEmpty) return null;

    // Уже в нашей папке — не копируем повторно.
    if (sourcePath.contains('pocket_botanist_images')) return sourcePath;

    try {
      final file = File(sourcePath);
      if (!file.existsSync()) return sourcePath;
      return await _imageStorage.saveImage(file, prefix: 'diagnosis');
    } catch (_) {
      return sourcePath;
    }
  }
}
