import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../plants/presentation/providers/plant_providers.dart';
import '../../../plants/presentation/providers/watering_optimizer.dart';
import '../providers/care_schedule_providers.dart';

/// Экран настроек дачного графика полива.
class CareScheduleSettingsScreen extends ConsumerStatefulWidget {
  const CareScheduleSettingsScreen({super.key});

  @override
  ConsumerState<CareScheduleSettingsScreen> createState() =>
      _CareScheduleSettingsScreenState();
}

class _CareScheduleSettingsScreenState
    extends ConsumerState<CareScheduleSettingsScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(careScheduleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Режим дачника'),
        actions: [
          configAsync.maybeWhen(
            data: (config) => config.mode != CareScheduleMode.free
                ? IconButton(
                    icon: const Icon(Icons.restart_alt),
                    tooltip: 'Сбросить расписание',
                    onPressed: _busy ? null : _confirmReset,
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: configAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Ошибка: $err')),
        data: (config) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _IntroCard(),
            const SizedBox(height: 16),
            _ModeCard(config: config, onModeSelected: _onModeSelected),
            const SizedBox(height: 16),
            if (config.mode == CareScheduleMode.interval) ...[
              _IntervalCard(config: config),
              const SizedBox(height: 16),
            ],
            if (config.mode == CareScheduleMode.weekdays) ...[
              _WeekdaysCard(config: config),
              const SizedBox(height: 16),
            ],
            if (config.mode != CareScheduleMode.free) ...[
              const _OptimizeSection(),
            ],
          ],
        ),
      ),
    );
  }

  /// Смена режима — сохраняем, потом сразу предлагаем применить.
  Future<void> _onModeSelected(CareScheduleMode mode) async {
    await ref.read(careScheduleProvider.notifier).setMode(mode);

    if (mode == CareScheduleMode.free) return;
    if (!mounted) return;

    // Даём провайдеру пересчитаться.
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    final plan = await ref.read(wateringOptimizationPlanProvider.future);
    if (!mounted) return;
    if (plan == null) return;

    if (plan.changes.isEmpty && plan.cannotFit.isEmpty) {
      _showSnack('Все растения уже поливаются в этот день.');
      return;
    }

    if (plan.changes.isEmpty) {
      _showSnack(
        'Пока нечего переносить — ${plan.cannotFit.length} растений '
        'требуют отдельного полива.',
      );
      return;
    }

    final applied = await showDialog<bool>(
      context: context,
      builder: (_) => _OptimizationPreviewDialog(plan: plan),
    );

    if (applied == true) {
      await _applyPlan(plan);
    }
  }

  Future<void> _applyPlan(WateringOptimizationPlan plan) async {
    setState(() => _busy = true);
    try {
      final controller = ref.read(plantControllerProvider);
      await controller.applyScheduleChanges(
        plan.changes
            .map((c) => (plantId: c.plant.id, newDate: c.newDate))
            .toList(),
      );

      ref.invalidate(wateringOptimizationPlanProvider);

      if (!mounted) return;
      final total = plan.totalPlants;
      final moved = plan.changes.length;
      final fit = plan.willFitCount;
      _showSnack(
        'Готово: перенесено $moved. Теперь $fit из $total растений '
        'попадают в дни поездок.',
      );
    } catch (e) {
      if (!mounted) return;
      _showSnack('Ошибка: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Сбросить расписание?'),
        content: const Text(
          'Все растения вернутся к своим естественным датам полива: '
          'nextWaterDue = последний полив + частота. Оптимизация '
          'под дачный режим будет отменена, режим сброшен.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      final controller = ref.read(plantControllerProvider);
      final changed = await controller.resetWateringSchedule();

      await ref.read(careScheduleProvider.notifier).reset();
      ref.invalidate(wateringOptimizationPlanProvider);

      if (!mounted) return;
      _showSnack('Расписание сброшено. Обновлено растений: $changed.');
    } catch (e) {
      if (!mounted) return;
      _showSnack('Ошибка: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

// ============================================================================
//  Секция оптимизации
// ============================================================================

class _OptimizeSection extends ConsumerStatefulWidget {
  const _OptimizeSection();

  @override
  ConsumerState<_OptimizeSection> createState() => _OptimizeSectionState();
}

class _OptimizeSectionState extends ConsumerState<_OptimizeSection> {
  bool _applying = false;

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(wateringOptimizationPlanProvider);
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_fix_high, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Оптимизация',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'План строится от естественных дат полива — '
              'nextWaterDue = последний полив + частота. Сколько раз '
              'ни применяй, результат одинаковый.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            planAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Text('Ошибка: $err'),
              data: (plan) => _buildBody(context, plan),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WateringOptimizationPlan? plan) {
    final theme = Theme.of(context);

    if (plan == null) {
      return const Text('Выберите режим, чтобы увидеть план.');
    }

    if (plan.totalPlants == 0) {
      return const Text('Пока нет растений для оптимизации.');
    }

    if (plan.isEmpty) {
      return Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Расписание уже оптимально: все растения попадают в дни '
              'поездок.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      );
    }

    final fitNow = plan.alreadyFitCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Сейчас $fitNow из ${plan.totalPlants} растений '
                  'попадают в дни поездок. После применения будет '
                  '${plan.willFitCount}.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        if (plan.changes.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            'Можно перенести: ${plan.changes.length}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (plan.cannotFit.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Не дотянет до поездки: ${plan.cannotFit.length}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.orange.shade800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Эти растения придётся полить отдельно.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _applying || !plan.hasChanges
              ? null
              : () => _showPreviewDialog(plan),
          icon: _applying
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.auto_fix_high),
          label: Text(
            plan.hasChanges
                ? 'Применить оптимизацию (${plan.changes.length})'
                : 'Нет изменений',
          ),
        ),
      ],
    );
  }

  Future<void> _showPreviewDialog(WateringOptimizationPlan plan) async {
    final applied = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _OptimizationPreviewDialog(plan: plan),
    );

    if (applied != true) return;
    if (!mounted) return;

    setState(() => _applying = true);
    try {
      final controller = ref.read(plantControllerProvider);
      await controller.applyScheduleChanges(
        plan.changes
            .map((c) => (plantId: c.plant.id, newDate: c.newDate))
            .toList(),
      );

      ref.invalidate(wateringOptimizationPlanProvider);

      if (!mounted) return;
      final total = plan.totalPlants;
      final moved = plan.changes.length;
      final fit = plan.willFitCount;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Готово: перенесено $moved. Теперь $fit из $total растений '
            'попадают в дни поездок.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }
}

// ============================================================================
//  Диалог превью
// ============================================================================

class _OptimizationPreviewDialog extends StatelessWidget {
  const _OptimizationPreviewDialog({required this.plan});

  final WateringOptimizationPlan plan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('План оптимизации'),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            if (plan.changes.isNotEmpty) ...[
              Text(
                'Переносы (${plan.changes.length})',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              ...plan.changes.map((c) => _ChangeTile(change: c)),
            ],
            if (plan.cannotFit.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Не дотянет до поездки (${plan.cannotFit.length})',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.orange.shade800,
                ),
              ),
              const SizedBox(height: 8),
              ...plan.cannotFit.map((c) => _CannotFitTile(item: c)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Применить'),
        ),
      ],
    );
  }
}

