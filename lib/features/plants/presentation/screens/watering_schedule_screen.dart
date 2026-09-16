import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/database.dart';
import '../providers/watering_schedule_providers.dart';

/// Экран «Расписание полива» — просмотр на 14 дней вперёд.
class WateringScheduleScreen extends ConsumerWidget {
  const WateringScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(wateringScheduleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Расписание полива'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить',
            onPressed: () => ref.invalidate(wateringScheduleProvider),
          ),
        ],
      ),
      body: scheduleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Ошибка: $err')),
        data: (data) {
          if (data.isEmpty) {
            return const _EmptyView();
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(wateringScheduleProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (data.overdue.isNotEmpty) ...[
                  _OverdueCard(plants: data.overdue),
                  const SizedBox(height: 16),
                ],
                Text(
                  'Ближайшие $kScheduleDaysAhead дней',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                for (final day in data.days)
                  _DayCard(date: day, plants: data.byDay[day] ?? const []),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Карточка одного дня.
class _DayCard extends StatelessWidget {
  const _DayCard({required this.date, required this.plants});

  final DateTime date;
  final List<Plant> plants;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isToday = _sameDay(date, DateTime.now());

    if (plants.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.4,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Text(
                  _dayLabel(date),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const Spacer(),
                Text('—', style: TextStyle(color: theme.colorScheme.outline)),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        color: isToday
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _dayLabel(date),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isToday ? theme.colorScheme.primary : null,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${plants.length}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ...plants.map(
                (p) => InkWell(
                  onTap: () => context.push('/plants/${p.id}'),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 4,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_florist,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            p.customName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: theme.colorScheme.outline,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Красная карточка для просроченных.
class _OverdueCard extends StatelessWidget {
  const _OverdueCard({required this.plants});

  final List<Plant> plants;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.red.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Text(
                  'Просрочено (${plants.length})',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.red.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Эти растения нужно полить как можно скорее',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            ...plants.map(
              (p) => InkWell(
                onTap: () => context.push('/plants/${p.id}'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.water_drop, size: 14, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(child: Text(p.customName)),
                      if (p.nextWaterDue != null)
                        Text(
                          DateFormat('d MMM', 'ru').format(p.nextWaterDue!),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.red.shade700,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 72,
              color: theme.colorScheme.outline.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Пока нечего планировать',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Добавьте растения с указанной частотой полива — '
              'и расписание появится здесь',
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

// ---------- Вспомогательные ----------

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _dayLabel(DateTime date) {
  final now = DateTime.now();
  if (_sameDay(date, now)) return 'Сегодня';
  final tomorrow = now.add(const Duration(days: 1));
  if (_sameDay(date, tomorrow)) return 'Завтра';
  return DateFormat('EEEE, d MMMM', 'ru').format(date);
}
