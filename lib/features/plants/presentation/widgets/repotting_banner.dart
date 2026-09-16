import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/plant_providers.dart';

/// Баннер «Пора пересадить» для карточки растения.
class RepottingBanner extends ConsumerWidget {
  const RepottingBanner({super.key, required this.plantId});

  final int plantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(repottingStatusForPlantProvider(plantId));

    return statusAsync.maybeWhen(
      data: (status) {
        if (status == null) return const SizedBox.shrink();
        return _BannerContent(status: status);
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _BannerContent extends ConsumerStatefulWidget {
  const _BannerContent({required this.status});

  final RepottingStatus status;

  @override
  ConsumerState<_BannerContent> createState() => _BannerContentState();
}

class _BannerContentState extends ConsumerState<_BannerContent> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = widget.status;
    final overdue = status.isOverdue;

    final color = overdue ? Colors.red.shade600 : Colors.orange.shade700;
    final bgColor = overdue ? Colors.red.shade50 : Colors.orange.shade50;
    final borderColor = overdue ? Colors.red.shade200 : Colors.orange.shade200;

    final title = overdue ? 'Пора пересаживать' : 'Скоро пересадка';
    final subtitle = overdue
        ? 'Просрочено на ${status.monthsUntilDue.abs()} мес.'
        : 'В течение ${status.monthsUntilDue} мес.';

    return Card(
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.redeem, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(color: color),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Рекомендуется раз в '
                    '${status.repottingFrequencyMonths} мес.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            if (_busy)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              IconButton(
                icon: const Icon(Icons.check_circle_outline),
                tooltip: 'Отметить пересадку',
                color: color,
                onPressed: _markRepotted,
              ),
          ],
        ),
      ),
    );
  }

  /// Отметить пересадку — создаёт событие ухода `repotting`.
  ///
  /// После этого `lastRepottedAt` растения обновляется, и баннер
  /// исчезает: `plantsNeedingRepottingProvider` пересчитает статус
  /// от новой даты.
  Future<void> _markRepotted() async {
    setState(() => _busy = true);
    try {
      final controller = ref.read(careActionControllerProvider);
      await controller.perform(
        plantId: widget.status.plant.id,
        type: 'repotting',
      );
      // Провайдеры инвалидируются в контроллере.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.status.plant.customName}: пересадка отмечена',
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

/// Компактная карточка для списка «Сегодня».
class RepottingListTile extends ConsumerWidget {
  const RepottingListTile({super.key, required this.status});

  final RepottingStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final overdue = status.isOverdue;
    final color = overdue ? Colors.red.shade600 : Colors.orange.shade700;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(Icons.redeem, color: color),
        ),
        title: Text(status.plant.customName),
        subtitle: Text(
          overdue
              ? 'Просрочено на ${status.monthsUntilDue.abs()} мес.'
              : 'Пересадка в течение ${status.monthsUntilDue} мес.',
          style: theme.textTheme.bodySmall?.copyWith(color: color),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/plants/${status.plant.id}'),
      ),
    );
  }
}
