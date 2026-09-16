import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/database.dart';
import '../../../../core/utils/snack_bars.dart';
import '../../../plants/presentation/providers/plant_providers.dart';
import '../providers/diagnosis_providers.dart';

class TreatmentScreen extends ConsumerWidget {
  const TreatmentScreen({super.key, required this.diagnosisId});

  final int diagnosisId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diagnosisAsync = ref.watch(diagnosisByIdProvider(diagnosisId));
    final stepsAsync = ref.watch(treatmentStepsProvider(diagnosisId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Лечение'),
        actions: [
          diagnosisAsync.maybeWhen(
            data: (d) => d == null
                ? const SizedBox.shrink()
                : PopupMenuButton<String>(
                    onSelected: (value) => _onMenuAction(context, ref, value),
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'change',
                        child: ListTile(
                          leading: Icon(Icons.swap_horiz),
                          title: Text('Изменить диагноз'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          title: Text(
                            'Удалить диагноз',
                            style: TextStyle(color: Colors.red),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: diagnosisAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Ошибка: $err')),
        data: (diagnosis) {
          if (diagnosis == null) {
            return const Center(child: Text('Диагноз не найден'));
          }
          return stepsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Ошибка: $err')),
            data: (steps) => _buildBody(context, diagnosis, steps),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    Diagnose diagnosis,
    List<TreatmentStep> steps,
  ) {
    // Делим шаги на группы. Внутри каждой сохраняем исходный порядок
    // по `stepNumber`. Первый «в процессе» — следующий шаг к выполнению.
    final pending = steps.where((s) => !s.isCompleted).toList()
      ..sort((a, b) => a.stepNumber.compareTo(b.stepNumber));
    final completed = steps.where((s) => s.isCompleted).toList()
      ..sort((a, b) => a.stepNumber.compareTo(b.stepNumber));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _StatusCard(diagnosis: diagnosis, steps: steps),
        const SizedBox(height: 16),
        Text('План лечения', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        if (steps.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Шаги лечения не заданы'),
            ),
          )
        else ...[
          _GroupHeader(
            icon: Icons.pending_actions_outlined,
            title: 'В процессе',
            count: pending.length,
          ),
          const SizedBox(height: 8),
          if (pending.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Все шаги выполнены',
                style: TextStyle(color: Colors.black54),
              ),
            )
          else
            ...pending.asMap().entries.map(
              (e) => _StepTile(
                step: e.value,
                diagnosisId: diagnosisId,
                isNext: e.key == 0,
              ),
            ),
          const SizedBox(height: 16),
          _GroupHeader(
            icon: Icons.check_circle_outline,
            title: 'Выполнено',
            count: completed.length,
          ),
          const SizedBox(height: 8),
          ...completed.map((s) => _StepTile(step: s, diagnosisId: diagnosisId)),
        ],
      ],
    );
  }

  Future<void> _onMenuAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    final router = GoRouter.of(context);

    switch (action) {
      case 'change':
        final newDiseaseId = await _showDiseasePicker(context, ref);
        if (newDiseaseId == null) return;

        // Дополнительное подтверждение.
        if (!context.mounted) return;
        final confirmed = await _confirmChange(context);
        if (confirmed != true) return;

        try {
          final userId = ref.read(currentUserIdProvider);
          await ref
              .read(diagnosisControllerProvider)
              .changeDiagnosis(
                diagnosisId: diagnosisId,
                newDiseaseId: newDiseaseId,
                userId: userId,
              );
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Диагноз изменён')));
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Не удалось изменить: $e')));
          }
        }
        break;
      case 'delete':
        final confirmed = await _confirmDelete(context);
        if (confirmed != true) return;

        try {
          await ref
              .read(diagnosisControllerProvider)
              .deleteDiagnosis(diagnosisId);
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Диагноз удалён')));
            router.pop();
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Не удалось удалить: $e')));
          }
        }
        break;
    }
  }

  Future<bool?> _confirmChange(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Изменить диагноз?'),
        content: const Text(
          'Текущий диагноз будет удалён вместе с прогрессом лечения. '
          'Новый план начнётся с первого шага.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Продолжить'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить диагноз?'),
        content: const Text(
          'Диагноз и все его шаги будут удалены. Это действие нельзя '
          'отменить. Растение останется нетронутым.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  /// Диалог выбора болезни. Возвращает id выбранной болезни или null.
  Future<String?> _showDiseasePicker(BuildContext context, WidgetRef ref) {
    return showDialog<String>(
      context: context,
      builder: (_) => const _DiseasePickerDialog(),
    );
  }
}

/// Заголовок подгруппы «В процессе» / «Выполнено» с количеством шагов.
class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.icon,
    required this.title,
    required this.count,
  });

  final IconData icon;
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.outline),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.outline,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Диалог выбора болезни с поиском.
class _DiseasePickerDialog extends ConsumerStatefulWidget {
  const _DiseasePickerDialog();

  @override
  ConsumerState<_DiseasePickerDialog> createState() =>
      _DiseasePickerDialogState();
}

class _DiseasePickerDialogState extends ConsumerState<_DiseasePickerDialog> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diseasesAsync = ref.watch(allDiseasesProvider);

    return AlertDialog(
      title: const Text('Выберите болезнь'),
      contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (v) => setState(() => _query = v.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Поиск по названию',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: diseasesAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Ошибка: $err'),
                ),
                data: (diseases) {
                  final filtered = _query.isEmpty
                      ? diseases
                      : diseases.where((d) {
                          final name = d.name.toLowerCase();
                          final desc = (d.description ?? '').toLowerCase();
                          return name.contains(_query) || desc.contains(_query);
                        }).toList();

                  if (filtered.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Ничего не найдено',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final d = filtered[i];
                      return ListTile(
                        leading: const Icon(
                          Icons.coronavirus_outlined,
                          color: Colors.redAccent,
                        ),
                        title: Text(d.name),
                        subtitle:
                            d.description != null && d.description!.isNotEmpty
                            ? Text(
                                d.description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        onTap: () => Navigator.of(context).pop(d.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.diagnosis, required this.steps});

  final Diagnose diagnosis;
  final List<TreatmentStep> steps;

  @override
  Widget build(BuildContext context) {
    final completed = steps.where((s) => s.isCompleted).length;
    final total = steps.length;
    final progress = total > 0 ? completed / total : 0.0;
    final isResolved = diagnosis.status == 'resolved';
    final theme = Theme.of(context);

    return Card(
      color: isResolved
          ? Colors.green.withValues(alpha: 0.15)
          : theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isResolved ? Icons.check_circle : Icons.healing,
                  size: 32,
                  color: isResolved
                      ? Colors.green.shade700
                      : theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isResolved ? 'Лечение завершено' : 'Лечение в процессе',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Прогресс: $completed из $total'),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepTile extends ConsumerStatefulWidget {
  const _StepTile({
    required this.step,
    required this.diagnosisId,
    this.isNext = false,
  });

  final TreatmentStep step;
  final int diagnosisId;

  /// Пометить карточку как «Следующий шаг».
  final bool isNext;

  @override
  ConsumerState<_StepTile> createState() => _StepTileState();
}

class _StepTileState extends ConsumerState<_StepTile> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    final theme = Theme.of(context);
    final isCompleted = step.isCompleted;
    final isNext = widget.isNext;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: isCompleted
              ? Colors.green.withValues(alpha: 0.15)
              : theme.colorScheme.primaryContainer,
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.green)
              : Text(
                  '${step.stepNumber}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                step.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  color: isCompleted ? theme.colorScheme.outline : null,
                ),
              ),
            ),
            if (isNext)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Следующий',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (step.description != null && step.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  step.description!,
                  style: theme.textTheme.bodySmall,
                ),
              ),
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
        trailing: _buildTrailing(context, isCompleted),
      ),
    );
  }

  Widget _buildTrailing(BuildContext context, bool isCompleted) {
    if (_busy) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (isCompleted) {
      return IconButton(
        icon: const Icon(Icons.undo),
        tooltip: 'Отменить выполнение',
        onPressed: _undo,
      );
    }

    return IconButton(
      icon: const Icon(Icons.check_circle_outline),
      tooltip: 'Отметить выполненным',
      onPressed: _complete,
    );
  }

  Future<void> _complete() async {
    setState(() => _busy = true);
    try {
      final controller = ref.read(diagnosisControllerProvider);
      await controller.completeStep(widget.step.id, widget.diagnosisId);
      if (mounted) {
        showAppSnackBar(context, 'Шаг выполнен');
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, 'Ошибка: $e');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _undo() async {
    setState(() => _busy = true);
    try {
      final controller = ref.read(diagnosisControllerProvider);
      await controller.uncompleteStep(widget.step.id, widget.diagnosisId);
      if (mounted) {
        showAppSnackBar(context, 'Выполнение отменено');
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, 'Ошибка: $e');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
