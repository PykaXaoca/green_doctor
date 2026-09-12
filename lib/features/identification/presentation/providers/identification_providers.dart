import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/plant_identifier_service.dart';

/// Singleton-провайдер сервиса распознавания.
final plantIdentifierProvider = Provider<PlantIdentifierService>((ref) {
  return PlantIdentifierService();
});

/// Состояние экрана «Определить».
class IdentifyState {
  const IdentifyState({
    this.imageFile,
    this.isProcessing = false,
    this.results = const [],
    this.error,
  });

  final File? imageFile;
  final bool isProcessing;
  final List<RecognitionResult> results;
  final String? error;

  IdentifyState copyWith({
    File? imageFile,
    bool? isProcessing,
    List<RecognitionResult>? results,
    String? error,
    bool clearError = false,
  }) {
    return IdentifyState(
      imageFile: imageFile ?? this.imageFile,
      isProcessing: isProcessing ?? this.isProcessing,
      results: results ?? this.results,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Notifier для экрана «Определить».
class IdentifyNotifier extends Notifier<IdentifyState> {
  @override
  IdentifyState build() => const IdentifyState();

  /// Установить изображение и запустить распознавание.
  Future<void> setImageAndIdentify(File file) async {
    state = state.copyWith(
      imageFile: file,
      isProcessing: true,
      results: const [],
      clearError: true,
    );

    try {
      final service = ref.read(plantIdentifierProvider);
      await service.initialize();
      final results = await service.identify(file);
      state = state.copyWith(isProcessing: false, results: results);
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: e.toString());
    }
  }

  /// Очистить состояние.
  void clear() {
    state = const IdentifyState();
  }
}

final identifyProvider = NotifierProvider<IdentifyNotifier, IdentifyState>(
  IdentifyNotifier.new,
);
