import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../core/services/disease_identifier_service.dart';

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

final activeDiagnosesProvider = FutureProvider<List<Diagnose>>((ref) async {
  final repo = ref.watch(diagnosisRepositoryProvider);
  return repo.getActive();
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
    _ref.invalidate(activeDiagnosesProvider);
    return id;
  }

  Future<void> completeStep(int stepId, int diagnosisId) async {
    final repo = _ref.read(diagnosisRepositoryProvider);
    await repo.completeStep(stepId);
    _ref.invalidate(treatmentStepsProvider(diagnosisId));

    final steps = await repo.getSteps(diagnosisId);
    if (steps.isNotEmpty && steps.every((s) => s.isCompleted)) {
      await repo.resolve(diagnosisId);
      _ref.invalidate(activeDiagnosesProvider);
      _ref.invalidate(diagnosisByIdProvider(diagnosisId));
    }
  }
}
