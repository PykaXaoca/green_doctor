import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/services/plant_identifier_service.dart';
import '../../../plants/presentation/providers/plant_providers.dart';
import '../providers/identification_providers.dart';

/// Экран «Определить» — распознавание растения по фото.
class IdentifyScreen extends ConsumerStatefulWidget {
  const IdentifyScreen({super.key});

  @override
  ConsumerState<IdentifyScreen> createState() => _IdentifyScreenState();
}

class _IdentifyScreenState extends ConsumerState<IdentifyScreen> {
  final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(identifyProvider);
    final service = ref.watch(plantIdentifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Определить'),
        actions: [
          if (state.imageFile != null)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Очистить',
              onPressed: () => ref.read(identifyProvider.notifier).clear(),
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
            const Center(child: Text('Распознаём...')),
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

  Widget _buildImageArea(IdentifyState state) {
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
                Icons.camera_alt_outlined,
                size: 72,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 12),
              Text(
                'Сфотографируйте растение\nили выберите из галереи',
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

  Widget _buildActionButtons(IdentifyState state) {
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

  Widget _buildResults(IdentifyState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Результаты', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...state.results.map(
              (r) => _ResultTile(result: r, imageFile: state.imageFile),
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
          .read(identifyProvider.notifier)
          .setImageAndIdentify(File(picked.path));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      }
    }
  }
}

/// Баннер mock-режима.
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
                'Демо-режим. Реальная модель не подключена. '
                'Результаты случайные. Обучите модель через ml/.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Плитка результата с кнопкой «Добавить растение».
class _ResultTile extends ConsumerStatefulWidget {
  const _ResultTile({required this.result, required this.imageFile});

  final RecognitionResult result;
  final File? imageFile;

  @override
  ConsumerState<_ResultTile> createState() => _ResultTileState();
}

class _ResultTileState extends ConsumerState<_ResultTile> {
  PlantSpecy? _species;
  bool _loading = true;
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    _loadSpecies();
  }

  Future<void> _loadSpecies() async {
    try {
      final repo = ref.read(speciesRepositoryProvider);
      final species = await repo.getById(widget.result.label);
      if (mounted) {
        setState(() {
          _species = species;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final confidence = widget.result.confidence;
    final percent = (confidence * 100).round();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              '$percent%',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onPrimaryContainer,
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
                    _species?.commonName ?? widget.result.label,
                    style: theme.textTheme.titleSmall,
                  ),
                if (_species != null)
                  Text(
                    _species!.scientificName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.outline,
                    ),
                  ),
              ],
            ),
          ),
          if (_adding)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            FilledButton.tonal(
              onPressed: _species == null ? null : _addAsPlant,
              child: const Text('Добавить'),
            ),
        ],
      ),
    );
  }

  Future<void> _addAsPlant() async {
    if (_species == null) return;
    setState(() => _adding = true);
    try {
      final controller = ref.read(plantControllerProvider);
      final userId = ref.read(currentUserIdProvider);
      final imageStorage = ref.read(imageStorageServiceProvider);

      // Сохраняем фото, по которому было распознано растение,
      // в постоянную папку приложения.
      String? savedImagePath;
      final src = widget.imageFile;
      if (src != null && src.existsSync()) {
        try {
          savedImagePath = await imageStorage.saveImage(src, prefix: 'plant');
        } catch (_) {
          // Если не удалось сохранить фото — не блокируем добавление.
          savedImagePath = null;
        }
      }

      final id = await controller.create(
        PlantsCompanion(
          userId: Value(userId),
          customName: Value(_species!.commonName),
          speciesId: Value(_species!.id),
          imagePath: Value(savedImagePath),
          wateringFrequencyDays: Value(_species!.defaultWateringDays),
          fertilizingFrequencyDays: const Value(30),
          soilType: Value(_species!.soilType),
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_species!.commonName} добавлено в коллекцию'),
          action: SnackBarAction(
            label: 'Открыть',
            onPressed: () => context.push('/plants/$id'),
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
      if (mounted) setState(() => _adding = false);
    }
  }
}

/// Блок ошибки.
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
