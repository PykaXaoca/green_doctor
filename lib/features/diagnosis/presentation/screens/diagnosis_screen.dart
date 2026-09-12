import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../core/services/disease_identifier_service.dart';
import '../../../plants/presentation/providers/plant_providers.dart';
import '../providers/diagnosis_providers.dart';

/// Экран диагностики болезней.
class DiagnosisScreen extends ConsumerStatefulWidget {
  const DiagnosisScreen({super.key, this.plantId});

  final int? plantId;

  @override
  ConsumerState<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends ConsumerState<DiagnosisScreen> {
  final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(diagnosisScreenProvider);
    final service = ref.watch(diseaseIdentifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Диагностика'),
        actions: [
          if (state.imageFile != null)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Очистить',
              onPressed: () =>
                  ref.read(diagnosisScreenProvider.notifier).clear(),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (service.isMockMode) const _MockModeBanner(),
          _buildImageArea(state),
          const SizedBox(height: 16),
          _buildActionButtons(state),
          if (state.isProcessing) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 8),
            const Center(child: Text('Анализируем...')),
          ],
          if (state.error != null) ...[
            const SizedBox(height: 16),
            _ErrorBox(message: state.error!),
          ],
          if (state.results.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildResults(state),
          ],
        ],
      ),
    );
  }

  Widget _buildImageArea(DiagnosisScreenState state) {
    final file = state.imageFile;
    if (file == null) {
      return Container(
        height: 260,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.healing_outlined,
                size: 72,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 12),
              Text(
                'Сфотографируйте поражённое растение\n'
                'или выберите фото из галереи',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.file(
        file,
        height: 300,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildActionButtons(DiagnosisScreenState state) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: state.isProcessing
                ? null
                : () => _pick(ImageSource.camera),
            icon: const Icon(Icons.photo_camera),
            label: const Text('Камера'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: state.isProcessing
                ? null
                : () => _pick(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Галерея'),
          ),
        ),
      ],
    );
  }

  Widget _buildResults(DiagnosisScreenState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Возможные диагнозы',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...state.results.map(
              (r) => _ResultTile(
                result: r,
                imageFile: state.imageFile!,
                plantId: widget.plantId,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );
      if (picked == null) return;
      await ref
          .read(diagnosisScreenProvider.notifier)
          .setImageAndDiagnose(File(picked.path));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      }
    }
  }
}

class _MockModeBanner extends StatelessWidget {
  const _MockModeBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.amber),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Демо-режим. Модель диагностики не подключена. '
                'Результаты случайные.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultTile extends ConsumerStatefulWidget {
  const _ResultTile({
    required this.result,
    required this.imageFile,
    required this.plantId,
  });

  final DiagnosisResult result;
  final File imageFile;
  final int? plantId;

  @override
  ConsumerState<_ResultTile> createState() => _ResultTileState();
}

class _ResultTileState extends ConsumerState<_ResultTile> {
  PlantDisease? _disease;
  bool _loading = true;
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    _loadDisease();
  }

  Future<void> _loadDisease() async {
    try {
      final disease = await ref.read(
        diseaseByIdProvider(widget.result.label).future,
      );
      if (mounted) {
        setState(() {
          _disease = disease;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final percent = (widget.result.confidence * 100).round();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.errorContainer,
            child: Text(
              '$percent%',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_loading)
                  const Text('Загрузка...')
                else
                  Text(
                    _disease?.name ?? widget.result.label,
                    style: theme.textTheme.titleSmall,
                  ),
                if (_disease?.description != null)
                  Text(
                    _disease!.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
              ],
            ),
          ),
          if (_starting)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            FilledButton.tonal(
              onPressed: _disease == null ? null : _startTreatment,
              child: const Text('Лечить'),
            ),
        ],
      ),
    );
  }

  Future<void> _startTreatment() async {
    if (_disease == null) return;
    setState(() => _starting = true);
    try {
      final controller = ref.read(diagnosisControllerProvider);
      final userId = ref.read(currentUserIdProvider);

      final diagnosisId = await controller.startTreatment(
        diseaseId: _disease!.id,
        userId: userId,
        plantId: widget.plantId,
        imagePath: widget.imageFile.path,
        confidence: widget.result.confidence,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Лечение начато: ${_disease!.name}'),
          action: SnackBarAction(
            label: 'Открыть',
            onPressed: () => context.push('/diagnosis/treatment/$diagnosisId'),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      }
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
