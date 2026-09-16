import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../diagnosis/presentation/providers/diagnosis_providers.dart';
import '../../../plants/presentation/providers/plant_providers.dart';
import '../providers/calendar_providers.dart';
import '../widgets/day_sectors.dart';

/// Экран календаря с запланированными и выполненными событиями.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(calendarEventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Календарь'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Сегодня',
            onPressed: () {
              final now = DateTime.now();
              setState(() {
                _focusedDay = now;
                _selectedDay = now;
              });
            },
          ),
        ],
      ),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Ошибка: $err')),
        data: (eventsByDay) => _buildBody(eventsByDay),
      ),
    );
  }

  /// Календарь и список в одном прокручиваемом полотне.
  ///
  /// Это устраняет overflow на низких экранах (поворот, маленькие
  /// устройства), потому что ни один блок не требует фиксированной
  /// высоты от Column.
  Widget _buildBody(Map<DateTime, List<CalendarEvent>> eventsByDay) {
    final key = _dateOnly(_selectedDay);
    final events = eventsByDay[key] ?? const <CalendarEvent>[];
    final active = events.where((e) => !e.isCompleted).toList(growable: false);
    final done = events.where((e) => e.isCompleted).toList(growable: false);

    return CustomScrollView(
      slivers: [
        // Календарь.
        SliverToBoxAdapter(child: _buildCalendar(eventsByDay)),
        const SliverToBoxAdapter(child: Divider(height: 1)),

        // Заголовок выбранного дня.
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              DateFormat('d MMMM yyyy, EEEE', 'ru').format(_selectedDay),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),

        // Пустой день.
        if (events.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyDayView(),
          )
        else ...[
          if (active.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _SectionHeader(title: 'Активные', count: active.length),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _EventTile(event: active[i]),
                ),
                childCount: active.length,
              ),
            ),
          ],
          if (done.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _SectionHeader(
                  title: 'Выполнено',
                  count: done.length,
                  muted: true,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _EventTile(event: done[i]),
                ),
                childCount: done.length,
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ],
    );
  }

  Widget _buildCalendar(Map<DateTime, List<CalendarEvent>> eventsByDay) {
    return TableCalendar<CalendarEvent>(
      locale: 'ru',
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      currentDay: DateTime.now(),
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: 'Месяц'},
      startingDayOfWeek: StartingDayOfWeek.monday,
      onDaySelected: (selected, focused) {
        setState(() {
          _selectedDay = selected;
          _focusedDay = focused;
        });
      },
      onPageChanged: (focused) {
        setState(() => _focusedDay = focused);
        ref
            .read(calendarRangeProvider.notifier)
            .setRange(
              DateTimeRange(
                start: DateTime(focused.year, focused.month, 1),
                end: DateTime(focused.year, focused.month + 1, 0, 23, 59, 59),
              ),
            );
      },
      eventLoader: (day) => eventsByDay[_dateOnly(day)] ?? const [],
      calendarBuilders: CalendarBuilders<CalendarEvent>(
        markerBuilder: (context, day, events) {
          if (events.isEmpty) return null;
          return _buildSectorMarker(events);
        },
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 0,
        cellMargin: const EdgeInsets.all(4),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
    );
  }

  Widget _buildSectorMarker(List<CalendarEvent> events) {
    final active = events.where((e) => !e.isCompleted);
    final counts = <String, int>{};
    for (final e in active) {
      counts[e.type] = (counts[e.type] ?? 0) + 1;
    }
    if (counts.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: DaySectorsMarker(counts: counts),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    this.muted = false,
  });

  final String title;
  final int count;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = muted ? theme.colorScheme.outline : theme.colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '· $count',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDayView extends StatelessWidget {
  const _EmptyDayView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text('На этот день событий нет', style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _EventTile extends ConsumerStatefulWidget {
  const _EventTile({required this.event});

  final CalendarEvent event;

  @override
  ConsumerState<_EventTile> createState() => _EventTileState();
}

class _EventTileState extends ConsumerState<_EventTile> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    final meta = _eventMeta(e);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: meta.color.withValues(alpha: 0.15),
          child: Icon(meta.icon, color: meta.color),
        ),
        title: Text(
          meta.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            decoration: e.isCompleted ? TextDecoration.lineThrough : null,
            color: e.isCompleted ? theme.colorScheme.outline : null,
          ),
        ),
        subtitle: Text(
          _buildSubtitle(e),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: _buildTrailing(context, e),
        onTap: () => _openDetails(context, e),
      ),
    );
  }

  String _buildSubtitle(CalendarEvent e) {
    if (e.type == 'fertilizing' &&
        e.fertilizerType != null &&
        e.fertilizerType!.isNotEmpty) {
      return '${e.plantName} · ${e.fertilizerType}';
    }
    return e.plantName;
  }

  Widget _buildTrailing(BuildContext context, CalendarEvent e) {
    if (_busy) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (e.isCompleted) {
      return IconButton(
        icon: const Icon(Icons.undo),
        tooltip: 'Отменить выполнение',
        onPressed: _undo,
      );
    }

    if (e.isTreatment) {
      return const Icon(Icons.chevron_right);
    }

    return FilledButton.tonal(
      onPressed: _complete,
      child: const Text('Выполнить'),
    );
  }

  Future<void> _complete() async {
    setState(() => _busy = true);
    try {
      final controller = ref.read(careActionControllerProvider);
      await controller.perform(
        plantId: widget.event.plantId!,
        type: widget.event.type,
      );
      ref.invalidate(calendarEventsProvider);
      if (mounted) {
        final label = _eventMeta(widget.event).label.toLowerCase();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.event.plantName}: $label отмечено')),
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

  Future<void> _undo() async {
    setState(() => _busy = true);
    try {
      final e = widget.event;
      if (e.isTreatment) {
        final diagnosisId = e.diagnosisId;
        final stepId = e.stepId;
        if (diagnosisId == null || stepId == null) return;
        await ref
            .read(diagnosisControllerProvider)
            .uncompleteStep(stepId, diagnosisId);
      } else {
        final eventId = e.careEventId;
        if (eventId == null) return;
        await ref.read(careActionControllerProvider).undo(eventId);

        if (e.plantId != null) {
          ref.invalidate(plantByIdProvider(e.plantId!));
          ref.invalidate(plantCareEventsProvider(e.plantId!));
        }
        ref.invalidate(plantsDueForWateringProvider);
        ref.invalidate(userPlantsProvider);
      }
      ref.invalidate(calendarEventsProvider);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Выполнение отменено')));
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

  void _openDetails(BuildContext context, CalendarEvent e) {
    if (e.isTreatment && e.diagnosisId != null) {
      context.push('/diagnosis/treatment/${e.diagnosisId}');
      return;
    }
    if (e.plantId != null) {
      context.push('/plants/${e.plantId}');
    }
  }

  _EventMeta _eventMeta(CalendarEvent e) {
    switch (e.type) {
      case 'watering':
        return const _EventMeta(
          Icons.water_drop,
          CalendarEventColors.watering,
          'Полив',
        );
      case 'fertilizing':
        return const _EventMeta(
          Icons.eco,
          CalendarEventColors.fertilizing,
          'Удобрение',
        );
      case 'misting':
        return const _EventMeta(
          Icons.spa,
          CalendarEventColors.misting,
          'Опрыскивание',
        );
      case 'repotting':
        return const _EventMeta(
          Icons.redeem,
          CalendarEventColors.repotting,
          'Пересадка',
        );
      case 'treatment':
        return _EventMeta(
          Icons.healing,
          AppTheme.treatmentRed,
          e.title != null && e.title!.isNotEmpty ? e.title! : 'Лечение',
        );
      default:
        return _EventMeta(Icons.event, Colors.grey, e.type);
    }
  }
}

class _EventMeta {
  const _EventMeta(this.icon, this.color, this.label);

  final IconData icon;
  final Color color;
  final String label;
}

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
