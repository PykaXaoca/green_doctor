import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/models/active_diagnosis.dart';

/// Карточка одного активного диагноза растения.
///
/// Показывает:
///  * название болезни;
///  * текущую фазу лечения и прогресс;
///  * на что обращать внимание (симптомы из справочника);
///  * что изменить сейчас (описание текущего шага);
///  * кнопку перехода на экран лечения.
class DiagnosisCard extends ConsumerWidget {
  const DiagnosisCard({super.key, required this.active});

  final ActiveDiagnosis active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final symptoms = _parseSymptoms(active.disease?.symptomsJson);
    final advice = active.currentStep?.description;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок: иконка + название болезни
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.errorContainer,
                  child: Icon(
                    Icons.coronavirus_outlined,
                    size: 20,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    active.diseaseName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Текущая фаза
            _phaseRow(context),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: active.progress,
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${active.completedSteps} из ${active.totalSteps} шагов выполнено',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),

            // На что обращать внимание
            if (symptoms.isNotEmpty) ...[
              const SizedBox(height: 12),
              _block(
                context,
                icon: Icons.visibility_outlined,
                title: 'На что обращать внимание',
                items: symptoms,
              ),
            ],

            // Что изменить сейчас
            if (advice != null && advice.isNotEmpty) ...[
              const SizedBox(height: 10),
              _block(
                context,
                icon: Icons.tips_and_updates_outlined,
                title: 'Что изменить сейчас',
                items: [advice],
              ),
            ],

            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () =>
                    context.push('/diagnosis/treatment/${active.diagnosisId}'),
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Перейти к лечению'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _phaseRow(BuildContext context) {
    final theme = Theme.of(context);
    final step = active.currentStep;
    final number = active.currentStepNumber;
    final total = active.totalSteps;

    final label = total > 0 ? 'Шаг $number из $total' : '';
    final title = step?.title ?? (active.isFinished ? 'Лечение завершено' : '');

    return Row(
      children: [
        Icon(Icons.stairs_outlined, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        if (label.isNotEmpty)
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        if (title.isNotEmpty) ...[
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '— $title',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ],
    );
  }

  Widget _block(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<String> items,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.outline),
            const SizedBox(width: 6),
            Text(
              title,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.outline,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...items.map(
          (s) => Padding(
            padding: const EdgeInsets.only(left: 22, bottom: 2),
            child: Text('• $s', style: theme.textTheme.bodySmall),
          ),
        ),
      ],
    );
  }

  /// Разбирает `PlantDiseases.symptomsJson` в список строк.
  ///
  /// Поддерживает несколько форматов, чтобы не падать на неожиданных
  /// данных:
  ///  * `["симптом 1", "симптом 2"]`
  ///  * `{"items": ["симптом 1", "симптом 2"]}`
  ///  * `{"symptoms": ["симптом 1", "симптом 2"]}`
  ///  * просто строка — вернётся как один элемент.
  List<String> _parseSymptoms(String? json) {
    if (json == null || json.isEmpty) return const [];
    try {
      final decoded = jsonDecode(json);
      if (decoded is List) {
        return decoded
            .whereType<Object>()
            .map((e) => e.toString())
            .where((s) => s.isNotEmpty)
            .toList(growable: false);
      }
      if (decoded is Map) {
        final nested = decoded['items'] ?? decoded['symptoms'];
        if (nested is List) {
          return nested
              .whereType<Object>()
              .map((e) => e.toString())
              .where((s) => s.isNotEmpty)
              .toList(growable: false);
        }
      }
      return [decoded.toString()];
    } catch (_) {
      return [json];
    }
  }
}