class _ChangeTile extends StatelessWidget {
  const _ChangeTile({required this.change});

  final WateringOptimizationChange change;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final forward = change.isForward;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            forward ? Icons.arrow_forward : Icons.arrow_back,
            size: 18,
            color: forward ? Colors.green.shade600 : Colors.blue.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  change.plant.customName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${DateFormat('d MMM', 'ru').format(change.oldDate)}'
                  ' → '
                  '${DateFormat('d MMM', 'ru').format(change.newDate)}'
                  '  (${forward ? '+' : ''}${change.shiftDays} дн.)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CannotFitTile extends StatelessWidget {
  const _CannotFitTile({required this.item});

  final CannotFit item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber, size: 18, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.plant.customName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.reason.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
//  Прочие секции
// ============================================================================

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Если вы ездите на дачу не каждый день',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Выберите режим — приложение сразу предложит '
                    'перестроить расписание так, чтобы все растения '
                    'нужно было полить в день вашей поездки.',
                    style: theme.textTheme.bodySmall,
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

class _ModeCard extends ConsumerWidget {
  const _ModeCard({required this.config, required this.onModeSelected});

  final CareScheduleConfig config;
  final Future<void> Function(CareScheduleMode) onModeSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Режим', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...CareScheduleMode.values.map((mode) {
              final selected = mode == config.mode;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
                title: Text(mode.label),
                subtitle: Text(mode.description),
                onTap: () => onModeSelected(mode),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _IntervalCard extends ConsumerWidget {
  const _IntervalCard({required this.config});

  final CareScheduleConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final days = config.intervalDays;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Интервал между поездками',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Раз в $days ${_daysWord(days)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: days > 1
                      ? () => ref
                            .read(careScheduleProvider.notifier)
                            .setIntervalDays(days - 1)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Expanded(
                  child: Slider(
                    value: days.toDouble(),
                    min: 1,
                    max: 14,
                    divisions: 13,
                    label: '$days',
                    onChanged: (v) => ref
                        .read(careScheduleProvider.notifier)
                        .setIntervalDays(v.round()),
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: days < 14
                      ? () => ref
                            .read(careScheduleProvider.notifier)
                            .setIntervalDays(days + 1)
                      : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [1, 2, 3, 5, 7, 10, 14].map((preset) {
                final selected = preset == days;
                return ChoiceChip(
                  label: Text('$preset'),
                  selected: selected,
                  onSelected: (_) => ref
                      .read(careScheduleProvider.notifier)
                      .setIntervalDays(preset),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _daysWord(int n) {
    if (n % 10 == 1 && n % 100 != 11) return 'день';
    if (n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20)) {
      return 'дня';
    }
    return 'дней';
  }
}

class _WeekdaysCard extends ConsumerWidget {
  const _WeekdaysCard({required this.config});

  final CareScheduleConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Дни поездок', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Выберите дни, когда вы обычно бываете на даче',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kWeekdayNames.entries.map((e) {
                final selected = config.weekdays.contains(e.key);
                return FilterChip(
                  label: Text(e.value),
                  selected: selected,
                  onSelected: (_) => ref
                      .read(careScheduleProvider.notifier)
                      .toggleWeekday(e.key),
                );
              }).toList(),
            ),
            if (config.weekdays.length <= 1) ...[
              const SizedBox(height: 8),
              Text(
                'Должен быть выбран хотя бы один день',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
