import 'package:flutter/material.dart';

import '../../../../core/services/symptom_matcher.dart';

/// Карточка одного результата матчинга.
class SymptomMatchCard extends StatelessWidget {
  const SymptomMatchCard({super.key, required this.match, required this.onTap});

  final SymptomMatch match;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final d = match.disease;
    final percent = match.percent;

    // Цвет процента: высокий — зелёный, средний — жёлтый, низкий — серый.
    final scoreColor = percent >= 60
        ? Colors.green.shade700
        : percent >= 35
        ? Colors.orange.shade700
        : theme.colorScheme.outline;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      d.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: scoreColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: scoreColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      '$percent%',
                      style: TextStyle(
                        color: scoreColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              if (d.description != null && d.description!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  d.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 6),
              // Совпавшие токены — чтобы пользователь видел, почему
              // болезнь попалась в список.
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: match.matchedTokens.take(6).map((t) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      t,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
