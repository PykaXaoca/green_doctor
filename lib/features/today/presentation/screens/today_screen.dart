import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../core/services/watering_advisor.dart';
import '../../../../core/services/weather_service.dart';
import '../../../plants/presentation/providers/plant_providers.dart';
import '../../../plants/presentation/widgets/plant_card.dart';

/// Главный экран «Сегодня» — растения, которые нужно полить.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueAsync = ref.watch(plantsDueForWateringProvider);
    final weatherAsync = ref.watch(currentWeatherProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Сегодня'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Календарь',
            onPressed: () => context.push('/today/calendar'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить',
            onPressed: () {
              ref.invalidate(plantsDueForWateringProvider);
              ref.invalidate(currentWeatherProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(plantsDueForWateringProvider);
          ref.invalidate(currentWeatherProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            WeatherHeader(weatherAsync: weatherAsync),
            const SizedBox(height: 16),
            dueAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Ошибка: $err'),
              ),
              data: (plants) {
                if (plants.isEmpty) {
                  return const _EmptyState();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, plants.length),
                    const SizedBox(height: 12),
                    ...plants.map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _TodayPlantTile(plant: p),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int count) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.water_drop,
              color: theme.colorScheme.onPrimaryContainer,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Требуют полива',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$count ${_plantWord(count)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _plantWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'растение';
    if (count % 10 >= 2 &&
        count % 10 <= 4 &&
        (count % 100 < 10 || count % 100 >= 20)) {
      return 'растения';
    }
    return 'растений';
  }
}

/// Виджет с текущей погодой.
class WeatherHeader extends StatelessWidget {
  const WeatherHeader({super.key, required this.weatherAsync});

  final AsyncValue<WeatherSnapshot?> weatherAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return weatherAsync.when(
      loading: () => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text('Загружаем погоду...', style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (weather) {
        if (weather == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.location_off, color: theme.colorScheme.outline),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Не удалось получить погоду. '
                      'Включите геолокацию и проверьте интернет.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final tomorrow = weather.tomorrow;
        final forecastStr = tomorrow == null
            ? ''
            : 'Завтра: ${tomorrow.tempMin.round()}–'
                  '${tomorrow.tempMax.round()}°C, '
                  'осадки ${(tomorrow.precipitationProbability * 100).round()}%';

        return Card(
          color: theme.colorScheme.secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  _weatherIcon(weather.currentIcon),
                  size: 40,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${weather.currentTemp.round()}°C, '
                        '${weather.currentDescription}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (forecastStr.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          forecastStr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _weatherIcon(String iconCode) {
    if (iconCode.isEmpty) return Icons.wb_cloudy;
    if (iconCode.startsWith('01')) return Icons.wb_sunny;
    if (iconCode.startsWith('02') || iconCode.startsWith('03')) {
      return Icons.wb_cloudy;
    }
    if (iconCode.startsWith('04')) return Icons.cloud;
    if (iconCode.startsWith('09') || iconCode.startsWith('10')) {
      return Icons.grain;
    }
    if (iconCode.startsWith('11')) return Icons.flash_on;
    if (iconCode.startsWith('13')) return Icons.ac_unit;
    if (iconCode.startsWith('50')) return Icons.foggy;
    return Icons.wb_cloudy;
  }
}

/// Плитка растения с быстрой кнопкой «Полить» и рекомендацией.
class _TodayPlantTile extends ConsumerWidget {
  const _TodayPlantTile({required this.plant});

  final Plant plant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduler = ref.read(careSchedulerProvider);
    final advisor = ref.read(wateringAdvisorProvider);
    final weather = ref.watch(currentWeatherProvider).asData?.value;

    final overdue = scheduler.isWateringOverdue(plant);
    final days = scheduler.daysUntilWatering(plant);
    final advice = advisor.advise(plant: plant, weather: weather);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            PlantCard(
              plant: plant,
              onTap: () => context.push('/plants/${plant.id}'),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: _WaterButton(plant: plant, overdue: overdue, days: days),
            ),
          ],
        ),
        if (advice.action != WateringAction.water)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
            child: _AdviceBanner(advice: advice),
          ),
      ],
    );
  }
}

class _AdviceBanner extends StatelessWidget {
  const _AdviceBanner({required this.advice});

  final WateringRecommendation advice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color) = switch (advice.action) {
      WateringAction.urgent => (Icons.warning_amber, Colors.orange),
      WateringAction.postpone => (Icons.schedule, Colors.blue),
      WateringAction.skip => (Icons.umbrella, Colors.teal),
      WateringAction.water => (Icons.check, Colors.green),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              advice.message,
              style: theme.textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterButton extends ConsumerStatefulWidget {
  const _WaterButton({
    required this.plant,
    required this.overdue,
    required this.days,
  });

  final Plant plant;
  final bool overdue;
  final int? days;

  @override
  ConsumerState<_WaterButton> createState() => _WaterButtonState();
}

class _WaterButtonState extends ConsumerState<_WaterButton> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.overdue ? Colors.red : theme.colorScheme.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.days != null && widget.days! < 0)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              label: Text(
                'Просрочен на ${widget.days!.abs()} дн.',
                style: const TextStyle(fontSize: 11, color: Colors.white),
              ),
              backgroundColor: color,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        FilledButton.icon(
          onPressed: _busy ? null : _water,
          icon: _busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.water_drop, size: 18),
          label: const Text('Полить'),
        ),
      ],
    );
  }

  Future<void> _water() async {
    setState(() => _busy = true);
    try {
      final controller = ref.read(careActionControllerProvider);
      await controller.perform(plantId: widget.plant.id, type: 'watering');
      ref.invalidate(plantsDueForWateringProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.plant.customName}: полив отмечен')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 72,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Все растения политы',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Сегодня ничего не требует внимания.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
