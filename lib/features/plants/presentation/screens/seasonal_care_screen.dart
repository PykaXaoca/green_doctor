import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/services/season_detector.dart';
import '../providers/plant_providers.dart';

/// Экран сезонного ухода для вида растения, к которому принадлежит
/// конкретное растение пользователя.
class SeasonalCareScreen extends ConsumerWidget {
  const SeasonalCareScreen({super.key, required this.plantId});

  final int plantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantAsync = ref.watch(plantByIdProvider(plantId));

    return plantAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Ошибка: $e')),
      ),
      data: (plant) {
        if (plant == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Растение не найдено')),
          );
        }
        final speciesId = plant.speciesId;
        if (speciesId == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Сезонный уход: ${plant.customName}')),
            body: const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'У растения не указан вид — сезонный уход недоступен.',
                ),
              ),
            ),
          );
        }
        final speciesAsync = ref.watch(_speciesByIdProvider(speciesId));
        return speciesAsync.when(
          loading: () => Scaffold(
            appBar: AppBar(title: const Text('Сезонный уход')),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Scaffold(
            appBar: AppBar(title: const Text('Сезонный уход')),
            body: Center(child: Text('Ошибка: $e')),
          ),
          data: (species) {
            if (species == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Сезонный уход')),
                body: const Center(child: Text('Вид не найден')),
              );
            }
            return Scaffold(
              appBar: AppBar(
                title: Text('Сезонный уход: ${species.commonName}'),
              ),
              body: _Body(species: species),
            );
          },
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.species});

  final PlantSpecy species;

  static const _detector = SeasonDetector();

  @override
  Widget build(BuildContext context) {
    final raw = species.seasonalCareJson;

    if (raw == null || raw.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'Сезонные рекомендации для этого вида пока не заполнены.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final Map<String, dynamic> care;
    try {
      care = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text('Не удалось прочитать сезонные рекомендации.'),
        ),
      );
    }

    final currentStage = _detector.currentStage(isIndoor: species.isIndoor);
    final currentText = care[currentStage] as String?;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          species.scientificName,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (species.category != null) Chip(label: Text(species.category!)),
            Chip(
              avatar: Icon(
                species.isIndoor ? Icons.home : Icons.park,
                size: 18,
              ),
              label: Text(species.isIndoor ? 'Комнатное' : 'Садовое'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Сейчас: ${_detector.title(currentStage)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (currentText == null || currentText.isEmpty)
                  const Text('Для этой стадии рекомендации ещё не заполнены.')
                else
                  _Markdownish(text: currentText),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Все стадии', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final stage in SeasonDetector.allStages)
          if (care[stage] != null)
            _StageExpansion(
              title: _detector.title(stage),
              text: care[stage] as String,
              initiallyExpanded: stage == currentStage,
            ),
      ],
    );
  }
}

/// Лёгкий рендер текста: ## / ### / **жирный** / | таблицы | / - списки.
class _Markdownish extends StatelessWidget {
  const _Markdownish({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (final raw in lines) {
      final line = raw.trimRight();

      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }
      if (line.startsWith('### ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              line.substring(4),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        );
        continue;
      }
      if (line.startsWith('## ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Text(
              line.substring(3),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        );
        continue;
      }
      if (line.startsWith('|')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              line,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        );
        continue;
      }
      if (line.startsWith('- ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 2, bottom: 2),
            child: Text('• ${line.substring(2)}'),
          ),
        );
        continue;
      }
      final plain = line.replaceAll('**', '');
      final isBold = line.contains('**');
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            plain,
            style: isBold ? const TextStyle(fontWeight: FontWeight.w600) : null,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}

class _StageExpansion extends StatelessWidget {
  const _StageExpansion({
    required this.title,
    required this.text,
    this.initiallyExpanded = false,
  });

  final String title;
  final String text;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(title),
        initiallyExpanded: initiallyExpanded,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _Markdownish(text: text),
          ),
        ],
      ),
    );
  }
}

/// Провайдер вида по ID — локальный для этого экрана.
/// Если захочешь вынести в общий файл — сделай публичным в plant_providers.dart.
final _speciesByIdProvider = FutureProvider.family<PlantSpecy?, String>((
  ref,
  id,
) async {
  final repo = ref.watch(speciesRepositoryProvider);
  return repo.getById(id);
});
