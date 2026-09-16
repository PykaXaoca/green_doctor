import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../core/services/watering_advisor.dart';
import '../../../../core/services/weather_service.dart';
import '../../../../domain/models/treatment_step_with_diagnosis.dart';
import '../../../diagnosis/presentation/providers/diagnosis_providers.dart';
import '../../../plants/presentation/providers/plant_providers.dart';
import '../../../plants/presentation/widgets/plant_card.dart';
import '../../../plants/presentation/widgets/repotting_banner.dart';
import '../providers/today_providers.dart';

/// Главный экран «Сегодня».
///
/// Показывает всё, что требует внимания сегодня (обёрнуто в секцию
/// «Планы на сегодня») и планы на завтра.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final dueAsync = ref.watch(plantsDueForWateringProvider);
    final weatherAsync = ref.watch(currentWeatherProvider);
    final repottingAsync = ref.watch(plantsNeedingRepottingProvider);
    final fertilizingAsync = ref.watch(fertilizingDueProvider);
    final mistingAsync = ref.watch(mistingDueProvider);
    final treatmentAsync = ref.watch(treatmentDueProvider);
    final tomorrowAsync = ref.watch(tomorrowPlansProvider);

    final wateringList = dueAsync.asData?.value ?? const <Plant>[];
    final fertilizingList = fertilizingAsync.asData?.value ?? const <Plant>[];
    final mistingList = mistingAsync.asData?.value ?? const <Plant>[];
    final treatmentList =
        treatmentAsync.asData?.value ?? const <TreatmentStepWithDiagnosis>[];
    final repottingList =
        repottingAsync.asData?.value ?? const <RepottingStatus>[];

    final allLoaded =
        dueAsync.hasValue &&
        fertilizingAsync.hasValue &&
        mistingAsync.hasValue &&
        treatmentAsync.hasValue &&
        repottingAsync.hasValue;

    final todayCount =
        wateringList.length +
        fertilizingList.length +
        mistingList.length +
        treatmentList.length +
        repottingList.length;

    final nothingToDo = allLoaded && todayCount == 0;

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
            onPressed: () => _invalidateAll(ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _invalidateAll(ref),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            WeatherHeader(weatherAsync: weatherAsync),
            const SizedBox(height: 20),

            // --- Секция «Планы на сегодня» ---
            _HeaderCard(
              icon: Icons.today,
              title: 'Планы на сегодня',
              subtitle: todayCount > 0
                  ? '$todayCount ${_itemWord(todayCount)}'
                  : 'Пока пусто',
              background: theme.colorScheme.primaryContainer,
              foreground: theme.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(height: 12),

            if (nothingToDo)
              const _EmptyState()
            else ...[
              // 1. Полив.
              dueAsync.when(
                loading: () => const _LoadingTile(),
                error: (err, _) => _ErrorTile(err: err),
                data: (plants) {
                  if (plants.isEmpty) return const SizedBox.shrink();
                  return _buildWateringBlock(context, plants);
                },
              ),

              // 2. Лечение.
              treatmentAsync.maybeWhen(
                data: (items) {
                  if (items.isEmpty) return const SizedBox.shrink();
                  return _buildTreatmentBlock(context, items);
                },
                orElse: () => const SizedBox.shrink(),
              ),

              // 3. Удобрение.
              fertilizingAsync.maybeWhen(
                data: (plants) {
                  if (plants.isEmpty) return const SizedBox.shrink();
                  return _buildFertilizingBlock(context, plants);
                },
                orElse: () => const SizedBox.shrink(),
              ),

              // 4. Опрыскивание.
              mistingAsync.maybeWhen(
                data: (plants) {
                  if (plants.isEmpty) return const SizedBox.shrink();
                  return _buildMistingBlock(context, plants);
                },
                orElse: () => const SizedBox.shrink(),
              ),

              // 5. Пересадка.
              repottingAsync.maybeWhen(
                data: (list) {
                  if (list.isEmpty) return const SizedBox.shrink();
                  return _buildRepottingBlock(context, list);
                },
                orElse: () => const SizedBox.shrink(),
              ),
            ],

            const SizedBox(height: 20),

            // --- Секция «Планы на завтра» ---
            tomorrowAsync.maybeWhen(
              data: (plans) => _buildTomorrowSection(context, plans),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  void _invalidateAll(WidgetRef ref) {
    ref.invalidate(plantsDueForWateringProvider);
    ref.invalidate(currentWeatherProvider);
    ref.invalidate(plantsNeedingRepottingProvider);
    ref.invalidate(fertilizingDueProvider);
    ref.invalidate(mistingDueProvider);
    ref.invalidate(treatmentDueProvider);
    ref.invalidate(tomorrowPlansProvider);
  }

  // -----------------------------------------------------------------
  //  Полив
  // -----------------------------------------------------------------

  Widget _buildWateringBlock(BuildContext context, List<Plant> plants) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SubHeader(
            icon: Icons.water_drop,
            title: 'Требуют полива',
            count: plants.length,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 8),
          ...plants.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _TodayPlantTile(plant: p),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------
  //  Лечение
  // -----------------------------------------------------------------

  Widget _buildTreatmentBlock(
    BuildContext context,
    List<TreatmentStepWithDiagnosis> items,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SubHeader(
            icon: Icons.healing,
            title: 'Лечение',
            count: items.length,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _TreatmentStepTile(item: item),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------
  //  Удобрение
  // -----------------------------------------------------------------

  Widget _buildFertilizingBlock(BuildContext context, List<Plant> plants) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SubHeader(
            icon: Icons.eco,
            title: 'Пора удобрить',
            count: plants.length,
            color: Colors.green.shade700,
          ),
          const SizedBox(height: 8),
          ...plants.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _CarePlantTile(
                plant: p,
                actionType: 'fertilizing',
                actionLabel: 'Удобрить',
                actionIcon: Icons.eco,
                actionColor: Colors.green.shade700,
                cardIcon: Icons.eco,
                cardText: p.fertilizingFrequencyDays != null
                    ? 'Удобрение: каждые ${p.fertilizingFrequencyDays} дн.'
                    : 'Удобрение',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------
  //  Опрыскивание
  // -----------------------------------------------------------------

  Widget _buildMistingBlock(BuildContext context, List<Plant> plants) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SubHeader(
            icon: Icons.spa,
            title: 'Пора опрыскать',
            count: plants.length,
            color: Colors.teal.shade700,
          ),
          const SizedBox(height: 8),
          ...plants.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _CarePlantTile(
                plant: p,
                actionType: 'misting',
                actionLabel: 'Опрыскать',
                actionIcon: Icons.spa,
                actionColor: Colors.teal.shade700,
                cardIcon: Icons.spa,
                cardText: p.mistingFrequencyDays != null
                    ? 'Опрыскивание: каждые ${p.mistingFrequencyDays} дн.'
                    : 'Опрыскивание',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------
  //  Пересадка
  // -----------------------------------------------------------------

  Widget _buildRepottingBlock(
    BuildContext context,
    List<RepottingStatus> list,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SubHeader(
            icon: Icons.redeem,
            title: 'Пора пересадить',
            count: list.length,
            color: Colors.orange.shade800,
          ),
          const SizedBox(height: 8),
          ...list.map((s) => RepottingListTile(status: s)),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------
  //  Планы на завтра
  // -----------------------------------------------------------------

  Widget _buildTomorrowSection(BuildContext context, TomorrowPlans plans) {
    final theme = Theme.of(context);

    if (plans.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderCard(
            icon: Icons.event_available,
            title: 'Планы на завтра',
            subtitle: 'Пока пусто',
            background: theme.colorScheme.tertiaryContainer,
            foreground: theme.colorScheme.onTertiaryContainer,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.event_available, color: theme.colorScheme.outline),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'На завтра дел нет',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeaderCard(
          icon: Icons.event_available,
          title: 'Планы на завтра',
          subtitle: '${plans.totalCount} ${_itemWord(plans.totalCount)}',
          background: theme.colorScheme.tertiaryContainer,
          foreground: theme.colorScheme.onTertiaryContainer,
        ),
        const SizedBox(height: 12),

        if (plans.wateringPlants.isNotEmpty) ...[
          _TomorrowSubHeader(
            icon: Icons.water_drop,
            title: 'Полив',
            count: plans.wateringPlants.length,
            color: Colors.blue.shade700,
          ),
          const SizedBox(height: 8),
          ...plans.wateringPlants.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _TomorrowItemTile(
                plant: p,
                icon: Icons.water_drop,
                iconColor: Colors.blue.shade700,
                actionText: 'Полить',
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        if (plans.treatmentSteps.isNotEmpty) ...[
          _TomorrowSubHeader(
            icon: Icons.healing,
            title: 'Лечение',
            count: plans.treatmentSteps.length,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 8),
          ...plans.treatmentSteps.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _TomorrowTreatmentTile(item: item),
            ),
          ),
          const SizedBox(height: 12),
        ],

        if (plans.fertilizingPlants.isNotEmpty) ...[
          _TomorrowSubHeader(
            icon: Icons.eco,
            title: 'Удобрение',
            count: plans.fertilizingPlants.length,
            color: Colors.green.shade700,
          ),
          const SizedBox(height: 8),
          ...plans.fertilizingPlants.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _TomorrowItemTile(
                plant: p,
                icon: Icons.eco,
                iconColor: Colors.green.shade700,
                actionText: 'Удобрить',
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        if (plans.mistingPlants.isNotEmpty) ...[
          _TomorrowSubHeader(
            icon: Icons.spa,
            title: 'Опрыскивание',
            count: plans.mistingPlants.length,
            color: Colors.teal.shade700,
          ),
          const SizedBox(height: 8),
          ...plans.mistingPlants.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _TomorrowItemTile(
                plant: p,
                icon: Icons.spa,
                iconColor: Colors.teal.shade700,
                actionText: 'Опрыскать',
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _itemWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'дело';
    if (count % 10 >= 2 &&
        count % 10 <= 4 &&
        (count % 100 < 10 || count % 100 >= 20)) {
      return 'дела';
    }
    return 'дел';
  }
}

// =========================================================================
//  Заголовок секции (крупная карточка)
// =========================================================================

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: background,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: foreground, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: foreground,
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
}

/// Подзаголовок внутри секции: иконка + название + количество.
class _SubHeader extends StatelessWidget {
  const _SubHeader({
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final String title;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _TomorrowSubHeader extends StatelessWidget {
  const _TomorrowSubHeader({
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final String title;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          '$title ($count)',
          style: theme.textTheme.labelLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// =========================================================================
//  Погода
// =========================================================================

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

        return Card(
          color: theme.colorScheme.secondaryContainer,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.push('/today/weather'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _weatherIcon(weather.currentIcon),
                        size: 44,
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
                            if (weather.apparentTemp != null)
                              Text(
                                'Ощущается как '
                                '${weather.apparentTemp!.round()}°C · '
                                'влажность ${weather.currentHumidity}%',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSecondaryContainer,
                                ),
                              )
                            else
                              Text(
                                'Влажность ${weather.currentHumidity}%',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSecondaryContainer,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniDay(label: 'Сегодня', day: weather.today),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MiniDay(label: 'Завтра', day: weather.tomorrow),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Подробнее',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MiniDay extends StatelessWidget {
  const _MiniDay({required this.label, required this.day});

  final String label;
  final DailyForecast? day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onColor = theme.colorScheme.onSecondaryContainer;

    if (day == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: onColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: onColor),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: onColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(color: onColor),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(_weatherIcon(day!.icon), size: 18, color: onColor),
              const SizedBox(width: 6),
              Text(
                '${day!.tempMin.round()}° / ${day!.tempMax.round()}°',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: onColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Осадки ${(day!.precipitationProbability * 100).round()}%',
            style: theme.textTheme.bodySmall?.copyWith(color: onColor),
          ),
        ],
      ),
    );
  }
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

// =========================================================================
//  Плитки растений
// =========================================================================

class _TodayPlantTile extends ConsumerWidget {
  const _TodayPlantTile({required this.plant});

  final Plant plant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduler = ref.read(careSchedulerProvider);
    final advisor = ref.read(wateringAdvisorProvider);
    final weather = ref.watch(currentWeatherProvider).asData?.value;

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
              child: _CareActionButton(
                plant: plant,
                type: 'watering',
                label: 'Полить',
                icon: Icons.water_drop,
                overdueDays: (days != null && days < 0) ? days : null,
              ),
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

class _CarePlantTile extends StatelessWidget {
  const _CarePlantTile({
    required this.plant,
    required this.actionType,
    required this.actionLabel,
    required this.actionIcon,
    required this.actionColor,
    required this.cardIcon,
    required this.cardText,
  });

  final Plant plant;
  final String actionType;
  final String actionLabel;
  final IconData actionIcon;
  final Color actionColor;
  final IconData cardIcon;
  final String cardText;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PlantCard(
          plant: plant,
          onTap: () => context.push('/plants/${plant.id}'),
          actionIcon: cardIcon,
          actionColor: actionColor,
          actionText: cardText,
        ),
        Positioned(
          right: 8,
          bottom: 8,
          child: _CareActionButton(
            plant: plant,
            type: actionType,
            label: actionLabel,
            icon: actionIcon,
          ),
        ),
      ],
    );
  }
}

class _TomorrowItemTile extends StatelessWidget {
  const _TomorrowItemTile({
    required this.plant,
    required this.icon,
    required this.iconColor,
    required this.actionText,
  });

  final Plant plant;
  final IconData icon;
  final Color iconColor;
  final String actionText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: iconColor.withValues(alpha: 0.15),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        title: Text(
          plant.customName,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          actionText,
          style: theme.textTheme.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/plants/${plant.id}'),
      ),
    );
  }
}

class _TomorrowTreatmentTile extends ConsumerWidget {
  const _TomorrowTreatmentTile({required this.item});

  final TreatmentStepWithDiagnosis item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final step = item.step;
    final diagnosis = item.diagnosis;
    final plantId = diagnosis.plantId;

    final plantAsync = plantId != null
        ? ref.watch(plantByIdProvider(plantId))
        : const AsyncValue<Plant?>.data(null);
    final plantName =
        plantAsync.asData?.value?.customName ??
        (plantId != null ? 'Растение #$plantId' : 'Без растения');

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: theme.colorScheme.errorContainer,
          child: Icon(
            Icons.coronavirus_outlined,
            size: 18,
            color: theme.colorScheme.onErrorContainer,
          ),
        ),
        title: Text(
          step.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '$plantName · ${diagnosis.diseaseId ?? ''}',
          style: theme.textTheme.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/diagnosis/treatment/${diagnosis.id}'),
      ),
    );
  }
}

class _TreatmentStepTile extends ConsumerStatefulWidget {
  const _TreatmentStepTile({required this.item});

  final TreatmentStepWithDiagnosis item;

  @override
  ConsumerState<_TreatmentStepTile> createState() => _TreatmentStepTileState();
}

class _TreatmentStepTileState extends ConsumerState<_TreatmentStepTile> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final step = widget.item.step;
    final diagnosis = widget.item.diagnosis;
    final plantId = diagnosis.plantId;

    final plantAsync = plantId != null
        ? ref.watch(plantByIdProvider(plantId))
        : const AsyncValue<Plant?>.data(null);
    final plantName =
        plantAsync.asData?.value?.customName ??
        (plantId != null ? 'Растение #$plantId' : 'Без растения');

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.errorContainer,
          child: Icon(
            Icons.coronavirus_outlined,
            size: 20,
            color: theme.colorScheme.onErrorContainer,
          ),
        ),
        title: Text(
          step.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('$plantName · ${diagnosis.diseaseId ?? ''}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.event, size: 14, color: theme.colorScheme.outline),
                const SizedBox(width: 4),
                Text(
                  'До ${DateFormat('d MMM yyyy', 'ru').format(step.dueAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: _busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : IconButton(
                icon: const Icon(Icons.check_circle_outline),
                tooltip: 'Отметить выполненным',
                onPressed: _complete,
              ),
        onTap: () => context.push('/diagnosis/treatment/${diagnosis.id}'),
      ),
    );
  }

  Future<void> _complete() async {
    setState(() => _busy = true);
    try {
      final controller = ref.read(diagnosisControllerProvider);
      await controller.completeStep(
        widget.item.step.id,
        widget.item.diagnosis.id,
      );
      ref.invalidate(treatmentDueProvider);
      ref.invalidate(tomorrowPlansProvider);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Шаг лечения выполнен')));
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

class _CareActionButton extends ConsumerStatefulWidget {
  const _CareActionButton({
    required this.plant,
    required this.type,
    required this.label,
    required this.icon,
    this.overdueDays,
  });

  final Plant plant;
  final String type;
  final String label;
  final IconData icon;
  final int? overdueDays;

  @override
  ConsumerState<_CareActionButton> createState() => _CareActionButtonState();
}

class _CareActionButtonState extends ConsumerState<_CareActionButton> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overdue = widget.overdueDays != null && widget.overdueDays! < 0;
    final chipColor = overdue ? Colors.red : theme.colorScheme.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (overdue)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              label: Text(
                'Просрочен на ${widget.overdueDays!.abs()} дн.',
                style: const TextStyle(fontSize: 11, color: Colors.white),
              ),
              backgroundColor: chipColor,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        FilledButton.icon(
          onPressed: _busy ? null : _perform,
          icon: _busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(widget.icon, size: 18),
          label: Text(widget.label),
        ),
      ],
    );
  }

  Future<void> _perform() async {
    setState(() => _busy = true);
    try {
      final controller = ref.read(careActionControllerProvider);
      await controller.perform(plantId: widget.plant.id, type: widget.type);

      ref.invalidate(plantsDueForWateringProvider);
      ref.invalidate(fertilizingDueProvider);
      ref.invalidate(mistingDueProvider);
      ref.invalidate(tomorrowPlansProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.plant.customName}: ${widget.label.toLowerCase()} отмечено',
            ),
          ),
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

class _LoadingTile extends StatelessWidget {
  const _LoadingTile();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorTile extends StatelessWidget {
  const _ErrorTile({required this.err});

  final Object err;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text('Ошибка: $err'),
    );
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
              'Все дела на сегодня закрыты',
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
