import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
            itemBuilder: (context, i) {
              final d = diagnoses[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.errorContainer,
                    child: Icon(
                      Icons.healing,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                  title: Text(d.diseaseId ?? 'Неизвестно'),
                  subtitle: Text(
                    'Начато ${DateFormat('d MMM yyyy', 'ru').format(d.startedAt)}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/diagnosis/treatment/${d.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
