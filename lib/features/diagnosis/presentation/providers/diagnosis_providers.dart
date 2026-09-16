import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../core/services/disease_identifier_service.dart';
import '../../../../domain/models/active_diagnosis.dart';
import '../../../../domain/models/treatment_step_with_diagnosis.dart';
import '../../../calendar/presentation/providers/calendar_providers.dart';
import '../../../plants/presentation/providers/plants_filter_providers.dart';

/// Состояние экрана диагностики.
class DiagnosisScreenState {
  const DiagnosisScreenState({
    this.imageFile,
    this.isProcessing = false,
    this.results = const [],
    this.error,
  });

  final File? imageFile;
  final bool isProcessing;
  final List<DiagnosisResult> results;
  final String? error;

  DiagnosisScreenState copyWith({
    File? imageFile,
    bool? isProcessing,
    List<DiagnosisResult>? results,
    String? error,
    bool clearError = false,
  }) {
    return DiagnosisScreenState(
      imageFile: imageFile ?? this.imageFile,
      isProcessing: isProcessing ?? this.isProcessing,
      results: results ?? this.results,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class DiagnosisNotifier extends Notifier<DiagnosisScreenState> {
  @override
  DiagnosisScreenState build() => const DiagnosisScreenState();

  Future<void> setImageAndDiagnose(File file) async {
    state = state.copyWith(
      imageFile: file,
      isProcessing: true,
      results: const [],
      clearError: true,
    );

    try {
      final service = ref.read(diseaseIdentifierProvider);
      await service.initialize();
      final results = await service.diagnose(file);
      state = state.copyWith(isProcessing: false, results: results);
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: e.toString());
    }
  }

  void clear() {
    state = const DiagnosisScreenState();
  }
}

final diagnosisScreenProvider =
    NotifierProvider<DiagnosisNotifier, DiagnosisScreenState>(
      DiagnosisNotifier.new,
    );

// =========================================================================
//  Диагнозы
// =========================================================================

final activeDiagnosesProvider = FutureProvider<List<Diagnose>>((ref) async {
  final repo = ref.watch(diagnosisRepositoryProvider);
  return repo.getActive();
});

final activeDiagnosesForPlantProvider =
    FutureProvider.family<List<ActiveDiagnosis>, int>((ref, plantId) async {
      final repo = ref.watch(diagnosisRepositoryProvider);
      final db = ref.watch(databaseProvider);

      final diagnoses = await repo.getActiveByPlant(plantId);
      if (diagnoses.isEmpty) return const <ActiveDiagnosis>[];

      final ids = diagnoses.map((d) => d.id).toList(growable: false);
      final allSteps = await repo.getStepsForDiagnoses(ids);

      final stepsByDiagnosis = <int, List<TreatmentStep>>{};
      for (final s in allSteps) {
        stepsByDiagnosis
            .putIfAbsent(s.diagnosisId, () => <TreatmentStep>[])
            .add(s);
      }

      final result = <ActiveDiagnosis>[];
      for (final d in diagnoses) {
        final steps = stepsByDiagnosis[d.id] ?? const <TreatmentStep>[];

        var completed = 0;
        TreatmentStep? current;
        for (final s in steps) {
          if (s.isCompleted) {
            completed++;
            continue;
          }
          if (current == null || s.stepNumber < current.stepNumber) {
            current = s;
          }
        }

        final disease = d.diseaseId != null
            ? await db.diseaseDao.getById(d.diseaseId!)
            : null;

        result.add(
          ActiveDiagnosis(
            diagnosis: d,
            disease: disease,
            currentStep: current,
            totalSteps: steps.length,
            completedSteps: completed,
          ),
        );
      }
      return result;
    });

final diagnosisByIdProvider = FutureProvider.family<Diagnose?, int>((
  ref,
  id,
) async {
  final repo = ref.watch(diagnosisRepositoryProvider);
  return repo.getById(id);
});

final treatmentStepsProvider = FutureProvider.family<List<TreatmentStep>, int>((
  ref,
  diagnosisId,
) async {
  final repo = ref.watch(diagnosisRepositoryProvider);
  return repo.getSteps(diagnosisId);
});

final diseaseByIdProvider = FutureProvider.family<PlantDisease?, String>((
  ref,
  id,
) async {
  final db = ref.watch(databaseProvider);
  return db.diseaseDao.getById(id);
});

/// Все болезни из справочника — для диалога «Изменить диагноз».
final allDiseasesProvider = FutureProvider<List<PlantDisease>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.diseaseDao.getAll();
});

final treatmentStepsInRangeProvider =
    FutureProvider.family<
      List<TreatmentStepWithDiagnosis>,
      ({DateTime from, DateTime to})
    >((ref, range) async {
      final repo = ref.watch(diagnosisRepositoryProvider);
      return repo.getStepsWithDiagnosisInRange(range.from, range.to);
    });

