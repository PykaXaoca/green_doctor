import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/services/season_detector.dart';
import '../providers/plant_providers.dart';

/// Экран сезонного ухода для вида растения, к которому принадлежит
/// конкретное растение пользователя.
///
/// Поддерживает два формата `seasonalCareJson`:
///   1. Новый структурированный: `{ "stages": [...] }` — рисуем
///      расписание, действия и заметки нативными виджетами.
///   2. Старый markdown по 5 стадиям — рендерим как раньше,
///      `_Markdownish`.
///
/// Формат определяется автоматически по наличию ключа `stages`.
class SeasonalCareScreen extends ConsumerWidget {
  const SeasonalCareScreen({super.key, required this.plantId});

  final int plantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantAsync = ref.watch(plantByIdProvider(plantId));

    return plantAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Ошибка: $e')),
      ),
      data: (plant) {
        if (plant == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Растение не найдено')),
          );
        }
        final speciesId = plant.speciesId;
        if (speciesId == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Сезонный уход: ${plant.customName}')),
            body: const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'У растения не указан вид — сезонный уход недоступен.',
                ),
              ),
            ),
          );
        }
        final speciesAsync = ref.watch(_speciesByIdProvider(speciesId));
        return speciesAsync.when(
          loading: () => Scaffold(
            appBar: AppBar(title: const Text('Сезонный уход')),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Scaffold(
            appBar: AppBar(title: const Text('Сезонный уход')),
            body: Center(child: Text('Ошибка: $e')),
          ),
          data: (species) {
            if (species == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Сезонный уход')),
                body: const Center(child: Text('Вид не найден')),
              );
            }
            return Scaffold(
              appBar: AppBar(
                title: Text('Сезонный уход: ${species.commonName}'),
              ),
              body: _Body(species: species, plant: plant),
            );
          },
        );
      },
    );
  }
}

// =====================================================================
//  Точка входа: определяем формат и делегируем рендер
// =====================================================================

class _Body extends StatelessWidget {
  const _Body({required this.species, required this.plant});

  final PlantSpecy species;
  final Plant plant;

  @override
  Widget build(BuildContext context) {
    final raw = species.seasonalCareJson;
    if (raw == null || raw.isEmpty) {
      return const _EmptyView(
        'Сезонные рекомендации для этого вида пока не заполнены.',
      );
    }

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return const _EmptyView('Не удалось прочитать сезонные рекомендации.');
    }

    // Новый структурированный формат.
    if (json.containsKey('stages')) {
      final care = _StructuredCare.tryParse(json);
      if (care != null && care.stages.isNotEmpty) {
        return _StructuredBody(species: species, plant: plant, care: care);
      }
    }

    // Старый markdown-формат (обратная совместимость).
    return _LegacyBody(species: species, care: json);
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(child: Text(message, textAlign: TextAlign.center)),
    );
  }
}

// =====================================================================
//  НОВЫЙ ФОРМАТ — структурированный
// =====================================================================

class _StructuredBody extends StatelessWidget {
  const _StructuredBody({
    required this.species,
    required this.plant,
    required this.care,
  });

  final PlantSpecy species;
  final Plant plant;
  final _StructuredCare care;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final currentStageId = _detectCurrentStage(care.stages, now);
    final isYoung = plant.growthStage == 'young';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          species.scientificName,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (species.category != null) Chip(label: Text(species.category!)),
            Chip(
              avatar: Icon(
                species.isIndoor ? Icons.home : Icons.park,
                size: 18,
              ),
              label: Text(species.isIndoor ? 'Комнатное' : 'Садовое'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Стадии роста', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final stage in care.stages)
          _StructuredStage(
            stage: stage,
            isCurrent: !isYoung && stage.id == currentStageId,
            isYoungHighlight: isYoung && stage.id == 'spring',
          ),
      ],
    );
  }

  /// Определяет текущую стадию по месяцу/дню.
  /// Учитывает wrap-around (например, `dormant`: окт — март).
  String _detectCurrentStage(List<_StructuredStageData> stages, DateTime now) {
    final cur = now.month * 100 + now.day;
    for (final s in stages) {
      final start = s.startMonth * 100 + s.startDay;
      final end = s.endMonth * 100 + s.endDay;
      final isIn = start <= end
          ? cur >= start && cur <= end
          : cur >= start || cur <= end;
      if (isIn) return s.id;
    }
    return '';
  }
}

