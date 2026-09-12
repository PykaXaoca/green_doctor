import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/database.dart';
import '../providers/diagnosis_providers.dart';

class TreatmentScreen extends ConsumerWidget {
  const TreatmentScreen({super.key, required this.diagnosisId});

  final int diagnosisId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diagnosisAsync = ref.watch(diagnosisByIdProvider(diagnosisId));
    final stepsAsync = ref.watch(treatmentStepsProvider(diagnosisId));

    return Scaffold(
      appBar: AppBar(title: const Text('Лечение')),
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
            data: (steps) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _StatusCard(diagnosis: diagnosis, steps: steps),
                  const SizedBox(height: 16),
                  Text(
                    'План лечения',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  if (steps.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Шаги лечения не заданы'),
                      ),
                    )
                  else
                    ...steps.map(
                      (s) => _StepTile(step: s, diagnosisId: diagnosisId),
                    ),
                ],
              );
            },
          );
        },
      ),
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
  const _StepTile({required this.step, required this.diagnosisId});

  final TreatmentStep step;
  final int diagnosisId;

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
        title: Text(
          step.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? theme.colorScheme.outline : null,
          ),
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
        trailing: isCompleted
            ? null
            : _busy
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
      ),
    );
  }

  Future<void> _complete() async {
    setState(() => _busy = true);
    try {
      final controller = ref.read(diagnosisControllerProvider);
      await controller.completeStep(widget.step.id, widget.diagnosisId);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Шаг выполнен')));
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
