import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/database.dart';

/// Карточка растения для списка.
class PlantCard extends StatelessWidget {
  const PlantCard({super.key, required this.plant, required this.onTap});

  final Plant plant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildImage(theme),
              const SizedBox(width: 12),
              Expanded(child: _buildInfo(theme)),
              Icon(Icons.chevron_right, color: theme.colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(ThemeData theme) {
    final path = plant.imagePath;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 72,
        height: 72,
        child: path != null && File(path).existsSync()
            ? Image.file(File(path), fit: BoxFit.cover)
            : Container(
                color: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.local_florist,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 36,
                ),
              ),
      ),
    );
  }

  Widget _buildInfo(ThemeData theme) {
    final next = plant.nextWaterDue;
    final nextStr = next != null
        ? DateFormat('d MMM', 'ru').format(next)
        : 'не задано';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          plant.customName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        if (plant.location != null && plant.location!.isNotEmpty)
          Text(
            plant.location!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.water_drop, size: 14, color: Colors.blue[400]),
            const SizedBox(width: 4),
            Text('Полив: $nextStr', style: theme.textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}