class _StructuredStage extends StatelessWidget {
  const _StructuredStage({
    required this.stage,
    this.isCurrent = false,
    this.isYoungHighlight = false,
  });

  final _StructuredStageData stage;
  final bool isCurrent;
  final bool isYoungHighlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isCurrent
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrent
            ? BorderSide(color: accent.withValues(alpha: 0.5), width: 1)
            : BorderSide.none,
      ),
      child: ExpansionTile(
        initiallyExpanded: isCurrent,
        title: Row(
          children: [
            Expanded(
              child: Text(
                '${_stageEmoji(stage.id)} ${stage.name}',
                style: TextStyle(
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            if (isCurrent) const _Badge(text: 'сейчас'),
            if (isYoungHighlight) const _Badge(text: 'молодое', green: true),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          if (stage.schedule.isNotEmpty) _ScheduleCard(rows: stage.schedule),
          if (stage.actions.isNotEmpty) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Действия', style: theme.textTheme.titleSmall),
            ),
            const SizedBox(height: 4),
            for (final action in stage.actions) _ActionCard(action: action),
          ],
          if (stage.notes.isNotEmpty) _NotesCard(notes: stage.notes),
        ],
      ),
    );
  }

  static String _stageEmoji(String id) {
    switch (id) {
      case 'spring':
        return '🌸';
      case 'growing':
        return '🌱';
      case 'flowering':
        return '🌼';
      case 'fruiting':
        return '🍎';
      case 'dormant':
        return '❄️';
      default:
        return '🌿';
    }
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, this.green = false});

  final String text;
  final bool green;

  @override
  Widget build(BuildContext context) {
    final color = green
        ? Colors.green.shade700
        : Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.rows});

  final List<_ScheduleRow> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(top: 4, bottom: 8),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text('Календарь работ', style: theme.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) const Divider(height: 16),
              _ScheduleRowView(row: rows[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScheduleRowView extends StatelessWidget {
  const _ScheduleRowView({required this.row});

  final _ScheduleRow row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metaParts = <String>[];
    if (row.temperature.isNotEmpty && row.temperature != '—') {
      metaParts.add(row.temperature);
    }
    if (row.phase.isNotEmpty && row.phase != '—') {
      metaParts.add(row.phase);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          row.period,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (metaParts.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            metaParts.join(' · '),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
        if (row.action.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.arrow_right_alt,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(row.action, style: theme.textTheme.bodyMedium),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action});

  final _Action action;

  @override
  Widget build(BuildContext context) {
    if (action.details.isEmpty) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: _ActionContent(action: action),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        title: _ActionContent(action: action),
        children: [
          const Divider(height: 1),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final block in action.details)
                  _DetailBlockView(block: block),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionContent extends StatelessWidget {
  const _ActionContent({required this.action});

  final _Action action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _PriorityDot(priority: action.priority),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                action.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        if (action.description.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(action.description, style: theme.textTheme.bodyMedium),
        ],
        const SizedBox(height: 8),
        _MetaRow(icon: Icons.event, label: _formatWindow(action.window)),
        if (action.recurring)
          const _MetaRow(icon: Icons.refresh, label: 'Ежегодно'),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.outline),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityDot extends StatelessWidget {
  const _PriorityDot({required this.priority});

  final String priority;

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Color _color(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (priority) {
      case 'high':
        return scheme.error;
      case 'medium':
        return Colors.amber.shade700;
      case 'low':
        return scheme.primary;
      default:
        return scheme.outline;
    }
  }
}

class _DetailBlockView extends StatelessWidget {
  const _DetailBlockView({required this.block});

  final _DetailBlock block;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    switch (block.type) {
      case 'subheading':
        return Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 4),
          child: Text(
            block.text ?? '',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      case 'bullets':
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final item in block.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•  '),
                      Expanded(
                        child: Text(item, style: theme.textTheme.bodyMedium),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      case 'paragraph':
      default:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(block.text ?? '', style: theme.textTheme.bodyMedium),
        );
    }
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.notes});

  final List<String> notes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(top: 4),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text('Тонкости', style: theme.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 8),
            for (final note in notes)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  '),
                    Expanded(
                      child: Text(note, style: theme.textTheme.bodySmall),
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

// =====================================================================
//  Модель структурированного JSON
// =====================================================================

class _StructuredCare {
  const _StructuredCare({required this.stages});

  final List<_StructuredStageData> stages;

  static _StructuredCare? tryParse(Map<String, dynamic> json) {
    final rawStages = json['stages'];
    if (rawStages is! List) return null;

    final stages = <_StructuredStageData>[];
    for (final item in rawStages) {
      if (item is! Map) continue;
      final stage = _StructuredStageData.tryParse(
        Map<String, dynamic>.from(item),
      );
      if (stage != null) stages.add(stage);
    }
    return _StructuredCare(stages: stages);
  }
}

class _StructuredStageData {
  const _StructuredStageData({
    required this.id,
    required this.name,
    required this.startMonth,
    required this.startDay,
    required this.endMonth,
    required this.endDay,
    required this.schedule,
    required this.actions,
    required this.notes,
  });

  final String id;
  final String name;
  final int startMonth;
  final int startDay;
  final int endMonth;
  final int endDay;
  final List<_ScheduleRow> schedule;
  final List<_Action> actions;
  final List<String> notes;

  static _StructuredStageData? tryParse(Map<String, dynamic> map) {
    final id = map['id'];
    final name = map['name'];
    if (id is! String || name is! String) return null;

    return _StructuredStageData(
      id: id,
      name: name,
      startMonth: (map['start_month'] as int?) ?? 1,
      startDay: (map['start_day'] as int?) ?? 1,
      endMonth: (map['end_month'] as int?) ?? 12,
      endDay: (map['end_day'] as int?) ?? 31,
      schedule: _parseSchedule(map['schedule']),
      actions: _parseActions(map['actions']),
      notes: _parseNotes(map['notes']),
    );
  }

  static List<_ScheduleRow> _parseSchedule(dynamic raw) {
    if (raw is! List) return const [];
    final result = <_ScheduleRow>[];
    for (final item in raw) {
      if (item is! Map) continue;
      result.add(
        _ScheduleRow(
          period: (item['period'] as String?) ?? '',
          temperature: (item['temperature'] as String?) ?? '',
          phase: (item['phase'] as String?) ?? '',
          action: (item['action'] as String?) ?? '',
        ),
      );
    }
    return result;
  }

  static List<_Action> _parseActions(dynamic raw) {
    if (raw is! List) return const [];
    final result = <_Action>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final action = _Action.tryParse(Map<String, dynamic>.from(item));
      if (action != null) result.add(action);
    }
    return result;
  }

  static List<String> _parseNotes(dynamic raw) {
    if (raw is! List) return const [];
    return raw.whereType<String>().toList(growable: false);
  }
}

class _ScheduleRow {
  const _ScheduleRow({
    required this.period,
    required this.temperature,
    required this.phase,
    required this.action,
  });

  final String period;
  final String temperature;
  final String phase;
  final String action;
}

class _Action {
  const _Action({
    required this.code,
    required this.title,
    required this.description,
    required this.window,
    required this.priority,
    required this.recurring,
    required this.details,
  });

  final String code;
  final String title;
  final String description;
  final _WindowDates window;
  final String priority;
  final bool recurring;
  final List<_DetailBlock> details;

  static _Action? tryParse(Map<String, dynamic> map) {
    final code = map['code'];
    final title = map['title'];
    if (code is! String || title is! String) return null;
    return _Action(
      code: code,
      title: title,
      description: (map['description'] as String?) ?? '',
      window: _WindowDates.tryParse(map['window']),
      priority: (map['priority'] as String?) ?? 'medium',
      recurring: (map['recurring'] as bool?) ?? true,
      details: _parseDetails(map['details']),
    );
  }

  static List<_DetailBlock> _parseDetails(dynamic raw) {
    if (raw is! List) return const [];
    final result = <_DetailBlock>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final type = item['type'] as String?;
      if (type == null) continue;
      result.add(
        _DetailBlock(
          type: type,
          text: item['text'] as String?,
          items:
              (item['items'] as List?)?.whereType<String>().toList(
                growable: false,
              ) ??
              const [],
        ),
      );
    }
    return result;
  }
}

class _DetailBlock {
  const _DetailBlock({required this.type, this.text, this.items = const []});

  final String type;
  final String? text;
  final List<String> items;
}

class _WindowDates {
  const _WindowDates({
    required this.startMonth,
    required this.startDay,
    required this.endMonth,
    required this.endDay,
  });

  final int startMonth;
  final int startDay;
  final int endMonth;
  final int endDay;

  static _WindowDates tryParse(dynamic raw) {
    if (raw is! Map) {
      return const _WindowDates(
        startMonth: 1,
        startDay: 1,
        endMonth: 12,
        endDay: 31,
      );
    }
    return _WindowDates(
      startMonth: (raw['start_month'] as int?) ?? 1,
      startDay: (raw['start_day'] as int?) ?? 1,
      endMonth: (raw['end_month'] as int?) ?? 12,
      endDay: (raw['end_day'] as int?) ?? 31,
    );
  }
}

String _formatWindow(_WindowDates w) {
  const months = [
    'янв',
    'фев',
    'мар',
    'апр',
    'мая',
    'июн',
    'июл',
    'авг',
    'сен',
    'окт',
    'ноя',
    'дек',
  ];
  final sm = months[(w.startMonth - 1).clamp(0, 11)];
  final em = months[(w.endMonth - 1).clamp(0, 11)];
  if (w.startMonth == w.endMonth) {
    return '${w.startDay}–${w.endDay} $sm';
  }
  return '${w.startDay} $sm — ${w.endDay} $em';
}

// =====================================================================
//  СТАРЫЙ ФОРМАТ — markdown по 5 стадиям (обратная совместимость)
// =====================================================================

class _LegacyBody extends StatelessWidget {
  const _LegacyBody({required this.species, required this.care});

  final PlantSpecy species;
  final Map<String, dynamic> care;

  static const _detector = SeasonDetector();

  @override
  Widget build(BuildContext context) {
    final currentStage = _detector.currentStage(isIndoor: species.isIndoor);

    final availableStages = SeasonDetector.allStages
        .where((s) => care[s] != null)
        .toList(growable: false);

    if (availableStages.isEmpty) {
      return const _EmptyView(
        'Сезонные рекомендации для этого вида пока не заполнены.',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          species.scientificName,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (species.category != null) Chip(label: Text(species.category!)),
            Chip(
              avatar: Icon(
                species.isIndoor ? Icons.home : Icons.park,
                size: 18,
              ),
              label: Text(species.isIndoor ? 'Комнатное' : 'Садовое'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Стадии роста', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final stage in availableStages)
          _LegacyStage(
            title: _detector.title(stage),
            text: care[stage] as String,
            isCurrent: stage == currentStage,
          ),
      ],
    );
  }
}

/// Лёгкий рендер markdown для старого формата.
class _Markdownish extends StatelessWidget {
  const _Markdownish({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (final raw in lines) {
      final line = raw.trimRight();

      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }
      if (line.startsWith('### ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              line.substring(4),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        );
        continue;
      }
      if (line.startsWith('## ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Text(
              line.substring(3),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        );
        continue;
      }
      if (line.startsWith('|')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              line,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        );
        continue;
      }
      if (line.startsWith('- ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 2, bottom: 2),
            child: Text('• ${line.substring(2)}'),
          ),
        );
        continue;
      }
      final plain = line.replaceAll('**', '');
      final isBold = line.contains('**');
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            plain,
            style: isBold ? const TextStyle(fontWeight: FontWeight.w600) : null,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}

class _LegacyStage extends StatelessWidget {
  const _LegacyStage({
    required this.title,
    required this.text,
    this.isCurrent = false,
  });

  final String title;
  final String text;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isCurrent
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrent
            ? BorderSide(color: accent.withValues(alpha: 0.5), width: 1)
            : BorderSide.none,
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            if (isCurrent) const _Badge(text: 'сейчас'),
          ],
        ),
        initiallyExpanded: isCurrent,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _Markdownish(text: text),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
//  Провайдер вида по ID — локальный для этого экрана
// =====================================================================

final _speciesByIdProvider = FutureProvider.family<PlantSpecy?, String>((
  ref,
  id,
) async {
  final repo = ref.watch(speciesRepositoryProvider);
  return repo.getById(id);
});
