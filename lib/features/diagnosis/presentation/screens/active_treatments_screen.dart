import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/database.dart';
import '../providers/diagnosis_providers.dart';

/// Список активных лечений.
class ActiveTreatmentsScreen extends ConsumerWidget {
  const ActiveTreatmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diagnosesAsync = ref.watch(activeDiagnosesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Активные лечения')),
      body: diagnosesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Ошибка: $err')),
        data: (diagnoses) {
          if (diagnoses.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.healing_outlined,
                      size: 96,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Активных лечений нет',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Все растения здоровы',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: diagnoses.length,
            itemBuilder: (context, i) =>
                _DiagnosisTile(diagnosis: diagnoses[i]),
          );
        },
      ),
    );
  }
}

class _DiagnosisTile extends ConsumerWidget {
  const _DiagnosisTile({required this.diagnosis});

  final Diagnose diagnosis;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diseaseAsync = diagnosis.diseaseId == null
        ? const AsyncValue<PlantDisease?>.data(null)
        : ref.watch(diseaseByIdProvider(diagnosis.diseaseId!));

    final disease = diseaseAsync.value;
    final name = disease?.name ?? diagnosis.diseaseId ?? 'Неизвестно';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          child: Icon(
            Icons.healing,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
        title: Text(name),
        subtitle: Text(
          'Начато ${DateFormat('d MMM yyyy', 'ru').format(diagnosis.startedAt)}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/diagnosis/treatment/${diagnosis.id}'),
      ),
    );
  }
}
