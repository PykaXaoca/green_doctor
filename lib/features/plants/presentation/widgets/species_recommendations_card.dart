import 'package:flutter/material.dart';

import '../../../../core/database/database.dart';

/// Карточка с полным набором рекомендаций по виду растения.
///
/// Режимы:
///  * **форма** (`readOnly == false`) — карточка с кнопкой
///    «Применить к форме», которая заполняет поля полива, удобрения
///    и почвы. Используется в [PlantFormScreen].
///  * **просмотр** (`readOnly == true`) — нейтральная карточка без
///    кнопки. Используется в карточке растения.
class SpeciesRecommendationsCard extends StatelessWidget {
  const SpeciesRecommendationsCard({
    super.key,
    required this.species,
    this.onApply,
    this.readOnly = false,
    this.title,
  });

  final PlantSpecy species;
  final VoidCallback? onApply;
  final bool readOnly;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bg = readOnly
        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
        : theme.colorScheme.primaryContainer.withValues(alpha: 0.35);

    return Card(
      color: bg,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  readOnly
                      ? Icons.menu_book_outlined
                      : Icons.tips_and_updates_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title ??
                        (readOnly
                            ? 'Рекомендации по уходу'
                            : 'Рекомендации для вида'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              species.commonName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            if (species.category != null && species.category!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Chip(
                label: Text(species.category!),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
            const SizedBox(height: 12),

            if (species.defaultWateringDays != null)
              _row(
                context,
                Icons.water_drop,
                Colors.blue,
                'Полив',
                'каждые ${species.defaultWateringDays} дн.',
              ),

            if (species.fertilizingFrequencyDays != null)
              _row(
                context,
                Icons.eco,
                Colors.green,
                'Удобрение',
                'каждые ${species.fertilizingFrequencyDays} дн.'
                    '${species.fertilizerType != null ? ' · ${species.fertilizerType}' : ''}',
              ),

            if (species.lightRequirements != null &&
                species.lightRequirements!.isNotEmpty)
              _row(
                context,
                Icons.wb_sunny,
                Colors.orange,
                'Свет',
                species.lightRequirements!,
              ),

            if (species.minTemperature != null &&
                species.maxTemperature != null)
              _row(
                context,
                Icons.thermostat,
                Colors.redAccent,
                'Температура',
                '${species.minTemperature}–${species.maxTemperature}°C',
              ),

            if (species.humidityMin != null && species.humidityMax != null)
              _row(
                context,
                Icons.water,
                Colors.lightBlue,
                'Влажность воздуха',
                '${species.humidityMin}–${species.humidityMax}%',
              ),

            if (species.soilType != null && species.soilType!.isNotEmpty)
              _row(
                context,
                Icons.grass,
                Colors.brown,
                'Почва',
                species.soilType!,
              ),

            if (species.soilMoisture != null &&
                species.soilMoisture!.isNotEmpty)
              _row(
                context,
                Icons.opacity,
                Colors.teal,
                'Влажность почвы',
                species.soilMoisture!,
              ),

            if (species.repottingFrequencyMonths != null)
              _row(
                context,
                Icons.redeem,
                Colors.purple,
                'Пересадка',
                'каждые ${species.repottingFrequencyMonths} мес.',
              ),

            if (species.pruningInfo != null && species.pruningInfo!.isNotEmpty)
              _row(
                context,
                Icons.content_cut,
                Colors.deepPurple,
                'Обрезка',
                species.pruningInfo!,
              ),

            if (species.toxicity != null && species.toxicity!.isNotEmpty)
              _row(
                context,
                Icons.warning_amber,
                Colors.amber.shade800,
                'Токсичность',
                species.toxicity!,
              ),

            if (!readOnly && onApply != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: onApply,
                  icon: const Icon(Icons.download_done),
                  label: const Text('Применить к форме'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    IconData icon,
    Color color,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
