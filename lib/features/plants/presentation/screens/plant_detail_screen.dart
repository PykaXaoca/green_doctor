import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/utils/snack_bars.dart';
import '../providers/plant_providers.dart';
import '../widgets/health_section.dart';
import '../widgets/repotting_banner.dart';
import '../widgets/species_recommendations_card.dart';

/// Экран деталей растения.
class PlantDetailScreen extends ConsumerWidget {
  const PlantDetailScreen({super.key, required this.plantId});

  final int plantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantAsync = ref.watch(plantByIdProvider(plantId));

    return plantAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Ошибка: $err')),
      ),
      data: (plant) {
        if (plant == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Растение не найдено')),
          );
        }
        return _PlantDetailView(plant: plant);
      },
    );
  }
}

class _PlantDetailView extends ConsumerWidget {
  const _PlantDetailView({required this.plant});

  final Plant plant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(plant.customName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Редактировать',
            onPressed: () => context.push('/plants/${plant.id}/edit'),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _onMenuAction(context, ref, value),
            itemBuilder: (context) => [
              if (plant.isArchived)
                const PopupMenuItem(
                  value: 'unarchive',
                  child: ListTile(
                    leading: Icon(Icons.unarchive_outlined),
                    title: Text('Восстановить'),
                    contentPadding: EdgeInsets.zero,
                  ),
                )
              else
                const PopupMenuItem(
                  value: 'archive',
                  child: ListTile(
                    leading: Icon(Icons.archive_outlined),
                    title: Text('Архивировать'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.red),
                  title: Text('Удалить', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPhoto(),
          const SizedBox(height: 16),
          _buildTitle(),
          const SizedBox(height: 16),
          RepottingBanner(plantId: plant.id),
          _buildCareInfo(ref),
          const SizedBox(height: 16),
          _buildRecommendations(ref),
          const SizedBox(height: 16),
          HealthSection(plantId: plant.id),
          const SizedBox(height: 16),
          _buildQuickActions(context, ref),
          const SizedBox(height: 16),
          if (_hasSeedData()) ...[
            _buildSeedBlock(),
            const SizedBox(height: 16),
          ],
          _buildEventsLog(ref),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ---------- Меню ----------
  Future<void> _onMenuAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    final controller = ref.read(plantControllerProvider);
    final router = GoRouter.of(context);

    switch (action) {
      case 'archive':
        final confirmed = await _confirm(
          context,
          'Архивировать растение?',
          'Оно исчезнет из основного списка, но останется в базе.',
        );
        if (confirmed == true) {
          try {
            await controller.archive(plant.id);
            router.pop();
          } catch (e) {
            if (context.mounted) {
              showErrorSnackBar(context, 'Не удалось архивировать: $e');
            }
          }
        }
        break;
      case 'unarchive':
        try {
          await controller.unarchive(plant.id);
          if (context.mounted) {
            showAppSnackBar(context, 'Растение восстановлено');
          }
        } catch (e) {
          if (context.mounted) {
            showErrorSnackBar(context, 'Не удалось восстановить: $e');
          }
        }
        break;
      case 'delete':
        final confirmed = await _confirm(
          context,
          'Удалить растение?',
          'Это действие нельзя отменить. Все события ухода и диагностики '
              'будут удалены.',
        );
        if (confirmed == true) {
          try {
            await controller.delete(plant.id);
            router.pop();
          } catch (e) {
            if (context.mounted) {
              showErrorSnackBar(context, 'Не удалось удалить: $e');
            }
          }
        }
        break;
    }
  }

  Future<bool?> _confirm(BuildContext context, String title, String body) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Да'),
          ),
        ],
      ),
    );
  }

  // ---------- Секции ----------

  Widget _buildPhoto() {
    final path = plant.imagePath;
    final hasImage = path != null && File(path).existsSync();

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 1,
        child: hasImage
            ? Image.file(File(path), fit: BoxFit.cover)
            : Container(
                color: Colors.green.shade100,
                child: Icon(
                  Icons.local_florist,
                  size: 96,
                  color: Colors.green.shade700,
                ),
              ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                plant.customName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (plant.isArchived)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.archive_outlined,
                      size: 14,
                      color: Colors.orange.shade800,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'в архиве',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        if (plant.location != null && plant.location!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.place, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(plant.location!, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCareInfo(WidgetRef ref) {
    final speciesAsync = plant.speciesId != null
        ? ref.watch(_speciesByIdProvider(plant.speciesId!))
        : const AsyncValue<PlantSpecy?>.data(null);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Уход',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            speciesAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (species) {
                final rows = <Widget>[];

                if (species != null) {
                  rows.add(
                    _infoRow(Icons.local_florist, 'Вид', species.commonName),
                  );
                  rows.add(
                    _infoRow(Icons.science, 'Научное', species.scientificName),
                  );
                  if (species.category != null &&
                      species.category!.isNotEmpty) {
                    rows.add(
                      _infoRow(Icons.category, 'Категория', species.category!),
                    );
                  }
                }

                if (plant.wateringFrequencyDays != null) {
                  rows.add(
                    _infoRow(
                      Icons.water_drop,
                      'Полив',
                      'каждые ${plant.wateringFrequencyDays} дн.',
                    ),
                  );
                }
                if (plant.fertilizingFrequencyDays != null) {
                  final type = species?.fertilizerType;
                  rows.add(
                    _infoRow(
                      Icons.eco,
                      'Удобрение',
                      'каждые ${plant.fertilizingFrequencyDays} дн.'
                          '${type != null ? ' · $type' : ''}',
                    ),
                  );
                }
                if (plant.soilType != null && plant.soilType!.isNotEmpty) {
                  rows.add(_infoRow(Icons.grass, 'Почва', plant.soilType!));
                }
                if (plant.potSize != null && plant.potSize!.isNotEmpty) {
                  rows.add(
                    _infoRow(Icons.circle_outlined, 'Горшок', plant.potSize!),
                  );
                }

                if (species?.lightRequirements != null) {
                  rows.add(
                    _infoRow(
                      Icons.wb_sunny,
                      'Свет',
                      species!.lightRequirements!,
                    ),
                  );
                }
                if (species?.minTemperature != null &&
                    species?.maxTemperature != null) {
                  rows.add(
                    _infoRow(
                      Icons.thermostat,
                      'Температура',
                      '${species!.minTemperature}–${species.maxTemperature}°C',
                    ),
                  );
                }
                if (species?.humidityMin != null &&
                    species?.humidityMax != null) {
                  rows.add(
                    _infoRow(
                      Icons.water,
                      'Влажность воздуха',
                      '${species!.humidityMin}–${species.humidityMax}%',
                    ),
                  );
                }
                if (species?.soilMoisture != null &&
                    species!.soilMoisture!.isNotEmpty) {
                  rows.add(
                    _infoRow(
                      Icons.opacity,
                      'Влажность почвы',
                      species.soilMoisture!,
                    ),
                  );
                }
                if (species?.repottingFrequencyMonths != null) {
                  rows.add(
                    _infoRow(
                      Icons.redeem,
                      'Пересадка',
                      'каждые ${species!.repottingFrequencyMonths} мес.',
                    ),
                  );
                }
                if (species?.pruningInfo != null &&
                    species!.pruningInfo!.isNotEmpty) {
                  rows.add(
                    _infoRow(
                      Icons.content_cut,
                      'Обрезка',
                      species.pruningInfo!,
                    ),
                  );
                }
                if (species?.toxicity != null &&
                    species!.toxicity!.isNotEmpty) {
                  rows.add(
                    _infoRow(
                      Icons.warning_amber,
                      'Токсичность',
                      species.toxicity!,
                    ),
                  );
                }

                if (rows.isEmpty) {
                  return const Text(
                    'Нет данных о уходе',
                    style: TextStyle(color: Colors.grey),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: rows,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(WidgetRef ref) {
    if (plant.speciesId == null) return const SizedBox.shrink();

    final speciesAsync = ref.watch(_speciesByIdProvider(plant.speciesId!));

    return speciesAsync.maybeWhen(
      data: (species) {
        if (species == null) return const SizedBox.shrink();
        return SpeciesRecommendationsCard(species: species, readOnly: true);
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    final controller = ref.read(careActionControllerProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Быстрые действия',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    context,
                    ref,
                    controller,
                    icon: Icons.water_drop,
                    label: 'Полить',
                    type: 'watering',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _actionButton(
                    context,
                    ref,
                    controller,
                    icon: Icons.eco,
                    label: 'Удобрить',
                    type: 'fertilizing',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _actionButton(
                    context,
                    ref,
                    controller,
                    icon: Icons.spa,
                    label: 'Опрыскать',
                    type: 'misting',
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    context,
                    ref,
                    controller,
                    icon: Icons.redeem,
                    label: 'Пересадить',
                    type: 'repotting',
                    color: Colors.brown,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(
    BuildContext context,
    WidgetRef ref,
    CareActionController controller, {
    required IconData icon,
    required String label,
    required String type,
    required Color color,
  }) {
    return FilledButton.tonalIcon(
      onPressed: () async {
        try {
          await controller.perform(plantId: plant.id, type: type);
          if (context.mounted) {
            showAppSnackBar(context, '$label: готово');
          }
        } catch (e) {
          if (context.mounted) {
            showErrorSnackBar(context, 'Ошибка: $e');
          }
        }
      },
      icon: Icon(icon, color: color),
      label: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  bool _hasSeedData() {
    return (plant.seedVarietyName != null &&
            plant.seedVarietyName!.isNotEmpty) ||
        (plant.plantingLocation != null &&
            plant.plantingLocation!.isNotEmpty) ||
        plant.seedlingPlantingDate != null ||
        (plant.seedPacketImagePath != null &&
            File(plant.seedPacketImagePath!).existsSync());
  }

  Widget _buildSeedBlock() {
    final hasImage =
        plant.seedPacketImagePath != null &&
        File(plant.seedPacketImagePath!).existsSync();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.agriculture, color: Colors.brown),
                SizedBox(width: 8),
                Text(
                  'Семена и рассада',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (hasImage)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(plant.seedPacketImagePath!),
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            if (plant.seedVarietyName != null &&
                plant.seedVarietyName!.isNotEmpty)
              _infoRow(Icons.label, 'Сорт', plant.seedVarietyName!),
            if (plant.plantingLocation != null &&
                plant.plantingLocation!.isNotEmpty)
              _infoRow(Icons.place, 'Место высадки', plant.plantingLocation!),
            if (plant.seedlingPlantingDate != null)
              _infoRow(
                Icons.event,
                'Дата высадки',
                DateFormat(
                  'd MMMM yyyy',
                  'ru',
                ).format(plant.seedlingPlantingDate!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsLog(WidgetRef ref) {
    final eventsAsync = ref.watch(plantCareEventsProvider(plant.id));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history),
                SizedBox(width: 8),
                Text(
                  'Журнал событий',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            eventsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Text('Ошибка: $err'),
              data: (events) {
                if (events.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Пока нет событий. Отметьте первое действие выше.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                final recent = events.take(10).toList();
                return Column(
                  children: recent
                      .map((e) => _eventRow(e))
                      .toList(growable: false),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _eventRow(CareEvent event) {
    final (icon, color, label) = _eventMeta(event.type);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            DateFormat('d MMM, HH:mm', 'ru').format(event.performedAt),
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  (IconData, Color, String) _eventMeta(String type) {
    switch (type) {
      case 'watering':
        return (Icons.water_drop, Colors.blue, 'Полив');
      case 'fertilizing':
        return (Icons.eco, Colors.green, 'Удобрение');
      case 'misting':
        return (Icons.spa, Colors.teal, 'Опрыскивание');
      case 'repotting':
        return (Icons.redeem, Colors.brown, 'Пересадка');
      default:
        return (Icons.event, Colors.grey, type);
    }
  }
}

/// Провайдер для одного вида растения по ID.
final _speciesByIdProvider = FutureProvider.family<PlantSpecy?, String>((
  ref,
  id,
) async {
  final repo = ref.watch(speciesRepositoryProvider);
  return repo.getById(id);
});
