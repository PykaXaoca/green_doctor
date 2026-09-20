import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'asset_folder_loader.dart';

/// Результат диагностики.
class DiagnosisResult {
  const DiagnosisResult({required this.label, required this.confidence});

  final String label;
  final double confidence;

  @override
  String toString() =>
      'DiagnosisResult(label: $label, confidence: ${confidence.toStringAsFixed(3)})';
}

/// Сервис диагностики болезней по фото.
class DiseaseIdentifierService {
  DiseaseIdentifierService();

  static const String _modelAsset =
      'assets/models/disease_diagnosis_model.tflite';
  static const String _labelsAsset = 'assets/models/disease_labels.txt';
  static const String _diseasesFolder = 'assets/data/diseases';
  static const int _inputSize = 224;

  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _mockMode = true;
  bool _initialized = false;

  bool get isMockMode => _mockMode;

  Future<void> initialize() async {
    if (_initialized) return;

    _labels = await _loadLabels();

    try {
      _interpreter = await Interpreter.fromAsset(_modelAsset);
      _mockMode = false;
    } catch (e) {
      _mockMode = true;
      if (kDebugMode) {
        debugPrint('[DiseaseIdentifier] Модель не найдена, mock-режим: $e');
      }
    }

    _initialized = true;
  }

  /// Загружает метки: сначала из `disease_labels.txt`, если нет —
  /// из папки `assets/data/diseases/` (в порядке `model_label_id`).
  Future<List<String>> _loadLabels() async {
    try {
      final labelsData = await rootBundle.loadString(_labelsAsset);
      final labels = labelsData
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (labels.isNotEmpty) return labels;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[DiseaseIdentifier] $_labelsAsset не найден, '
          'fallback на $_diseasesFolder: $e',
        );
      }
    }

    try {
      final byId = await loadJsonObjectsByIdFromFolder(_diseasesFolder);
      final entries = byId.values.map((map) {
        return (
          id: map['id'] as String,
          order: (map['model_label_id'] as int?) ?? 1 << 30,
        );
      }).toList()..sort((a, b) => a.order.compareTo(b.order));
      return entries.map((e) => e.id).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DiseaseIdentifier] Не удалось загрузить метки: $e');
      }
      return const [];
    }
  }

  Future<List<DiagnosisResult>> diagnose(
    File imageFile, {
    int topK = 3,
    double minConfidence = 0.05,
  }) async {
    if (!_initialized) await initialize();

    if (_mockMode || _interpreter == null) {
      return _mockDiagnose(topK: topK);
    }

    try {
      final bytes = await imageFile.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return [];

      final resized = img.copyResize(
        decoded,
        width: _inputSize,
        height: _inputSize,
      );

      final input = _prepareInput(resized);
      final output = _prepareOutput();

      _interpreter!.run(input, output);

      return _processOutput(output, topK: topK, minConfidence: minConfidence);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DiseaseIdentifier] Ошибка inference: $e');
      }
      return [];
    }
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _initialized = false;
    _mockMode = true;
    _labels = [];
  }

  List<List<List<List<double>>>> _prepareInput(img.Image image) {
    final inputType = _interpreter!.getInputTensor(0).type;
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
            return [r, g, b];
          } else {
            return [(r / 127.5) - 1.0, (g / 127.5) - 1.0, (b / 127.5) - 1.0];
          }
        }),
      ),
    );
  }

  List<List<double>> _prepareOutput() {
    final outputShape = _interpreter!.getOutputTensor(0).shape;
    final numClasses = outputShape.last;
    return List.generate(1, (_) => List.filled(numClasses, 0.0));
  }

  List<DiagnosisResult> _processOutput(
    List<List<double>> output, {
    required int topK,
    required double minConfidence,
  }) {
    final outputType = _interpreter!.getOutputTensor(0).type;
    final isUint8 = outputType == TensorType.uint8;

    final probs = output.first.map((v) => isUint8 ? v / 255.0 : v).toList();

    final sum = probs.fold<double>(0, (a, b) => a + b);
    final normalized = sum > 0 && (sum - 1.0).abs() > 0.01
        ? probs.map((v) => v / sum).toList()
        : probs;

    final indexed = List.generate(normalized.length, (i) => i);
    indexed.sort((a, b) => normalized[b].compareTo(normalized[a]));

    final results = <DiagnosisResult>[];
    for (var i = 0; i < math.min(topK, indexed.length); i++) {
      final idx = indexed[i];
      final confidence = normalized[idx];
      if (confidence < minConfidence) continue;
      final label = idx < _labels.length ? _labels[idx] : 'class_$idx';
      results.add(DiagnosisResult(label: label, confidence: confidence));
    }
    return results;
  }

  List<DiagnosisResult> _mockDiagnose({required int topK}) {
    if (_labels.isEmpty) return const [];

    final rng = math.Random();
    final shuffled = List<String>.from(_labels)..shuffle(rng);
    final selected = shuffled.take(math.min(topK, shuffled.length)).toList();

    final rawProbs = List.generate(
      selected.length,
      (_) => rng.nextDouble() + 0.3,
    )..sort((a, b) => b.compareTo(a));
    final sum = rawProbs.fold<double>(0, (a, b) => a + b);

    return List.generate(
      selected.length,
      (i) => DiagnosisResult(label: selected[i], confidence: rawProbs[i] / sum),
    );
  }
}