// =========================================================================
//  Контроллер
// =========================================================================

final diagnosisControllerProvider = Provider<DiagnosisController>((ref) {
  return DiagnosisController(ref);
});

class DiagnosisController {
  DiagnosisController(this._ref);

  final Ref _ref;

  Future<int> startTreatment({
    required String diseaseId,
    required int userId,
    int? plantId,
    String? imagePath,
    double? confidence,
  }) async {
    final useCase = _ref.read(startTreatmentProvider);
    final id = await useCase(
      diseaseId: diseaseId,
      userId: userId,
      plantId: plantId,
      imagePath: imagePath,
      confidence: confidence,
    );

    _invalidateAll();

    return id;
  }

  Future<void> completeStep(int stepId, int diagnosisId) async {
    final repo = _ref.read(diagnosisRepositoryProvider);
    final scheduler = _ref.read(treatmentSchedulerProvider);

    await repo.completeStep(stepId);

    await scheduler.rescheduleAfterStepCompleted(
      diagnosisId: diagnosisId,
      completedStepId: stepId,
    );

    _invalidateAll();
    _ref.invalidate(treatmentStepsProvider(diagnosisId));

    final steps = await repo.getSteps(diagnosisId);
    if (steps.isNotEmpty && steps.every((s) => s.isCompleted)) {
      await repo.resolve(diagnosisId);
      await scheduler.cancelForDiagnosis(diagnosisId);
      _invalidateAll();
      _ref.invalidate(diagnosisByIdProvider(diagnosisId));
    }
  }

  Future<void> uncompleteStep(int stepId, int diagnosisId) async {
    final repo = _ref.read(diagnosisRepositoryProvider);
    final scheduler = _ref.read(treatmentSchedulerProvider);

    await repo.uncompleteStep(stepId);

    final diagnosis = await repo.getById(diagnosisId);
    if (diagnosis != null && diagnosis.status != 'active') {
      await repo.reactivate(diagnosisId);
    }

    await scheduler.scheduleForDiagnosis(diagnosisId);

    _invalidateAll();
    _ref.invalidate(treatmentStepsProvider(diagnosisId));
    _ref.invalidate(diagnosisByIdProvider(diagnosisId));
  }

  /// Удалить диагноз вместе со всеми шагами и уведомлениями.
  Future<void> deleteDiagnosis(int diagnosisId) async {
    final repo = _ref.read(diagnosisRepositoryProvider);
    final scheduler = _ref.read(treatmentSchedulerProvider);

    // 1. Отменяем уведомления шагов лечения.
    await scheduler.cancelForDiagnosis(diagnosisId);

    // 2. Удаляем диагноз и шаги из БД (в транзакции).
    await repo.deleteDiagnosis(diagnosisId);

    // 3. Инвалидация провайдеров UI.
    _invalidateAll();
    _ref.invalidate(diagnosisByIdProvider(diagnosisId));
    _ref.invalidate(treatmentStepsProvider(diagnosisId));
  }

  /// Сменить диагноз: удалить текущий и создать новый с другой болезнью.
  ///
  /// Возвращает id нового диагноза. Сохраняет привязку к растению,
  /// фото и уверенность исходного диагноза.
  Future<int> changeDiagnosis({
    required int diagnosisId,
    required String newDiseaseId,
    required int userId,
  }) async {
    final repo = _ref.read(diagnosisRepositoryProvider);
    final scheduler = _ref.read(treatmentSchedulerProvider);

    // 1. Сохраняем данные старого диагноза, которые перенесём в новый.
    final old = await repo.getById(diagnosisId);
    if (old == null) {
      throw Exception('Диагноз не найден');
    }

    // 2. Отменяем уведомления старого диагноза.
    await scheduler.cancelForDiagnosis(diagnosisId);

    // 3. Удаляем старый диагноз со всеми шагами.
    await repo.deleteDiagnosis(diagnosisId);

    // 4. Создаём новый диагноз с той же болезнью.
    final useCase = _ref.read(startTreatmentProvider);
    final newId = await useCase(
      diseaseId: newDiseaseId,
      userId: userId,
      plantId: old.plantId,
      imagePath: old.imagePath,
      confidence: old.confidence,
    );

    // 5. Инвалидация.
    _invalidateAll();
    _ref.invalidate(diagnosisByIdProvider(diagnosisId));
    _ref.invalidate(diagnosisByIdProvider(newId));

    return newId;
  }

  /// Инвалидация провайдеров, зависящих от списка диагнозов.
  void _invalidateAll() {
    _ref.invalidate(activeDiagnosesProvider);
    _ref.invalidate(activeDiagnosesForPlantProvider);
    _ref.invalidate(treatmentStepsInRangeProvider);
    _ref.invalidate(calendarEventsProvider);
    _ref.invalidate(filteredPlantsProvider);
  }
}
