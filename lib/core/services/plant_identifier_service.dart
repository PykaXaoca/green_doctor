import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Результат распознавания.
class RecognitionResult {
  const RecognitionResult({required this.label, required this.confidence});

  /// Идентификатор вида (соответствует `PlantSpecies.id`).
  final String label;

  /// Уверенность 0.0 – 1.0.
  final double confidence;

  @override
  String toString() =>
      'RecognitionResult(label: $label, confidence: ${confidence.toStringAsFixed(3)})';
}

/// Сервис идентификации растений по фото.
///
/// Работает в двух режимах:
/// - **real** — если в assets/models/plant_identification_model.tflite
///   есть обученная модель.
/// - **mock** — если модели нет: возвращает случайные результаты из labels.txt.
///   Полезно для разработки и тестирования UI.
class PlantIdentifierService {
  PlantIdentifierService();

  static const String _modelAsset =
      'assets/models/plant_identification_model.tflite';
  static const String _labelsAsset = 'assets/models/labels.txt';
  static const int _inputSize = 224;

  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _mockMode = true;
  bool _initialized = false;

  /// Работает ли сервис в mock-режиме (без реальной модели).
  bool get isMockMode => _mockMode;

  /// Инициализация сервиса. Вызывается один раз при старте приложения.
  Future<void> initialize() async {
    if (_initialized) return;

    // Загружаем метки — они нужны в обоих режимах.
    try {
      final labelsData = await rootBundle.loadString(_labelsAsset);
      _labels = labelsData
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[PlantIdentifier] Не удалось загрузить labels.txt: $e');
      }
      _labels = [];
    }

    // Пытаемся загрузить модель.
    try {
      _interpreter = await Interpreter.fromAsset(_modelAsset);
      _mockMode = false;
      if (kDebugMode) {
        // ignore: avoid_print
        print('[PlantIdentifier] Модель загружена: $_modelAsset');
      }
    } catch (e) {
      _mockMode = true;
      if (kDebugMode) {
        // ignore: avoid_print
        print('[PlantIdentifier] Модель не найдена, mock-режим: $e');
      }
    }

    _initialized = true;
  }

  /// Идентифицировать растение на изображении.
  ///
  /// Возвращает top-K результатов, отсортированных по уверенности.
  /// Результаты с уверенностью ниже [minConfidence] отбрасываются.
  Future<List<RecognitionResult>> identify(
    File imageFile, {
    int topK = 3,
    double minConfidence = 0.05,
  }) async {
    if (!_initialized) await initialize();

    if (_mockMode || _interpreter == null) {
      return _mockIdentify(topK: topK);
    }

    try {
      final bytes = await imageFile.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return [];

      // Ресайз до 224x224.
      final resized = img.copyResize(
        decoded,
        width: _inputSize,
        height: _inputSize,
      );

      // Подготовка входного тензора.
      final input = _prepareInput(resized);
      final output = _prepareOutput();

      // Inference.
      _interpreter!.run(input, output);

      return _processOutput(output, topK: topK, minConfidence: minConfidence);
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[PlantIdentifier] Ошибка inference: $e');
      }
      return [];
    }
  }

  /// Освободить ресурсы.
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _initialized = false;
  }

  // ---------- Приватные методы ----------

  /// Подготовка входа. Формат: [1, 224, 224, 3], значения -1.0 … 1.0.
  List<List<List<List<double>>>> _prepareInput(img.Image image) {
    // Проверяем реальный тип входа модели.
    final inputType = _interpreter!.getInputTensor(0).type;

    // Для uint8-квантованной модели вход в 0…255.
    final isUint8 = inputType == TensorType.uint8;

    return List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (y) => List.generate(_inputSize, (x) {
          final pixel = image.getPixel(x, y);
          final r = pixel.r.toDouble();
          final g = pixel.g.toDouble();
          final b = pixel.b.toDouble();

          if (isUint8) {
            // Квантованная модель ожидает 0…255.
            return [r, g, b];
          } else {
            // Float-модель ожидает -1…1.
            return [(r / 127.5) - 1.0, (g / 127.5) - 1.0, (b / 127.5) - 1.0];
          }
        }),
      ),
    );
  }

  /// Выделяем выходной буфер под размерность модели.
  List<List<double>> _prepareOutput() {
    final outputShape = _interpreter!.getOutputTensor(0).shape;
    // Обычно [1, N].
    final numClasses = outputShape.last;
    return List.generate(1, (_) => List.filled(numClasses, 0.0));
  }

  /// Обработка выхода модели.
  List<RecognitionResult> _processOutput(
    List<List<double>> output, {
    required int topK,
    required double minConfidence,
  }) {
    final outputType = _interpreter!.getOutputTensor(0).type;
    final isUint8 = outputType == TensorType.uint8;

    final probs = output.first.map((v) {
      // Если квантовано в uint8 — делим на 255.
      return isUint8 ? v / 255.0 : v;
    }).toList();

    // Если модель вернула логиты (не softmax) — нормализуем.
    final sum = probs.fold<double>(0, (a, b) => a + b);
    final normalized = sum > 0 && (sum - 1.0).abs() > 0.01
        ? probs.map((v) => v / sum).toList()
        : probs;

    // Индексы и значения.
    final indexed = List.generate(normalized.length, (i) => i);
    indexed.sort((a, b) => normalized[b].compareTo(normalized[a]));

    final results = <RecognitionResult>[];
    for (var i = 0; i < math.min(topK, indexed.length); i++) {
      final idx = indexed[i];
      final confidence = normalized[idx];
      if (confidence < minConfidence) continue;
      final label = idx < _labels.length ? _labels[idx] : 'class_$idx';
      results.add(RecognitionResult(label: label, confidence: confidence));
    }
    return results;
  }

  /// Mock-режим: случайные результаты из labels.txt.
  List<RecognitionResult> _mockIdentify({required int topK}) {
    if (_labels.isEmpty) {
      return const [];
    }

    final rng = math.Random();
    // Выбираем topK разных меток.
    final shuffled = List<String>.from(_labels)..shuffle(rng);
    final selected = shuffled.take(math.min(topK, shuffled.length)).toList();

    // Генерируем убывающие вероятности.
    final rawProbs = List.generate(
      selected.length,
      (_) => rng.nextDouble() + 0.3,
    )..sort((a, b) => b.compareTo(a));
    final sum = rawProbs.fold<double>(0, (a, b) => a + b);

    return List.generate(
      selected.length,
      (i) =>
          RecognitionResult(label: selected[i], confidence: rawProbs[i] / sum),
    );
  }
}
